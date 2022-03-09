%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lexico.c"
#include "estruct.c"

void erro (char *);
int yyerror (char *);
int conta = 0;
int rotulo = 0;
char tipo = 0;
%}

%start programa

%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_IDENTIF
%token T_LEIA
%token T_ESCREVA
%token T_ENQTO
%token T_FACA
%token T_FIMENQTO
%token T_SE
%token T_SENAO
%token T_ENTAO
%token T_FIMSE
%token T_ATRIB
%token T_VEZES
%token T_DIV
%token T_MAIS
%token T_MENOS
%token T_IGUAL
%token T_MAIOR
%token T_MENOR
%token T_E
%token T_OU
%token T_V
%token T_F
%token T_NUMERO
%token T_NAO
%token T_ABRE
%token T_FECHA
%token T_ABRE_C
%token T_FECHA_C
%token T_INTEIRO
%token T_LOGICO

%left T_E T_OU
%left T_IGUAL
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV
%%  

programa
    : cabecalho variaveis 
        { 
          mostra_tabela();
          fprintf(yyout, "\tAMEM\t%d\n", conta);
          empilha (conta); 
        }
    T_INICIO lista_comandos T_FIM
        { 
          fprintf(yyout, "\tDMEM\t%d\n", desempilha());
          fprintf(yyout, "\tFIMP\n"); 
        }
    ;

cabecalho
    : T_PROGRAMA T_IDENTIF
        { fprintf(yyout, "\tINPP\n"); }
    ;

variaveis
    :
    | declaracao_variaveis
    ;

declaracao_variaveis
    : tipo lista_variaveis declaracao_variaveis
    | tipo lista_variaveis
    ;

tipo
    : T_INTEIRO
        {
            tipo = 'i';
        }
    | T_LOGICO 
        {
            tipo = 'l';
        }
    ;

lista_variaveis
    : lista_variaveis variavel 
        {
            insere_simbolo(elem_tab);
        }
    | variavel
        {
            insere_simbolo(elem_tab);
        }

    ;

variavel
    : T_IDENTIF
       {
            strcpy(elem_tab.id, atomo); 
            printf("var: %s\n", atomo);  
            elem_tab.tipo = tipo;
        }
      declaracao_tamanho
    ;

declaracao_tamanho
    : T_ABRE_C T_NUMERO T_FECHA_C
        {
            strcpy(elem_tab.cat, "VET");
            elem_tab.tam = atoi(atomo);
            elem_tab.endereco = conta; 
            conta += atoi(atomo);       
        }
    | 
        {
            strcpy(elem_tab.cat, "VAR");
            elem_tab.tam = 1; 
            elem_tab.endereco = conta++; 
        }

lista_comandos
    :
    | comando lista_comandos
    ;

comando 
    : leitura
    | escrita
    | repeticao
    | selecao
    | atribuicao
    ;

leitura
    : T_LEIA T_IDENTIF
        {
          fprintf(yyout, "\tLEIA\n");
          int pos = busca_simbolo(atomo);
            if (pos == -1)
              erro ("Variavel não declarada!");
            fprintf(yyout, "\tARZG\t%d\n", TabSimb[pos].endereco); 
        }
    ;

escrita
    : T_ESCREVA expr
        { 
            desempilha();
            fprintf(yyout, "\tESCR\n"); 
        }
    ;

repeticao
    : T_ENQTO 
        { 
            rotulo++;
            fprintf (yyout, "L%d\tNADA\n", rotulo);
            empilha(rotulo);
        }
    expr T_FACA 
        { 
            char t = desempilha();
            if (t != 'l') erro ("Incompatibilidade de tipo!");
            rotulo++;
            fprintf (yyout, "\tDSVF\tL%d\n", rotulo); 
            empilha(rotulo);
        }
    lista_comandos T_FIMENQTO
        { 
            int r1 = desempilha();
            int r2 = desempilha();
            fprintf (yyout, "\tDSVS\tL%d\n", r2);
            fprintf (yyout, "L%d\tNADA\n", r1); 
        }
    ;

selecao
    : T_SE expr T_ENTAO 
        { 
            char t = desempilha();
            if (t != 'l') erro ("Incompatibilidade de tipo!");
            rotulo++;
            empilha(rotulo);
            fprintf (yyout, "\tDSVF\tL%d\n", rotulo); 
        }
    lista_comandos T_SENAO 
        { 
            int r = desempilha();
            rotulo++;
            fprintf (yyout, "\tDSVS\tL%d\n", rotulo);
            empilha(rotulo);
            fprintf (yyout, "L%d\tNADA\n", r); 
        }
    lista_comandos T_FIMSE
        { 
            int r = desempilha();
            fprintf (yyout, "L%d\tNADA\n", r); 
        }
    ;

