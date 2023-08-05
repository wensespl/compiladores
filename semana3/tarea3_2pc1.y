%{
  #include<stdio.h>
  #include<string.h>
  char lexema[255];
  void yyerror(char *);
%}

// Especificamos los tokens
%token NUMDEC

// Especificamos las reglas
%%
instruccion: instruccion NUMDEC;
instruccion: ;
%%

void yyerror(char *msg) {
  printf("error: %s", msg);
}

int yylex() {
  char c;
  while(1){
    c = getchar();
    if(c == '\n') continue;
    if(c == ' ') continue;
    // Verificamos que inicie con un digito o '-'
    if(isdigit(c) || c == '-') {
      int i = 0;
      do {
        lexema[i++] = c;
        c = getchar();
      } while(isdigit(c)); // Verificamos que los siguientes
                          // sean digitos
      // Verficamos que despues siga un '.'
      if (c == '.') {
        lexema[i++] = c;
        c = getchar();
        // Verificamos que despues del '.' continue un digito
        if(isdigit(c)) {
          do {
            lexema[i++] = c;
            c = getchar();
          } while(isdigit(c)); // Verificamos que los siguientes
                              // sean digitos
          ungetc(c, stdin);
          lexema[i] == 0;
          return NUMDEC; // Retornamos token numero decimal
        }
      }
      ungetc(c, stdin);
      lexema[i] == 0;
    }
    // Sino salimos porque la cadena es invalida
    return c;
  }
}

int main() {
  if(!yyparse()) printf("cadena valida\n");
  else printf("cadena invalida\n");
  return 0;
}