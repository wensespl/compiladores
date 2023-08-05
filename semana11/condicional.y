%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
char lexema[60];
void yyerror(char *);
int yylex();
typedef struct{
	char nombre[60];
	double valor;
	int token;
}tipoTS;
tipoTS TablaSim[100];
int nSim=0;//fila de la tabla de símbolo
typedef struct{
	int op;
	int a1;
	int a2;
	int a3;
}tipoCodigo;
tipoCodigo TCodigo[100];
int cx=-1; //fila de la tabla de tabla de código
void generaCodigo(int,int,int,int);//llena la tabla de código
int localizaSimb(char *,int);//llena la tabla de símbolos
void imprimeTablaSim();
void imprimeTablaCod();
int GenVarTemp();//genera variables temporales
int nVarTemp=0;
void interpretaCodigo();//recorre la tabla de código para actualizar la tabla de símbolos
int esPalabraReservada(char lexema[]);
%}

%token PROGRAMA ID INICIO FIN NUM ASIGNAR SUMAR SI ENTONCES MAYOR SALTARF
/*
Program MiProg;
Begin
	x:=5;
	y:=6;
	if y>x then
		Begin
			a:=2;
			b:=3;
		End
	z:=6;
End.
*/
%%
S: PROGRAMA ID ';' INICIO listaInstr FIN '.';
listaInstr: instr listaInstr| ;
instr: SI cond {generaCodigo(SALTARF,$2,'?','-');$$=cx;} ENTONCES bloque{TCodigo[$3].a2=cx+1;};
bloque: INICIO listaInstr FIN|instr;
instr: ID {$$=localizaSimb(lexema,ID);}':''=' expr{generaCodigo(ASIGNAR,$2,$5,'-');} ';';
cond: expr'>'expr  {int i=GenVarTemp(); generaCodigo(MAYOR,i,$1,$3);$$=i;}; 
expr:expr '+' term {int i=GenVarTemp(); generaCodigo(SUMAR,i,$1,$3);$$=i;};
expr:term;
term:NUM {$$=localizaSimb(lexema,NUM);}|ID{$$=localizaSimb(lexema,ID);};
%%

int GenVarTemp(){
	char t[20];
	sprintf(t,"_T%d",nVarTemp++);
	return localizaSimb(t,ID);
}

void generaCodigo(int op,int a1,int a2, int a3){
	cx++;
	TCodigo[cx].op=op;
	TCodigo[cx].a1=a1;
	TCodigo[cx].a2=a2;
	TCodigo[cx].a3=a3;
}

int localizaSimb(char *nom, int tok){
	int i;
	for(i=0;i<nSim;i++){
		if(!strcasecmp(TablaSim[i].nombre,nom))
			return i;	
	}
	strcpy(TablaSim[nSim].nombre,nom);
	TablaSim[nSim].token=tok;
	if(tok=ID) TablaSim[nSim].valor=0.0;
	if(tok=NUM) sscanf(nom,"%lf",&TablaSim[nSim].valor);
	nSim++;
	return nSim-1;
}

void imprimeTablaSim(){
	int i;
	for(i=0;i<nSim;i++)
	printf("%d nombre=%s tok=%d valor=%lf\n",i,TablaSim[i].nombre,TablaSim[i].token, TablaSim[i].valor);
}
void imprimeTablaCod(){
	int i;
	for(i=0;i<=cx;i++)
	printf("%d op=%d a1=%d a2=%d a3=%d\n",i,TCodigo[i].op, TCodigo[i].a1,TCodigo[i].a2, TCodigo[i].a3);
}

void interpretaCodigo(){
	int i,a1,a2,a3,op;
	for(i=0;i<=cx;i++){
		op=TCodigo[i].op;
		a1=TCodigo[i].a1;
		a2=TCodigo[i].a2;
		a3=TCodigo[i].a3;
		if(op==ASIGNAR)
			TablaSim[a1].valor=TablaSim[a2].valor;
		if(op==SUMAR)
			TablaSim[a1].valor=TablaSim[a2].valor+TablaSim[a3].valor;
		if(op==MAYOR)
			if(TablaSim[a2].valor>TablaSim[a3].valor)
				TablaSim[a1].valor=1;
			else 
				TablaSim[a1].valor=0;
		if(op==SALTARF)
			if(TablaSim[a1].valor==0)
				i=a2-1;
	}
}
void yyerror(char *msg){
	printf("Error: %s\n",msg);
}

int esPalabraReservada(char lexema[]){
	if(strcasecmp(lexema,"Program")==0) return PROGRAMA;
	if(strcasecmp(lexema,"Begin")==0) return INICIO;
	if(strcasecmp(lexema,"End")==0) return FIN;
	if(strcasecmp(lexema,"if")==0) return SI;
	if(strcasecmp(lexema,"then")==0) return ENTONCES;
	return ID;
}
int yylex(){
	char c;
	int i;
	while(1){
		c=getchar();
		if(c==' ') continue;
		if(c=='\t')continue;
		if(c=='\n')continue;
		if(isdigit(c)){
			i=0;
			do{
				lexema[i++]=c;
				c=getchar();
			}while(isdigit(c));
			ungetc(c,stdin);
			lexema[i]='\0';
			return NUM;
		}
		if(isalpha(c)){
			i=0;
			do{
				lexema[i++]=c;
				c=getchar();
			}while(isalnum(c));
			ungetc(c,stdin);
			lexema[i]='\0';
			return esPalabraReservada(lexema);
		}
		return c;

	}

}
int main(){
	if(!yyparse()) printf("Cadena válida\n");
	else printf("Cadena inválida\n");
	printf("Tabla de símbolos\n");
	imprimeTablaSim();
	printf("Tabla de códigos\n");
	imprimeTablaCod();
	printf("Interpreta código\n");
	interpretaCodigo();
	imprimeTablaSim();
}
