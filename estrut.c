/*-------------------------------------------------
  |         Unifal - Universidade Federal de Alfenas.
  |             BACHARELADO EM CIENCIA DA COMPUTACAO.
  | Trabalho..: Vetor e verificaocao de tipos
  | Disciplina: Teoria de Linguagens e Compiladores
  | Professor.: Luiz Eduardo da Silva
  | Aluno.....: Guilherme Augusto Gouveia
  | Data......: 09/03/2022
  -------------------------------------------------*/

#define TAM_TAB 100
#define TAM_PIL 100

//Pilha semântica
int Pilha[TAM_PIL];
int topo = -1;

//Tabela de símbolos da Pilha
struct elem_tam_simbolos {
    char id[100];
    int endereco;
    char tipo;
    char cat[4];
    int tam;
} TabSimb[TAM_TAB], elem_tab;
int pos_tab;

//Rotinas de pilha semântica
void empilha(int valor) {
    if (topo == TAM_PIL)
        printf("Erro: Pilha cheia!\n");
        Pilha[++topo] = valor;
}
    
int desempilha() {
    if (topo == -1)
        printf("Erro: Pilha vazia!\n");
        return Pilha[topo--];
}

//Rotinas de Tabela de símbolos
// retorna -1 se não encontrar o id
int busca_simbolo (char *id) {
    int i = pos_tab - 1;
    for (; strcmp(TabSimb[i].id, id) && i >= 0; i--);
    return i;
}

void insere_simbolo (struct elem_tam_simbolos elem) {
    int i;
    if (pos_tab == TAM_TAB)
        erro ("Tabela de símbolos cheia!");
    i = busca_simbolo(elem.id);
    if (i != -1) 
        erro ("Identificador duplicado");
    TabSimb[pos_tab++] = elem;
    
}

void mostra_tabela() {
    int i;
    printf("Tabela de símbolos");
    printf("\n%3c | %30s | %s | %s | %s | %s\n",'#', "ID", "END", "tipo", "cat", "tam");
    for (i = 0; i < 60; i++)
        printf("-");
    for (i = 0; i < pos_tab; i++)
        printf("\n%3d | %30s | %3d | %4c | %3s | %d", i, TabSimb[i].id, TabSimb[i].endereco, TabSimb[i].tipo, TabSimb[i].cat, TabSimb[i].tam);
    puts("\n");
}