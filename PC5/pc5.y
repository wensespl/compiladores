%{
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
char lexema[60];
void yyerror(char *msg);

typedef struct {
	char nombre[60];
	double valor;
	int token;
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
void generaCodigo(int, int, int, int);

int localizaSimb(char *, int);
void imprimeTablaSim();

void imprimeTablaCod();
int nVarTemp = 0;
int GenVarTemp();

void interpretaCodigo();

int yylex();
int EsPalabraReservada(char[], int);
%}

%token ALGORITMO ID INICIOALGORITMO FINALGORITMO NUM
%token ASIGNAR SUMAR RESTAR MULTIPLICAR DIVIDIR PARENTESIS
%token SI SINO ENTONCES FINSI SALTARF1 SALTARF2
%token MAYOR MENOR MAYOR_IGUAL MENOR_IGUAL

%%
S: ALGORITMO ID INICIOALGORITMO listaAsig ';' listaInstr FINALGORITMO '.';
listaAsig: asig
         | asig ',' listaAsig;
asig: ID {$$ = localizaSimb(lexema, ID);} '=' NUM {$$ = localizaSimb(lexema, NUM);} {generaCodigo(ASIGNAR, $2, $5, '-');};
listaInstr: instr
					| instr listaInstr;
instr: instr_asig
     | instr_if
     | instr_if_else;
instr_if: SI cond {
								generaCodigo(SALTARF1, $2, '?', '-');
								$$=cx;
							 } ENTONCES bloque {TCodigo[$3].a2 = cx + 1;} FINSI;
instr_if_else: SI cond {
								generaCodigo(SALTARF1, $2, '?', '-');
								$$=cx;
							 } ENTONCES bloque {TCodigo[$3].a2 = cx + 1;} SINO {
                                                                    generaCodigo(SALTARF2, '?', '-', '-');
                                                                    $$=cx;
                                                                  } bloque {TCodigo[$8].a1 = cx + 1;} FINSI;
bloque: listaInstr
      | instr bloque;
instr_asig: ID {$$ = localizaSimb(lexema, ID);} '=' expr {generaCodigo(ASIGNAR, $2, $4, '-');} ';';
cond: expr '>' expr {
	                  	int i = GenVarTemp();
											generaCodigo(MAYOR, i, $1, $3);
											$$ = i;
										}
    | expr '<' expr {
	                  	int i = GenVarTemp();
											generaCodigo(MENOR, i, $1, $3);
											$$ = i;
										}
    | expr '>' '=' expr {
	                  	int i = GenVarTemp();
											generaCodigo(MAYOR_IGUAL, i, $1, $4);
											$$ = i;
										}
    | expr '<' '=' expr {
	                  	int i = GenVarTemp();
											generaCodigo(MENOR_IGUAL, i, $1, $4);
											$$ = i;
										};
expr: expr '+' term {
											int i = GenVarTemp(); 
											generaCodigo(SUMAR, i, $1, $3); 
											$$ = i;
										}
    | expr '-' term {
											int i = GenVarTemp();
											generaCodigo(RESTAR, i, $1, $3); 
											$$ = i;
										}
    | term;
term: term '*' term2 {
											int i = GenVarTemp(); 
											generaCodigo(MULTIPLICAR, i, $1, $3); 
											$$ = i;
										 }
    | term '/' term2 {
											int i = GenVarTemp(); 
											generaCodigo(DIVIDIR, i, $1, $3); 
											$$ = i;
										 }
		| term2;
term2: '(' expr ')' {
											int i = GenVarTemp(); 
											generaCodigo(PARENTESIS, i, $2, '-'); 
											$$ = i;
										}
		 | NUM {$$ = localizaSimb(lexema, NUM);}
		 | ID {$$ = localizaSimb(lexema, ID);};
%%

int GenVarTemp(){
	char t[60];
	sprintf(t, "_T%d", nVarTemp++);
	return localizaSimb(t, ID);
}

void generaCodigo(int op, int a1, int a2, int a3){
	cx++;	
	TCodigo[cx].op = op;
	TCodigo[cx].a1 = a1;
	TCodigo[cx].a2 = a2;
	TCodigo[cx].a3 = a3;
}

int localizaSimb(char *nom, int tok) {
	int i;
	for(i = 0; i < nSim; i++) {
		if(!strcasecmp(TablaSim[i].nombre, nom)) 
			return i;
	}
	strcpy(TablaSim[nSim].nombre, nom);
	TablaSim[nSim].token = tok;
	if(tok == ID) TablaSim[nSim].valor = 0.0;
	if(tok == NUM) sscanf(nom, "%lf", &TablaSim[nSim].valor);
	nSim++;
	return nSim - 1;
}

void imprimeTablaSim(){
	int i;
	for(i = 0; i < nSim; i++){
		printf("%d  nombre=%s tok=%d valor=%lf\n", i, TablaSim[i].nombre, TablaSim[i].token, TablaSim[i].valor);
	}
}

void imprimeTablaCod(){
	int i;
	for(i = 0; i <= cx; i++){
		printf("%d  a1=%d a2=%d a3=%d\n", TCodigo[i].op, TCodigo[i].a1, TCodigo[i].a2, TCodigo[i].a3);
	}
}

void interpretaCodigo(){
	int i, a1, a2, a3, op;
	for(i = 0; i <= cx; i++){
		op = TCodigo[i].op;
		a1 = TCodigo[i].a1;
		a2 = TCodigo[i].a2;
		a3 = TCodigo[i].a3;
		
		if(op == ASIGNAR)
			TablaSim[a1].valor = TablaSim[a2].valor;
		
		if(op == SUMAR)
			TablaSim[a1].valor = TablaSim[a2].valor + TablaSim[a3].valor;
		
		if(op == RESTAR)
			TablaSim[a1].valor = TablaSim[a2].valor - TablaSim[a3].valor;
		
		if(op == MULTIPLICAR)
			TablaSim[a1].valor = TablaSim[a2].valor * TablaSim[a3].valor;
		
		if(op == DIVIDIR)
			TablaSim[a1].valor = TablaSim[a2].valor / TablaSim[a3].valor;

		if(op == PARENTESIS)
			TablaSim[a1].valor = TablaSim[a2].valor;
		
		if(op == MAYOR)
			if(TablaSim[a2].valor > TablaSim[a3].valor)
				TablaSim[a1].valor = 1;
			else
				TablaSim[a1].valor = 0;
    
    if(op == MENOR)
			if(TablaSim[a2].valor < TablaSim[a3].valor)
				TablaSim[a1].valor = 1;
			else
				TablaSim[a1].valor = 0;
    
    if(op == MAYOR_IGUAL)
			if(TablaSim[a2].valor >= TablaSim[a3].valor)
				TablaSim[a1].valor = 1;
			else
				TablaSim[a1].valor = 0;
    
    if(op == MENOR_IGUAL)
			if(TablaSim[a2].valor <= TablaSim[a3].valor)
				TablaSim[a1].valor = 1;
			else
				TablaSim[a1].valor = 0;
		
		if(op == SALTARF1)
			if(TablaSim[a1].valor == 0)
				i = a2 - 1;
    
    if(op == SALTARF2)
      i = a1 - 1;
	}
}

void yyerror(char *msg){
	printf("ERROR:%s\n",msg);
}

int EsPalabraReservada(char lexema[], int default_token) {
	//strcmp considera may y minusc
	//strcasecmp ignora may de min
	if(strcasecmp(lexema, "Algoritmo") == 0) return ALGORITMO;
	if(strcasecmp(lexema, "inicioAlgoritmo") == 0) return INICIOALGORITMO;
	if(strcasecmp(lexema, "finAlgoritmo") == 0) return FINALGORITMO;
	if(strcasecmp(lexema, "si") == 0) return SI;
  if(strcasecmp(lexema, "finsi") == 0) return FINSI;
  if(strcasecmp(lexema, "sino") == 0) return SINO;
	if(strcasecmp(lexema, "entonces") == 0) return ENTONCES;
	
	return default_token;
}

int yylex(){
	char c;
	int i;
	while(1){
		c = getchar();

		if(c == ' ') continue;
		if(c == '\t') continue;
		if(c == '\n') continue;
	     
		if(isdigit(c)) {
			i = 0;
			do{
	    	lexema[i++] = c;
				c = getchar();	
   	  } while(isdigit(c));
		  ungetc(c, stdin);
		  lexema[i] = '\0';
		  return NUM;
	  }
	  
		if(isalpha(c)){
	    i = 0;
	  	do{
	    	lexema[i++] = c;
				c = getchar();			
   	  } while(isalnum(c));
		 ungetc(c, stdin);
		 lexema[i] = '\0';
		 return EsPalabraReservada(lexema, ID);	
	  }

	  return c; 
	}
}

int main(){
	if(!yyparse()) printf("La cadena es valida\n");
	else printf("La cadena es invalida\n");
	printf("tabla de simbolos\n");
	imprimeTablaSim();
	printf("tabla de codigos\n");
	imprimeTablaCod();
	printf("Interpreta codigo\n");
	interpretaCodigo();
	imprimeTablaSim();
	return 0;
}
