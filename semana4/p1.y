%{
  #include<stdio.h>
  #include<string.h>
  char lexema[255];
  void yyerror(char *);
%}

// Especificamos los tokens
%token CORREO

// Especificamos la gramatica
%%
instruccion: CORREO;
instruccion: ;
%%

void yyerror(char *msg) {
  printf("error: %s", msg);
}

// Especificamos las reglas de los tokens
int yylex() {
  char c;
  while(1) {
    c = getchar();
    if(c == '\n') continue;
    if(c == ' ') continue;
    
    // Token CORREO
    if(isalpha(c)) {
      int i = 0;
      do {
        lexema[i++] = c;
        c = getchar();
      } while(isalpha(c));
      char dominio[] = "@uni.edu.pe";
      int j = 0;

      if(c == dominio[j]) {
        do {
          lexema[i++] = c;
          c = getchar();
          j++;
        } while(c == dominio[j] && j < 11);
        if (j == 11) {
          ungetc(c, stdin);
          lexema[i] == 0;
          return CORREO;
        }
      }
    }
    return c;
  }
}

int main() {
  if(!yyparse()) printf("cadena valida\n");
  else printf("cadena invalida\n");
  return 0;
}