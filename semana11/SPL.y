%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
char lexema[60];
void yyerror(char *msg);
int yylex();

typedef struct {
  char nombre[60];
  double valor;
  int token;
  int tokenaux;
} tipoTS;
tipoTS TablaSim[100];
int nSim = 0;

typedef struct {
  int op;
  int a1;
  int a2;
  int a3;
} tipoCodigo;
int cx = -1;
tipoCodigo TCodigo[100];

void generaCodigo(int,int,int,int);
int localizaSimb(char *, int);
void imprimeTablaSim();

int nVarTemp = 0;
int GenVarTemp();
void InterpretaCodigo();

int errorLine = 0;
%}

%token ALGORITMO INICIO FIN INICIOALGORITMO FINALGORITMO NUM ID
%token SI SINO ENTONCES MIENTRAS HACER PARA HASTA
%token ASIGNAR SUMAR RESTAR MULTIPLICAR DIVIDIR PARENTESIS
%token SALTAR1 SALTAR2 SALTAR_FOR BUCLE_WHILE BUCLE_FOR
%token MAYOR MENOR IGUAL DESIGUAL MAYOR_IGUAL MENOR_IGUAL

%%
programa: ALGORITMO ID INICIOALGORITMO listaInstruccion FINALGORITMO;
listaInstruccion: instruccion listaInstruccion
                |  ;

instruccion: SI cond {generaCodigo(SALTAR1,$2,'?','-');$$=cx;} INICIO bloque {generaCodigo(SALTAR2,$2,'?','-');$$=cx;}{TCodigo[$3].a2=cx+1;} otro {TCodigo[$6].a2=cx+1;} FIN;
otro: SINO INICIO bloque
    |  ;
instruccion: MIENTRAS cond {generaCodigo(SALTAR1,$2,'?','-');$$=cx;} HACER INICIO bloque {generaCodigo(BUCLE_WHILE,$3,'-','-');}{TCodigo[$3].a2=cx+1;} FIN;
instruccion: PARA ID {$$=localizaSimb(lexema,ID);} HASTA expr {generaCodigo(SALTAR_FOR,$3,$5,'?');$$=cx;} INICIO bloque {generaCodigo(BUCLE_FOR,$3,$6,'-');}{TCodigo[$6].a3=cx+1;} FIN;
bloque: listaInstruccion FIN
      | instruccion;
instruccion: ID{$$=localizaSimb(lexema,ID);} '=' expr{generaCodigo(ASIGNAR,$2,$4,'-');}';';

expr: expr '+' term{int i = GenVarTemp(); generaCodigo(SUMAR,i,$1,$3); $$=i;};
expr: expr '-' term{int i = GenVarTemp(); generaCodigo(RESTAR,i,$1,$3); $$=i;};
expr: term;
term: term '*' term2{int i = GenVarTemp(); generaCodigo(MULTIPLICAR,i,$1,$3); $$=i;};
term: term '/' term2{int i = GenVarTemp(); generaCodigo(DIVIDIR,i,$1,$3); $$=i;};
term: term2;
term2: '(' expr ')'{int i = GenVarTemp(); generaCodigo(PARENTESIS,i,$2,$2); $$=i;};
term2: NUM{$$=localizaSimb(lexema,NUM);}
     | ID{$$=localizaSimb(lexema,ID);};

cond: expr '=' '=' expr {int i = GenVarTemp(); generaCodigo(IGUAL,i,$1,$4); $$=i;};
cond: expr '<' '>' expr {int i = GenVarTemp(); generaCodigo(DESIGUAL,i,$1,$4); $$=i;};
cond: cond2;
cond2: expr '<' expr {int i = GenVarTemp(); generaCodigo(MENOR,i,$1,$3); $$=i;};
cond2: expr '<' '=' expr {int i = GenVarTemp(); generaCodigo(MENOR_IGUAL,i,$1,$4); $$=i;};
cond2: expr '>' expr {int i = GenVarTemp(); generaCodigo(MAYOR,i,$1,$3); $$=i;};
cond2: expr '>' '=' expr {int i = GenVarTemp(); generaCodigo(MAYOR_IGUAL,i,$1,$4); $$=i;};
%%

