/*--------------------------------------------------------
 *      Simulador da Maquina Virtual Simples (MVS)
 *      Por Luiz Eduardo da Silva
 *--------------------------------------------------------*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/*--------------------------------------------------------
 * Conjunto de instrucoes mnemonicas da MVS
 *--------------------------------------------------------*/
#define TOTALINST 33
char *inst[TOTALINST] = {
    "CRVG", /* Carrega valor */
    "CRCT", /* Carrega constante */
    "SOMA", /* Soma */
    "SUBT", /* Subtrai */
    "MULT", /* Multiplica */
    "DIVI", /* Divide (divisao inteira) */
    "CMIG", /* Compara se igual */
    "CMMA", /* Compara se maior */
    "CMME", /* Compara se menor */
    "CONJ", /* Conjuncao - e logico */
    "DISJ", /* Disjuncao - ou logico */
    "NEGA", /* Negacao - nao logico */
    "ARZG", /* Armazena na variavel */
    "DSVS", /* Desvia sempre */
    "DSVF", /* Desvia se falso */
    "NADA", /* Nada */
    "ESCR", /* Escreve */
    "LEIA", /* Le */
    "INPP", /* Inicia Programa Principal */
    "AMEM", /* Aloca memoria */
    "CRVL", /* Carrega valor local */
    "ARZL", /* Armazena Local */
    "CREL", /* Carrega endereco local */
    "CREG", /* Carrega endereco global */
    "CRVI", /* Carrega valor indireto */
    "ARMI", /* Armazena indireto */
    "SVCP", /* Salva contador de programa */
    "ENSP", /* Entrada Sub-Programa */
    "RTSP", /* Retorno Sub-Programa */
    "DMEM", /* Desaloca memoria */
    "FIMP", /* Fim do programa */
    "ARZV", /* Armazena em vetor */
    "CRVV"  /* Carrega valor de vetor */
};

enum codinst
{
    CRVG,
    CRCT,
    SOMA,
    SUBT,
    MULT,
    DIVI,
    CMIG,
    CMMA,
    CMME,
    CONJ,
    DISJ,
    NEGA,
    ARZG,
    DSVS,
    DSVF,
    NADA,
    ESCR,
    LEIA,
    INPP,
    AMEM,
    CRVL,
    ARZL,
    CREL,
    CREG,
    CRVI,
    ARMI,
    SVCP,
    ENSP,
    RTSP,
    DMEM,
    FIMP,
    ARZV,
    CRVV
};

/*--------------------------------------------------------
 * Regioes do ambiente de execucao da MVS
 *--------------------------------------------------------*/
struct prog
{
    int r, i, o;
} P[500]; /* Regiao do Programa */
int
    L[50]; /* Posicao dos rotulos */
int
    M[500]; /* Pilha M - Dados do programa */

/*--------------------------------------------------------
 * Rotinas da MVS
 *--------------------------------------------------------*/
int busca_instrucao(char *);
int carrega_programa(char *, int *);
void mostra_programa(int);
void executa_programa(int);

/*--------------------------------------------------------
 * Funcao principal.
 * Carrega o codigo passado em linha de comando e executa
 *--------------------------------------------------------*/
int main(int argc, char *argv[])
{
    char *p, nome[100];
    int i, nroinst, debug = 0, mostra = 0;
    argc--;
    argv++;
    if (argc < 1)
    {
        puts("\nMVS - Maquina Virtual Simples");
        puts("Uso: mvs <nomedoarquivo>[.mvs] [opcoes]");
        puts("Opcoes:\t+m=mostra codigo \n\t+d=debug\n\n");
        exit(0);
    }
    if (p = strstr(argv[0], ".mvs"))
        *p = 0;
    strcpy(nome, argv[0]);
    strcat(nome, ".mvs");
    for (i = 0; i < argc; i++)
    {
        if (strstr(argv[i], "+m"))
            mostra = 1;
        if (strstr(argv[i], "+d"))
            debug = 1;
    }
    if (carrega_programa(nome, &nroinst))
    {
        if (mostra)
            mostra_programa(nroinst);
        executa_programa(debug);
        printf("Fim do programa.\n");
    }
    return 1;
}

/*--------------------------------------------------------
 * Funcao que codifica as instrucoes.
 * Recebe o nome da instrucao e retorna um numero.
 *--------------------------------------------------------*/
int busca_instrucao(char *s)
{
    int i;
    for (i = TOTALINST - 1; i >= 0 && strcmp(inst[i], s); i--)
        ;
    return i;
}

void instrucao(char *linha, int *rot, int *inst, int *op)
{
    char str[6];
    int i;
    //---- rotulo
    if (*linha == 'L')
    {
        i = 0;
        linha++;
        while (*linha != '\t')
            str[i++] = *linha++;
        str[i] = 0;
        *rot = atoi(str);
    }
    else
        *rot = -1;
    //---- instrucao
    linha++;
    i = 0;
    while (i < 4)
        str[i++] = *linha++;
    str[i] = 0;
    *inst = busca_instrucao(str);
    //---- operando
    if (*linha == '\t')
    {
        linha++;
        if (*linha == 'L')
            linha++;
        i = 0;
        while (*linha != '\r' && *linha != '\n')
            str[i++] = *linha++;
        str[i] = 0;
        *op = atoi(str);
    }
    else
        *op = -1;
}

/*--------------------------------------------------------
 * Carrega o programa MVS.
 * Recebe o nome do arquivo com o programa para MVS e
 * retorna o numero de linhas do programa.
 *--------------------------------------------------------*/
