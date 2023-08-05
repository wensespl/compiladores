%{
#include <ctype.h>
#include <stdio.h>
#define YYSTYPE double /* double type for YACC stack */
void yyerror(char *);
int yylex();
%}

%token NUMBER

%%
prog: expr '\n' prog { printf("VALOR %g\n", $1);  }
    | %empty;
expr: expr '+'  term	{ $$ = $1 + $3; }
    | expr '-'  term	{ $$ = $1 - $3; }	
	  | term { $$ = $1; };
term: term '*' NUMBER { $$ = $1 * $3; }
    | term '/' NUMBER { $$ = $1 / $3; }
    | NUMBER;
%%

void yyerror(char *mgs)
{
	printf("error: %s",mgs);
}

int yylex()
{ double t;
	int c;
	
  while ((c = getchar()) == ' ');
	
  if (c == '.' || isdigit(c)) {
		ungetc(c, stdin);
		scanf("%lf", &t);
    yylval = t; // pasando valor a la pila
		return NUMBER;
	}

	return c;
}

int main()
{
	return yyparse();
}