atribuicao
    : T_IDENTIF 
        {
            int pos = busca_simbolo(atomo);
            if (pos == -1)
              erro ("Variavel não declarada!");
            empilha(pos);

        }
      T_ATRIB expr
        {
            char t = desempilha();
            int p = desempilha();
            if (t != TabSimb[p].tipo) erro ("Incompatibilidade de tipo!");

            fprintf(yyout, "\tARZG\t%d\n", TabSimb[p].endereco); 
        }
    ;

expr
    : expr T_VEZES expr
        { 
            char t1 = desempilha();
            char t2 = desempilha();
            if (t1 != 'i' || t2 != 'i') erro ("Incompatibilidade de tipo!");
            empilha('i');
            fprintf (yyout, "\tMULT\n"); 
            
        }
    | expr T_DIV expr
    
        { 
            char t1 = desempilha();
            char t2 = desempilha();
            if (t1 != 'i' || t2 != 'i') erro ("Incompatibilidade de tipo!");
            empilha('i');
            fprintf (yyout, "\tDIVI\n"); 
        }
    | expr T_MAIS expr
        { 
            char t1 = desempilha();
            char t2 = desempilha();
            if (t1 != 'i' || t2 != 'i') erro ("Incompatibilidade de tipo6!");
            empilha('i');
            fprintf (yyout, "\tSOMA\n"); 
        }
    | expr T_MENOS expr
        { 
            char t1 = desempilha();
            char t2 = desempilha();
            if (t1 != 'i' || t2 != 'i') erro ("Incompatibilidade de tipo!");
            empilha('i');
            fprintf (yyout, "\tSUBT\n"); 
        }

    | expr T_MAIOR expr
        { 
            char t1 = desempilha();
            char t2 = desempilha();
            if (t1 != 'i' || t2 != 'i') erro ("Incompatibilidade de tipo!");
            empilha('l');
            fprintf (yyout, "\tCMMA\n"); }
    | expr T_MENOR expr
        { 
            char t1 = desempilha();
            char t2 = desempilha();
            if (t1 != 'i' || t2 != 'i') erro ("Incompatibilidade de tipo!");
            empilha('l');
            fprintf (yyout, "\tCMME\n"); 
        }
    | expr T_IGUAL expr
        { 
            char t1 = desempilha();
            char t2 = desempilha();
            if (t1 != 'i' || t2 != 'i') erro ("Incompatibilidade de tipo!");
            empilha('l');
            fprintf (yyout, "\tCMIG\n"); 
        }

    | expr T_E expr
        { 
            char t1 = desempilha();
            char t2 = desempilha();
            if (t1 != 'l' || t2 != 'l') erro ("Incompatibilidade de tipo!");
            empilha('l');
            fprintf (yyout, "\tCONJ\n"); 
        }
    | expr T_OU expr
        { 
            char t1 = desempilha();
            char t2 = desempilha();
            if (t1 != 'l' || t2 != 'l') erro ("Incompatibilidade de tipo!");
            empilha('l');
            fprintf (yyout, "\tCONJ\n");
            fprintf (yyout, "\tDISJ\n"); 
        }

    | termo
    ;

termo
    : T_IDENTIF 
        { 
            int pos = busca_simbolo(atomo);
            if (pos == -1) erro ("Variável não encontrada!");
            fprintf (yyout, "\tCRVG\t%d\n", TabSimb[pos].endereco); 
            empilha( TabSimb[pos].tipo);
        }
    | T_NUMERO
        { 
            fprintf (yyout, "\tCRCT\t%d\n", atoi(atomo)); 
            empilha('i');
        }
    | T_V
        { 
            fprintf (yyout, "\tCRCT\t1\n"); 
            empilha('l');
        }
    | T_F
        { 
            fprintf (yyout, "\tCRCT\t0\n");
            empilha('l'); 
        }
    | T_NAO termo
        { 
            int t = desempilha();
            if (t != 'l') erro ("Incompatibilidade de tipos10!");
            empilha('l');
            fprintf (yyout, "\tNEGA\n");
            
        }
    | T_ABRE expr T_FECHA
    ;

%%

void erro (char *s) {
    printf("ERRO na linha %d: %s\n", nlinha, s);
    exit(10);
}

int yyerror(char *s) {
    erro("Erro de sintaxe");
}

int main (int argc, char *argv[]) {
    char *p, nameIn[100], nameOut[100];
    argv++;
    if (argc < 2) {
        puts ("\nCompilador Simples");        
        puts ("\n\tUso: ./simples <nomefonte>[simples]\n\n");
        exit(10);
    }
    p = strstr(argv[0], ".simples");
    if (p) *p = 0;
    strcpy(nameIn, argv[0]);
    strcat(nameIn, ".simples");
    strcpy(nameOut, argv[0]);
    strcat(nameOut, ".mvs");

    yyin = fopen(nameIn, "r");
    if (!yyin) {
        printf("\nErro: arquivo %s nao encontrado\n", nameIn);
        exit(10);
    }
    yyout = fopen(nameOut, "wt");

    if (!yyparse())
    puts("Programa ok!");
}