int carrega_programa(char *s, int *nro)
{
    FILE *arq;
    char linha[20], *p, str[6];
    int j;

    if ((arq = fopen(s, "r")) == NULL)
    {
        puts("\n\nErro na abertura do arquivo\n\n");
        return 0;
    }
    *nro = 0;
    while (!feof(arq))
    {
        int rot, inst, op;
        fgets(linha, 20, arq);
        if (!feof(arq))
        {
            instrucao(linha, &rot, &inst, &op);
            P[*nro].r = rot;
            if (rot != -1)
                L[rot] = *nro;
            P[*nro].i = inst;
            P[*nro].o = op;
            (*nro)++; // proxima instrucao
        }
    }
    fclose(arq);
    return 1;
}

void mostra_programa(int nro)
{
    int i;
    char r_str[10], o_str[10];
    for (i = 0; i < nro; i++)
    {
        if (P[i].r != -1)
            sprintf(r_str, "%d", P[i].r);
        else
            strcpy(r_str, "   ");
        if (P[i].o != -1)
            sprintf(o_str, "%d", P[i].o);
        else
            strcpy(o_str, "   ");
        printf("%3d:[%-3s  %4s  %3s]\n", i, r_str, inst[P[i].i], o_str);
    }
}

/*--------------------------------------------------------
 * Funcao que executa o programa MVS
 * A partir do vetor P (programa) preenchido, executa uma
 * a uma as instrucoes do programa.
 *--------------------------------------------------------*/
void executa_programa(int debug)
{
    int i = 0, s = 0, d;
    char numstr[6];
    while (1)
    {
        if (debug)
        {
            int x;
            printf("M = [");
            for (x = 0; x <= s; x++)
                printf("%d:%d ", x, M[x]);
            printf("]\n%2d:[%2d\t%4s\t%2d]  s=%d  d=%d\n", i, P[i].r, inst[P[i].i], P[i].o, s, d);
            puts("digite . e <ENTER>");
            while (getchar() != '.')
                ;
        }
        switch (P[i].i)
        {
        case CRCT:
            s++;
            M[s] = P[i].o;
            i++;
            break;
        case CRVG:
            s++;
            M[s] = M[P[i].o];
            i++;
            break;
        case ARZG:
            M[P[i].o] = M[s];
            s--;
            i++;
            break;
        case SOMA:
            M[s - 1] = M[s - 1] + M[s];
            s--;
            i++;
            break;
        case SUBT:
            M[s - 1] = M[s - 1] - M[s];
            s--;
            i++;
            break;
        case MULT:
            M[s - 1] = M[s - 1] * M[s];
            s--;
            i++;
            break;
        case DIVI:
            M[s - 1] = M[s - 1] / M[s];
            s--;
            i++;
            break;
        case CONJ:
            if (M[s - 1] && M[s])
                M[s - 1] = 1;
            else
                M[s - 1] = 0;
            s--;
            i++;
            break;
        case DISJ:
            if (M[s - 1] || M[s])
                M[s - 1] = 1;
            else
                M[s - 1] = 0;
            s--;
            i++;
            break;
        case NEGA:
            M[s] = 1 - M[s];
            i++;
            break;
        case CMME:
            if (M[s - 1] < M[s])
                M[s - 1] = 1;
            else
                M[s - 1] = 0;
            s--;
            i++;
            break;
        case CMMA:
            if (M[s - 1] > M[s])
                M[s - 1] = 1;
            else
                M[s - 1] = 0;
            s--;
            i++;
            break;
        case CMIG:
            if (M[s - 1] == M[s])
                M[s - 1] = 1;
            else
                M[s - 1] = 0;
            s--;
            i++;
            break;
        case DSVS:
            i = L[P[i].o];
            break;
        case DSVF:
            if (M[s] == 0)
                i = L[P[i].o];
            else
                i++;
            s--;
            break;
        case NADA:
            i++;
            break;
        case FIMP:
            printf("\n\n");
            return;
        case LEIA:
            s++;
            printf("? ");
            fgets(numstr, 5, stdin);
            M[s] = atoi(numstr);
            i++;
            break;
        case ESCR:
            printf("Saida = %d\n", M[s]);
            s--;
            i++;
            break;
        case AMEM:
            s = s + P[i].o;
            i++;
            break;
        case INPP:
            s = -1;
            i++;
            d = -1;
            break;
        case CRVL:
            s = s + 1;
            M[s] = M[d + P[i].o];
            i++;
            break;
        case ARZL:
            M[d + P[i].o] = M[s];
            s = s - 1;
            i++;
            break;
        case CREL:
            s = s + 1;
            M[s] = d + P[i].o;
            i++;
            break;
        case CREG:
            s = s + 1;
            M[s] = P[i].o;
            i++;
            break;
        case CRVI:
            s = s + 1;
            M[s] = M[M[d + P[i].o]];
            i++;
            break;
        case ARMI:
            M[M[d + P[i].o]] = M[s];
            s = s - 1;
            i++;
            break;
        case SVCP:
            s = s + 1;
            M[s] = i + 2;
            i++;
            break;
        case ENSP:
            s = s + 1;
            M[s] = d;
            d = s + 1;
            i++;
            break;
        case RTSP:
        {
            int nropar = P[i].o;
            d = M[s];
            i = M[s - 1];
            s = s - (nropar + 2);
            break;
        }
        case DMEM:
            s = s - P[i].o;
            i++;
            break;
        case ARZV:
            M[P[i].o + M[s - 1]] = M[s];
            s = s - 2;
            i++;
            break;
        case CRVV:
            M[s] = M[P[i].o + M[s]];
            i++;
            break;
        default:
            printf("Instrucao <%d,%d> MVS desconhecida!", i, P[i].i);
            exit(0);
        }
    }
}
