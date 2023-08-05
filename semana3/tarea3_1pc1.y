%{
  #include<stdio.h>
  #include<string.h>
  char lexema[255];
  void yyerror(char *);
%}

// Especificamos los tokens
%token NUMNAT

// Especificamos las reglas
%%
instruccion: instruccion NUMNAT;
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
    // Verificamos que la cadena inicie con un numero
    if(isdigit(c)) {
      int i = 0;
      do {
        lexema[i++] = c;
        c = getchar();
      } while(isdigit(c)); // Verificamos que los demas
                          // carecteres siguientes sean numeros
      ungetc(c, stdin);
      lexema[i] == 0;
      return NUMNAT; // Retornamos el token numero natural
    }
    // Sino salimos, cadena invalida
    return c;
  }
}

int main() {
  if(!yyparse()) printf("cadena valida\n");
  else printf("cadena invalida\n");
  return 0;
}