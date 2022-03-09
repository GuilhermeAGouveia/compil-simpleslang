/*-------------------------------------------------
  |         Unifal - Universidade Federal de Alfenas.
  |             BACHARELADO EM CIENCIA DA COMPUTACAO.
  | Trabalho..: Vetor e verificaocao de tipos
  | Disciplina: Teoria de Linguagens e Compiladores
  | Professor.: Luiz Eduardo da Silva
  | Aluno.....: Guilherme Augusto Gouveia
  | Data......: 09/03/2022
  -------------------------------------------------*/

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
int pos = -1; //modificação desnecessária, mas que melhora o desempenho do código
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
%token T_ABRE_C //adicionando abre chaves
%token T_FECHA_C //adicionando fecha chaves
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
          fprintf(yyout, "\tFIMP"); 
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
    | variavel

    ;

variavel
    : T_IDENTIF
       {
            strcpy(elem_tab.id, atomo); 
            elem_tab.tipo = tipo;
        } // Adiciona as informações necessários antes que passe para declaracao_tamanho, 
          // pois quando isso ocorrer, a variavel mudará seu conteúdo para o tamanho do vetor, se o elemento for um vetor
      declaracao_tamanho
    ;

declaracao_tamanho
    : T_ABRE_C T_NUMERO T_FECHA_C
        {
            strcpy(elem_tab.cat, "VET");
            elem_tab.tam = atoi(atomo);
            elem_tab.endereco = conta; 
            conta += atoi(atomo);      
            insere_simbolo(elem_tab);
        } //acaba de inserir as informações em elem_tab e o colocar na tabela de simbolos efetivamente

    | //Ocorre quando não é vetor, ou seja, apenas uma variável
        {
            strcpy(elem_tab.cat, "VAR");
            elem_tab.tam = 1; 
            elem_tab.endereco = conta++; 
            insere_simbolo(elem_tab);
        } //acaba de inserir as informações em elem_tab e o colocar na tabela de simbolos efetivamente

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
            pos = busca_simbolo(atomo);
                if (pos == -1)
                erro ("Variavel não declarada!");
            
                empilha(pos);
        }
      declaracao_posicao //aqui já temos o valor da expressão que representa a posição calculada no topo da pilha de execução
        {
            int p = desempilha();
            fprintf(yyout, "\tLEIA\n"); 
            if (!strcmp(TabSimb[p].cat, "VAR"))
                fprintf(yyout, "\tARZG\t%d\n", TabSimb[pos].endereco); 
            else 
                fprintf(yyout, "\tARZV\t%d\n", TabSimb[pos].endereco);
        
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
            pos = busca_simbolo(atomo);
            if (pos == -1)
              erro ("Variavel não declarada!");
            empilha(pos);

        }
      declaracao_posicao //aqui já temos na pilha a expr que indica posição resolvida
      T_ATRIB expr //aqui já temos na pilha a expr que será armazenada na pilha
        {
            char t = desempilha();
            int p = desempilha();
            if (t != TabSimb[p].tipo) erro ("Incompatibilidade de tipo!");

            if (!strcmp(TabSimb[p].cat, "VAR")){
                fprintf(yyout, "\tARZG\t%d\n", TabSimb[p].endereco); 
            }
            else {
                fprintf(yyout, "\tARZV\t%d\n", TabSimb[p].endereco); 
            }
        }
    ;

declaracao_posicao //diferente da declaracao_tamanho, essa regra aceita expressões entre os colchetes
    : T_ABRE_C expr T_FECHA_C
        {
            //valida o tipo retornado por expr, que deve ser inteiro
            int t = desempilha(); 
            if (t != 'i') erro ("Incompatibilidade de tipo!");
        }
    | 
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
            pos = busca_simbolo(atomo);
            if (pos == -1) erro ("Variável não encontrada!");
            empilha(pos); //declaracao posicao também pode usar a variavel global pos, e isso sobrescreverá seu conteúdo em determinado contexto
                          //logo o valor e empilhado e reutilizado abaixo
        }
      declaracao_posicao // quando chegamos aqui, a pilha de execução já contém o valor da expressão que indica posição no topo
        {
            pos = desempilha(); //recupera a posicao empilhada logo acima
            if (!strcmp(TabSimb[pos].cat, "VAR")){
                fprintf (yyout, "\tCRVG\t%d\n", TabSimb[pos].endereco);
            }   
            else {
                fprintf (yyout, "\tCRVV\t%d\n", TabSimb[pos].endereco); 
            }
            empilha(TabSimb[pos].tipo);
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