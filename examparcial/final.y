%{
  #include<stdio.h>
  #include<string.h>
  #include<ctype.h>
  char lexema[255];
  void yyerror(char *);
  int yylex();
  int EsPalabraReservada(char[], int);
%}

// Especificamos los tokens
%token HEX
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
exp: exp '+' term1
   | exp '-' term1
   | term1;
term1: term1 '*' term2
    | term1 '/' term2
    | RAIZ '(' exp ')'
    | term2;
term2: '(' exp ')'
     | HEX
     | ID;
%%

void yyerror(char *msg) {
  printf("error: %s", msg);
}

int EsPalabraReservada(char lexema[], int default_token) {
  //strcmp considera mayusculas y minusculas
  //strcasecmp ignora mayusculas de minusculas
  if(strcmp(lexema,"libreria") == 0) return LIB;
  if(strcmp(lexema,"Programa") == 0) return PROG;
  if(strcmp(lexema,"var") == 0) return VAR;
  if(strcmp(lexema,"Inicio") == 0) return INI;
  if(strcmp(lexema,"Fin") == 0) return FIN;
  if(strcmp(lexema,"raiz") == 0) return RAIZ;
  return default_token;
}

// Especificamos las reglas de los tokens
int yylex() {
  char c;
  while(1) {
    c = getchar();
    if(isspace(c)) continue;

    if(isalpha(c)) {
      // Mayuscula
      if(c >= 65 && c <= 90) {
        // A-F
        if(c >= 65 && c <= 70) {
          int i = 0;
          lexema[i++] = c;
          c = getchar();
          // Minuscula
          if(c >= 97 && c <= 122) {
            do {
              lexema[i++] = c;
              c = getchar();
            } while(c >= 97 && c <= 122);
            ungetc(c, stdin);
            lexema[i] = '\0';
            return EsPalabraReservada(lexema, PROGNAME);
          }
          // A-F0-9
          if(c >= 65 && c <= 70 || isdigit(c)) {
            int i = 0;
            do {
              lexema[i++] = c;
              c = getchar();
            } while((c >= 65 && c <= 70) || isdigit(c));
            ungetc(c, stdin);
            lexema[i] = 0;
            return HEX;
          }

          ungetc(c, stdin);
          lexema[i] = 0;
          return HEX;
        } else {
          int i = 0;
          lexema[i++] = c;
          c = getchar();
          // Minuscula
          if(c >= 97 && c <= 122) {
            do {
              lexema[i++] = c;
              c = getchar();
            } while(c >= 97 && c <= 122);
            ungetc(c, stdin);
            lexema[i] = '\0';
            return EsPalabraReservada(lexema, PROGNAME);
          }
        }
      }

      // Minuscula
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
        ungetc(c, stdin);
        lexema[i] = '\0';
        return EsPalabraReservada(lexema, ID);
      }
    }

    if(isdigit(c)) {
      int i = 0;
      do {
        lexema[i++] = c;
        c = getchar();
      } while((c >= 65 && c <= 70) || isdigit(c));
      ungetc(c, stdin);
      lexema[i] = 0;
      return HEX;
    }

    return c;
  }
}

int main() {
  if(!yyparse()) printf("\ncadena valida\n");
  else printf("cadena invalida\n");
  return 0;
}