void InterpretaCodigo(){
  int i,a1,a2,a3,op,j,temp;
  for(i=0; i<=cx; i++){
    op = TCodigo[i].op;
    a1 = TCodigo[i].a1;
    a2 = TCodigo[i].a2;
    a3 = TCodigo[i].a3;

    if(op==MAYOR){
      TablaSim[a1].tokenaux=MAYOR;
      if(TablaSim[a2].valor>TablaSim[a3].valor) TablaSim[a1].valor=1;
      else TablaSim[a1].valor=0;
    }
    if(op==MENOR){
      TablaSim[a1].tokenaux=MENOR;
      if(TablaSim[a2].valor<TablaSim[a3].valor) TablaSim[a1].valor=1;
      else TablaSim[a1].valor=0;
    }
    if(op==MAYOR_IGUAL){
      TablaSim[a1].tokenaux=MAYOR_IGUAL;
      if(TablaSim[a2].valor>=TablaSim[a3].valor) TablaSim[a1].valor=1;
      else TablaSim[a1].valor=0;
    }
    if(op==MENOR_IGUAL){
      TablaSim[a1].tokenaux=MENOR_IGUAL;
      if(TablaSim[a2].valor<=TablaSim[a3].valor) TablaSim[a1].valor=1;
      else TablaSim[a1].valor=0;
    }
    if(op==IGUAL){
      TablaSim[a1].tokenaux=IGUAL;
      if(TablaSim[a2].valor==TablaSim[a3].valor) TablaSim[a1].valor=1;
      else TablaSim[a1].valor=0;
    }
    if(op==DESIGUAL){
      TablaSim[a1].tokenaux=DESIGUAL;
      if(TablaSim[a2].valor!=TablaSim[a3].valor) TablaSim[a1].valor=1;
      else TablaSim[a1].valor=0;
    }
    if(op==SUMAR) TablaSim[a1].valor = TablaSim[a2].valor + TablaSim[a3].valor;
    if(op==RESTAR) TablaSim[a1].valor = TablaSim[a2].valor - TablaSim[a3].valor;
    if(op==MULTIPLICAR) TablaSim[a1].valor = TablaSim[a2].valor * TablaSim[a3].valor;
    if(op==DIVIDIR) TablaSim[a1].valor = TablaSim[a2].valor / TablaSim[a3].valor;
    if(op==PARENTESIS) TablaSim[a1].valor = TablaSim[a2].valor;
    if(op==ASIGNAR) TablaSim[a1].valor = TablaSim[a2].valor;
    if(op==SALTAR1){
      if(TablaSim[a1].valor==0) i=a2-1;
    }
    if(op==SALTAR2){
      if(TablaSim[a1].valor==1) i=a2-1;
    }
    if(op==BUCLE_WHILE) i=a1-2;
    if(op==SALTAR_FOR){
      if(TablaSim[a1].valor >= TablaSim[a2].valor) i=a3-1;
    }
    if(op==BUCLE_FOR){
      TablaSim[a1].valor += 1;
      i=a2-1;
    }
  }
}

int GenVarTemp(){
  char t[60];
  sprintf(t,"_T%d",nVarTemp++);
  return localizaSimb(t,ID);
}

void generaCodigo(int op, int a1, int a2, int a3){
  cx++;
  TCodigo[cx].op = op;
  TCodigo[cx].a1 = a1;
  TCodigo[cx].a2 = a2;
  TCodigo[cx].a3 = a3;
}

int localizaSimb(char *nom, int tok){
  int i;
  for(i=0; i<nSim; i++){
    if(!strcasecmp(TablaSim[i].nombre,nom))
      return i;
  }
  strcpy(TablaSim[nSim].nombre,nom);
  TablaSim[nSim].token = tok;
  if(tok==ID) TablaSim[nSim].valor = 0.0;
  if(tok==NUM) sscanf(nom,"%lf",&TablaSim[nSim].valor);
  nSim++;
  return nSim - 1;
}

