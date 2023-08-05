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

%token ID NUM INI FIN

%%
prog: INI stm_lst FIN;

stm_lst: stm ','
       | stm ',' stm_lst;
stm: ID '=' expr;

expr: expr '+' term
    | expr '-' term
    | term;
term: term '*' term2
    | term '/' term2
    | term2;
term2: '(' expr ')'
     | NUM
     | ID;
%%

void yyerror(char *mgs)
{
	printf("error: %s",mgs);
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

