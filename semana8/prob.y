%{
#include <ctype.h>
#include <stdio.h>
void yyerror(char *);
int yylex();
%}

%token ID IGUAL NUM MAS DOSPUNTOS

%%
expr: ID DOSPUNTOS IGUAL termino expr
    |  ;
termino: termino MAS NUM
       | NUM;
%%

void yyerror(char *mgs)
{
	printf("error: %s",mgs);
}

int yylex()
{ 
  char c;

  while(1) {
    c = getchar();
    
    if(c == '\n') continue;
    if(c == ' ') continue;

    if(c == ':') return DOSPUNTOS;
    if(c == '=') return IGUAL;
    if(c == '+') return MAS;

    if(isalpha(c)) {
      int i = 0;
      do{
        lexema[i++] = c;
        c = getchar();
      } while(isalnum(c));
      ungetc(c, stdin);
      lexema[i] = 0;
      return ID;
    }

    if(isdigit(c)) {
      int i = 0;
      do{
        lexema[i++] = c;
        c = getchar();
      } while(isdigit(c));
      ungetc(c, stdin);
      lexema[i] = 0;
      return NUM;
    }

    return c;
  }
}

int main()
{
	return yyparse();
}