void imprimeTablaSim(){
  int i;
  for(i=0; i<nSim; i++){
    // if(TablaSim[i].tokenaux==DESIGUAL){
    //   if(TablaSim[i].valor==1.0)
    //     printf("%d nombre = %s tok = %d valor = verdadero\n",i,TablaSim[i].nombre,TablaSim[i].token);
    //   else
    //     printf("%d nombre = %s tok = %d valor = falso\n",i,TablaSim[i].nombre,TablaSim[i].token);
    // }
    // if(TablaSim[i].tokenaux==IGUAL){
    //   if(TablaSim[i].valor==1.0)
    //     printf("%d nombre = %s tok = %d valor = verdadero\n",i,TablaSim[i].nombre,TablaSim[i].token);
    //   else
    //     printf("%d nombre = %s tok = %d valor = falso\n",i,TablaSim[i].nombre,TablaSim[i].token);
    // }
    // if(TablaSim[i].tokenaux==MAYOR){
    //   if(TablaSim[i].valor==1.0)
    //     printf("%d nombre = %s tok = %d valor = verdadero\n",i,TablaSim[i].nombre,TablaSim[i].token);
    //   else
    //     printf("%d nombre = %s tok = %d valor = falso\n",i,TablaSim[i].nombre,TablaSim[i].token);
    // }
    // if(TablaSim[i].tokenaux==MENOR){
    //   if(TablaSim[i].valor==1.0)
    //     printf("%d nombre = %s tok = %d valor = verdadero\n",i,TablaSim[i].nombre,TablaSim[i].token);
    //   else
    //     printf("%d nombre = %s tok = %d valor = falso\n",i,TablaSim[i].nombre,TablaSim[i].token);
    // }
    // if(TablaSim[i].tokenaux==MAYOR_IGUAL){
    //   if(TablaSim[i].valor==1.0)
    //     printf("%d nombre = %s tok = %d valor = verdadero\n",i,TablaSim[i].nombre,TablaSim[i].token);
    //   else
    //     printf("%d nombre = %s tok = %d valor = falso\n",i,TablaSim[i].nombre,TablaSim[i].token);
    // }
    // if(TablaSim[i].tokenaux==MENOR_IGUAL){
    //   if(TablaSim[i].valor==1.0)
    //     printf("%d nombre = %s tok = %d valor = verdadero\n",i,TablaSim[i].nombre,TablaSim[i].token);
    //   else
    //     printf("%d nombre = %s tok = %d valor = falso\n",i,TablaSim[i].nombre,TablaSim[i].token);
    // }
    printf("%4d nombre = %6s tok = %6d valor = %4.3lf\n",i,TablaSim[i].nombre,TablaSim[i].token,TablaSim[i].valor);
  }
}

void imprimeTablaCod(){
  int i;
  for(i=0; i<=cx; i++){
    printf("%4d op=%5d  a1=%4d a2=%4d a3=%4d\n",i,TCodigo[i].op,TCodigo[i].a1,TCodigo[i].a2,TCodigo[i].a3);
  }
}

void yyerror(char *msg){
  printf("Syntax Error: %s on line %i \n", msg, errorLine);
}

int EsPalabraReservada(char lexema[]){
  //strcmp considera mayusculas y minusculas
  //strcasecmp ignora mayusculas de minusculas
  if(strcasecmp(lexema,"Algoritmo")==0) return ALGORITMO;
  if(strcasecmp(lexema,"inicioAlgoritmo")==0) return INICIOALGORITMO;
  if(strcasecmp(lexema,"finAlgoritmo")==0) return FINALGORITMO;
  if(strcasecmp(lexema,"finSi")==0 || strcasecmp(lexema,"finPara")==0 || strcasecmp(lexema,"finMientras")==0 || strcasecmp(lexema,"fin")==0) return FIN;
  if(strcasecmp(lexema,"inicio")==0) return INICIO;
  if(strcasecmp(lexema,"si")==0) return SI;
  if(strcasecmp(lexema,"sino")==0) return SINO;
  if(strcasecmp(lexema,"entonces")==0) return ENTONCES;
  if(strcasecmp(lexema,"mientras")==0) return MIENTRAS;
  if(strcasecmp(lexema,"hacer")==0) return HACER;
  if(strcasecmp(lexema,"para")==0) return PARA;
  if(strcasecmp(lexema,"hasta")==0) return HASTA; 
  
  return ID;
}

int yylex(){
  char c; int i;
  while(1){
    c = getchar();
    if(c == ' ') continue;
    if(c == '\t') continue;
    if(c == '\n'){
      errorLine += 1;
      continue;
    }

    if(isdigit(c)){
      i = 0;
      do{
        lexema[i++] = c;
        c = getchar();
      }while(isdigit(c));
      ungetc(c, stdin);
      lexema[i] = '\0';
      return NUM;
    }

    if(isalpha(c)){
      i = 0;
      do{
        lexema[i++] = c;
        c = getchar();
      }while(isalnum(c));
      ungetc(c, stdin);
      lexema[i] = '\0';
      return EsPalabraReservada(lexema);
    }

    return c;
  }
}

int main(){
  /*if(!yyparse()) printf("La cadena es VALIDA\n");
  else printf("La cadena es INVALIDA\n");*/
  yyparse();
  printf("Tabla de Simbolos:\n"); imprimeTablaSim();
  printf("Tabla de Codigos\n"); imprimeTablaCod();
  printf("--------------------------------\n");
  InterpretaCodigo();
  printf("--------------------------------\n");
  printf("Tabla de Simbolos despues de interpretar\n"); imprimeTablaSim();
  return 0;
}