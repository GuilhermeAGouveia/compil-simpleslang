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
#include "sintatico.h"
void erro (char *s);
char atomo[100];
int nlinha = 1;
%}

identificador [a-zA-Z][a-zA-Z0-9]*
numero        [0-9]+
espaco        [ \t]+
novalinha     [\n]
%x coment
%option noyywrap

%%

programa          return T_PROGRAMA;
inicio            return T_INICIO;
fimprograma       return T_FIM;

leia              return T_LEIA;
escreva           return T_ESCREVA;

se                return T_SE;
entao             return T_ENTAO;
senao             return T_SENAO;
fimse             return T_FIMSE;

enquanto          return T_ENQTO;
faca              return T_FACA;
fimenquanto       return T_FIMENQTO;

"+"               return T_MAIS;
"-"               return T_MENOS;
"*"               return T_VEZES;
"div"             return T_DIV;

">"               return T_MAIOR;
"<"               return T_MENOR;
"="               return T_IGUAL;

e                 return T_E;
ou                return T_OU;
nao               return T_NAO;

"<-"              return T_ATRIB;
"("               return T_ABRE;
")"               return T_FECHA;

inteiro           return T_INTEIRO;
logico            return T_LOGICO;
V                 return T_V;
F                 return T_F;

"["               return T_ABRE_C;
"]"               return T_FECHA_C;

{identificador}   { strcpy (atomo, yytext); return T_IDENTIF; }
{numero}          { strcpy (atomo, yytext); return T_NUMERO; }
{espaco}          /* Não faz nada */; 
{novalinha}       nlinha++;

"//".*            ; /* não faz nada */
"/*"              BEGIN (coment);
<coment>"*/"      BEGIN (INITIAL);
<coment>.         ;
<coment>\n        nlinha++;


.                 erro ("LEXICO"); 

%%