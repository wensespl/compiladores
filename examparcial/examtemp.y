%{
  #include<stdio.h>
  #include<string.h>
  #include<ctype.h>
  char lexema[255];
  void yyerror(char *);
%}

%token NUMBER

%%
prog: exp '\n' prog { printf("VALOR %g\n", $1); };
prog:  ;
exp: exp '+' term { $$ = $1 + $3; }
   | term { $$ = $1; };
term: NUMBER;
%%

void yyerror(char *msg) {
  printf("error: %s", msg);
}

int yylex() {
  double t;
  int c;

  while((c = getchar()) == ' ')

  

  while(1) {
    c = getchar();
    // if(c == '\n') continue;
    if(isspace(c)) continue;

    // if(c == '+') return MAS;
    // if(c == '-') return MENOS;
    // if(c == '*') return POR;
    // if(c == '/') return ENTRE;
    // if(c == '#') return HTAG;
    // if(c == ',') return COMA;
    // if(c == ';') return PCOMA;
    // if(c == '(') return LPAR;
    // if(c == ')') return RPAR;
    // if(c == '=') return IGUAL;

    // Nombres de programa caneda que inicia con mayuscula
    if(c >= 65 && c <= 90) {
      int i = 0;
      do {
        lexema[i++] = c;
        c = getchar();
      } while(isalpha(c));
      ungetc(c, stdin);
      lexema[i] == 0;
      return PROGNAME;
    }

    if((c >= 65 && c <= 70) || isdigit(c)) {
      int i = 0;
      do {
        lexema[i++] = c;
        c = getchar();
      } while((c >= 65 && c <= 70) || isdigit(c));
      ungetc(c, stdin);
      lexema[i] == 0;
      return NUMHEXADECIMAL;
    }

    if(isalpha(c)) {
      // Nombres de libreria cadena con solo minusculas
      if(c >= 97 && c <= 122) {
        int i = 0;
        do {
          lexema[i++] = c;
          c = getchar();
        } while(c >= 97 && c <= 122);
        if(c == '.') {
          lexema[i++] = c;
          c = getchar();
          if(c == 'x') {
            lexema[i++] = c;
            return LIBNAME;
          }
        }
        do {
          lexema[i++] = c;
          c = getchar();
        } while(isalnum(c));
        ungetc(c, stdin);
        lexema[i] = 0;
        return ID;
      }

      int i = 0;
      do {
        lexema[i++] = c;
        c = getchar();
      } while(isalnum(c));
      ungetc(c, stdin);
      lexema[i] = 0;
      return ID;
    }



    return c;
  }
}

int main() {
  if(!yyparse()) printf("\ncadena valida\n");
  else printf("cadena invalida\n");
  return 0;
}
