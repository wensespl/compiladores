%{
#include <ctype.h>
#include <stdio.h>
#include <string.h>
char lexema[255];
void yyerror(char *msg);

typedef struct{
  char nombre[60];
  double valor;
  int token;
} tipoTS;
tipoTS TablaSim[100];
int nSim = 0;

int localizaSimb(char *, int);
void imprimeTablaSim();

int yylex();
int EsPalabraReservada(char[], int);
%}

%PROGRAMA ID INICIO FIN NUM VARIABLE ASIGNAR SUMAR
%token ID NUM INI FIN

%%
S: PROGRAMA ID ';' INICIO listaInstr FIN '.';
listaInstr: instr listaInstr
          |  ;
instr: ID {$$=localizaSimb(lexema, ID);} ':' '=' expr ';';
expr: expr '+' term;
expr: term;
term: NUM {$$localizaSimb(lexema, NUM);};
%%

int localizaSimb(char *nom, int tok){
  int i;
  for (i=0; i<nSim; i++){
    if(!strcasecmp(TablaSim[i].nombre, nom))
      return i;
  }

  strcpy(TablaSim[nSim].nombre, nom);
  TablaSim[nSim].token = tok;

  if (tok == ID) TablaSim[nSim].valor = 0.0;
  if (tok == NUM) sscanf(nom, "%lf", &TablaSim[nSim].valor);
  nSim++;
  return nSim-1;
}

void imprimeTablaSim(){
  int i;
  for (i=0; i<nSim; i++) {
    printf("%d  nombre=%s, tok=%d, valor=%lf", TablaSim[i].nombre, TablaSim[i].token, TablaSim[i].valor)
  }
}

void yyerror(char *mgs)
{
	printf("ERROR: %s\n", mgs);
}

int EsPalabraReservada(char lexema[], int default_token) {
  //strcmp considera mayusculas y minusculas
  //strcasecmp ignora mayusculas de minusculas
  if(strcmp(lexema,"INICIO") == 0) return INI;
  if(strcmp(lexema,"FIN") == 0) return FIN;

  return default_token;
}

int yylex()
{ 
  char c;

  while(1) {
    c = getchar();
    
    if(c == '\n') continue;
    if(c == ' ') continue;
    if(isspace(c)) continue;

    if(isalpha(c)) {
      int i = 0;
      do{
        lexema[i++] = c;
        c = getchar();
      } while(isalnum(c));
      ungetc(c, stdin);
      lexema[i] = '\0';
      return EsPalabraReservada(lexema, ID);
    }

    if(isdigit(c)) {
      int i = 0;
      do{
        lexema[i++] = c;
        c = getchar();
      } while(isdigit(c));
      ungetc(c, stdin);
      lexema[i] = '\0';
      return NUM;
    }

    return c;
  }
}

int main()
{
	if(!yyparse()) printf("cadena valida\n");
  else printf("cadena invalida\n");
  return 0;
}

