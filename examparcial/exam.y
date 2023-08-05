%{
  #include<stdio.h>
  #include<string.h>
  #include<ctype.h>
  char lexema[255];
  void yyerror(char *);
%}

// Especificamos los tokens
%token NUMHEXADECIMAL
%token RAIZ
%token LIB LIBNAME
%token PROG PROGNAME VAR ID INI FIN

%start code

// Especificamos la gramatica
%%
code: head body;
head: liblst progstm varstm;
liblst: LIB '#' LIBNAME '#' liblst
      | %empty;
progstm: PROG PROGNAME ';';
varstm: VAR idlst ';';
idlst: ID
     | ID ',' idlst;
body: INI asiglst FIN;
asiglst: ID '=' exp ';'
       | ID '=' exp ';' asiglst;
exp: exp '+' term
   | exp '-' term
   | term;
term: term '*' NUMHEXADECIMAL
    | term '/' NUMHEXADECIMAL
    | term '*' ID
    | term '/' ID
    | '(' exp ')'
    | RAIZ '(' exp ')'
    | NUMHEXADECIMAL
    | ID;
%%

void yyerror(char *msg) {
  printf("error: %s", msg);
}

// Especificamos las reglas de los tokens
int yylex() {
  char c;
  while(1) {
    c = getchar();
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

    char CADENA_LIB[] = "libreria";
    if(c == CADENA_LIB[0]) {
      int i = 0, j = 0;
      do {
        lexema[i++] = c;
        c = getchar();
        j++;
      } while (c == CADENA_LIB[j] && j < 8);
      if(j == 8) {
        ungetc(c, stdin);
        lexema[i] == 0;
        return LIB;
      }
    }

    char CADENA_PROG[] = "Programa";
    if(c == CADENA_PROG[0]) {
      int i = 0, j = 0;
      do {
        lexema[i++] = c;
        c = getchar();
        j++;
      } while (c == CADENA_PROG[j] && j < 8);
      if(j == 8) {
        ungetc(c, stdin);
        lexema[i] == 0;
        return PROG;
      }
    }

    char CADENA_VAR[] = "var";
    if(c == CADENA_VAR[0]) {
      int i = 0, j = 0;
      do {
        lexema[i++] = c;
        c = getchar();
        j++;
      } while (c == CADENA_VAR[j] && j < 3);
      if(j == 3) {
        ungetc(c, stdin);
        lexema[i] == 0;
        return VAR;
      }
    }

    char CADENA_INI[] = "Inicio";
    if(c == CADENA_INI[0]) {
      int i = 0, j = 0;
      do {
        lexema[i++] = c;
        c = getchar();
        j++;
      } while (c == CADENA_INI[j] && j < 6);
      if(j == 6) {
        ungetc(c, stdin);
        lexema[i] == 0;
        return INI;
      }
    }

    char CADENA_FIN[] = "Fin";
    if(c == CADENA_FIN[0]) {
      int i = 0, j = 0;
      do {
        lexema[i++] = c;
        c = getchar();
        j++;
      } while (c == CADENA_FIN[j] && j < 3);
      if(j == 3) {
        ungetc(c, stdin);
        lexema[i] == 0;
        return FIN;
      }
    }

    char CADENA_RAIZ[] = "raiz";
    if(c == CADENA_RAIZ[0]) {
      int i = 0, j = 0;
      do {
        lexema[i++] = c;
        c = getchar();
        j++;
      } while (c == CADENA_RAIZ[j] && j < 4);
      if(j == 4) {
        ungetc(c, stdin);
        lexema[i] == 0;
        return RAIZ;
      }
    }

    if(c >= 65 && c <= 70) {
      int i = 0;
      lexema[i++] = c;
      c = getchar();
      if(c >= 97 && c <= 122) {
        do {
          lexema[i++] = c;
          c = getchar();
        } while(c >= 97 && c <= 122);
        ungetc(c, stdin);
        lexema[i] == 0;
        return PROGNAME;
      }
      if((c >= 65 && c <= 70) || isdigit(c)) {
        do {
          lexema[i++] = c;
          c = getchar();
        } while((c >= 65 && c <= 70) || isdigit(c));
        ungetc(c, stdin);
        lexema[i] == 0;
        return NUMHEXADECIMAL;
      }
    } else if(c > 70 && c <= 90) {
      int i = 0;
      do {
        lexema[i++] = c;
        c = getchar();
      } while(c >= 97 && c <= 122);
      ungetc(c, stdin);
      lexema[i] == 0;
      return PROGNAME;
    }

    if(isdigit(c)) {
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
        lexema[i] == 0;
        return ID;
      }

      int i = 0;
      do {
        lexema[i++] = c;
        c = getchar();
      } while(isalnum(c));
      ungetc(c, stdin);
      lexema[i] == 0;
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