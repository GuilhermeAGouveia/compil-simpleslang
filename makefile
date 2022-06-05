simples: estrut.c lexico.l sintatico.y; \
	  flex -o lexico.c lexico.l;\
	  bison -v -d sintatico.y -o sintatico.c;\
	  gcc sintatico.c -o simples;
	  
limpa: ; \
	rm -f lexico.c sintatico.c sintatico.h sintatico.output *~ simples