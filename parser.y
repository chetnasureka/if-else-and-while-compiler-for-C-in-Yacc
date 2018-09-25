%{
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>
#include "lex.yy.c"

char nL[3];

void yyerror(const char*);
int yylex();
int yywrap();
void insert_type();
void add(char);
int sym_search(char *);
int search(char *);
void addTo(char i,char *n);
void FOO();
void add_ptr();
void pop();
void insert_type_table();
char temptype(char *,char*);
void type_check(char *,char*);
void printtree(struct node1*);
void optimized();
struct node{ int val;} x;
struct dataType{
	char * id_name;
	char * data_type;
	char * type;
	int line_no;
	}symbolTable[100];
int ifd=0;//Label
int eld=20;
char typeStack[10][100];
int typeStack_top = 0;
char type[10];
char count=0;
int nxt=1;//printed next once
int c=0;//Temp var count
int q;
extern int countn;
struct intermediate
{
	char op[2];
	char op1[5];
	char op2[5];
	char res[5];
}intermediate_code[20];
int code=0;
struct node1{ struct node1*left;struct node1*right;char* token;};
struct node1* mknode(struct node1 *left,struct node1 *right, char *token);

%}
%union { struct var_name {char name[100];struct node1* nd;} nam ; 
	struct gen_code{char tr[10];char fal[10];struct node1* nd;} gen;
	 } 
%token <nam> IF ELSE INT FLOAT CHAR WHILE
%token VOID INCLUDE RETURN 
%token <nam> LE GE LT GT EQ NE NUM AND OR TR FL STRLT ID printff scanff
%type <gen> B C
%type <nam> relop Q T F E assign Arg P I M R TER N G U S EL S1 S2
%start P
%left '+' '-' '*' '/'
%right '=' '^'


%%


P : I M ID {insert_type_table();} '('{add('t');} R ')'{add('t');} '{'{add('t');} S { printf("Label next:\n");}  U '}'{$$.nd = mknode(NULL,$12.nd,"start");printf("\n\n-----------------------------------------------------------------------------------\n");printf("\n\t\t\tSyntax Tree in Inorder traversal\n-----------------------------------------------------------------------------------\n");
printtree($$.nd);
printf("\n\n");
add('t');
optimized();};
I : I I | INCLUDE {add('H');} ;
M : INT{insert_type();} | FLOAT{insert_type();}| CHAR{insert_type();} | VOID{insert_type();} ;
R : R ','{add('t');} R | M N TER | N TER;

TER : ';'{add('t');} | ;
N : ID{insert_type_table();} G | '*'{add_ptr();} N ; 
G : '['{add('t');} NUM {add('n');}']' G |  '['ID ']' G | '['{add('t');} ']' G |  ;

U : RETURN NUM {add('n');} ';'{add('t');printf("Return\t%s\n",$2.name);} | RETURN ID ';' {add('t');printf("Return\t%s\n",$2.name);}| ;

S:	S1
	|S2
	|assign {$$.nd=$1.nd;}
	|M ID TER {$$.nd=mknode(NULL,NULL,"definition"); int i=sym_search($2.name);if(i!=-1)
	{if(strcmp($1.name,"int")==0){addTo('i',$2.name);}
	else if(strcmp($1.name,"float")==0)addTo('f',$2.name);
	else addTo('c',$2.name);}
	else{printf("Variable already defined, error at line no: %d\n",yylineno);exit(0);}}
	|S S {$$.nd=mknode($1.nd,$2.nd,"statement");strcpy($$.name,"STATEMENT");}
	|printff  {add('f');} '(' STRLT ')'';' {$$.nd = mknode(NULL,NULL,"printf");}
	|scanff {add('f');}'('STRLT ',''&'ID')' ';'{$$.nd = mknode(NULL,NULL,"scanf");}
	|{$$.nd=mknode(NULL,NULL,"EPSILON");};



S1 :	IF{add('k');} '(' C ')'{printf("\n Label\t%s:\n",$4.tr);}'{'{addTo('{',"Punctuations");} S '}'{addTo('}',"Punctuations");
	pop();
	printf("goto next\n");
	printf("\nLabel\t%s:\n",$4.fal);} EL {$$.nd=mknode($4.nd,$9.nd,"IF");
	strcpy($$.name,"IF");}
	|assign {$$.nd=$1.nd;}
	|M ID TER {$$.nd=mknode(NULL,NULL,"definition"); int i=sym_search($2.name);if(i!=-1)
	{if(strcmp($1.name,"int")==0){addTo('i',$2.name);}
	else if(strcmp($1.name,"float")==0)addTo('f',$2.name);
	else addTo('c',$2.name);}
	else{printf("Variable already defined, error at line no: %d\n",yylineno);exit(0);}}
	|S S {$$.nd=mknode($1.nd,$2.nd,"statement");strcpy($$.name,"STATEMENT");}
	|printff  {add('f');} '(' STRLT ')'';' {$$.nd = mknode(NULL,NULL,"printf");}
	|scanff {add('f');}'('STRLT ',''&'ID')' ';'{$$.nd = mknode(NULL,NULL,"scanf");}
	|{$$.nd=mknode(NULL,NULL,"EPSILON");};

S2: 
	WHILE{add('k'); sprintf(nL,"L%d",ifd);ifd++;printf("\n Label \t %s : \n",nL);} '(' C ')'{printf("\n Label\t%s:\n",$4.tr);}'{'{addTo('{',"Punctuations");} S '}'{addTo('}',"Punctuations");
	pop();
	printf("goto %s\n",nL);
	printf("\nLabel\t%s:\n",$4.fal);} EL {$$.nd=mknode($4.nd,$9.nd,"WHILE");
	strcpy($$.name,"WHILE");}
	|assign {$$.nd=$1.nd;}
	|M ID TER {$$.nd=mknode(NULL,NULL,"definition"); int i=sym_search($2.name);if(i!=-1)
	{if(strcmp($1.name,"int")==0){addTo('i',$2.name);}
	else if(strcmp($1.name,"float")==0)addTo('f',$2.name);
	else addTo('c',$2.name);}
	else{printf("Variable already defined, error at line no: %d\n",yylineno);exit(0);}}
	|S S {$$.nd=mknode($1.nd,$2.nd,"statement");strcpy($$.name,"STATEMENT");}
	|printff  {add('f');} '(' STRLT ')'';' {$$.nd = mknode(NULL,NULL,"printf");}
	|scanff {add('f');}'('STRLT ',''&'ID')' ';'{$$.nd = mknode(NULL,NULL,"scanf");}
	|{$$.nd=mknode(NULL,NULL,"EPSILON");};
	
EL: ELSE{add('k');} '{'{addTo('{',"Punctuations");} S '}' {$$=$5;addTo('}',"Punctuations");
	pop();
	printf("goto next\n");
	printf("\n");}| {printf("goto next\n");
	printf("\n");};

Arg : STRLT ;

C : C AND B | C OR B | NE B | B{$$.nd=$1.nd;};


B : 	E relop E {$$.nd=mknode($1.nd,$3.nd,$2.name);
   	int i=search($1.name);
   	int j=search($3.name);
   	if(i!=0&&j!=0){
   	printf("if %s %s %s goto L%d else goto L%d\n",$1.name,$2.name,$3.name,ifd,eld);
   sprintf($$.tr,"L%d",ifd);
   sprintf($$.fal,"L%d",eld);ifd++;eld++;}   
   else{printf(" Variable not declared at line no: %d\n", yylineno);exit(0);}}   
   | ID '=' {add('o');} E{int i=search($1.name);
 	int j=search($4.name);
 	if(i!=0&&j!=0)
 	{
 	printf("if %s!=0 goto L%d else goto L%d\n",$1.name,ifd,eld);
 	sprintf($$.tr,"L%d",ifd);
	sprintf($$.fal,"L%d",eld);ifd++;eld++;} 
	else{printf(" Variable not declared at line no: %d\n", yylineno);
	exit(0);}} 
	| FL{printf("if False  goto L%d\n",eld);
	sprintf($$.tr,"L%d",ifd);
	sprintf($$.fal,"L%d",eld);ifd++;eld++;} 
	| TR {printf("if True  goto L%d\n",ifd);
	sprintf($$.tr,"L%d",ifd);
	sprintf($$.fal,"L%d",eld);ifd++;eld++;} 
	| ID {int i=search($1.name);
	if(i!=0)
	{
	printf("if %s!=0  goto L%d else goto L%d\n",$1.name,ifd,eld);
	sprintf($$.tr,"L%d",ifd);
	sprintf($$.fal,"L%d",eld);ifd++;eld++;}    
	else {printf(" Variable not declared at line no: %d\n", yylineno);
	exit(0);} }
	| NUM {add('n');
	printf("if %s!=0  goto L%d else goto L%d\n",$1.name,ifd,eld);
	sprintf($$.tr,"L%d",ifd);
	sprintf($$.fal,"L%d",eld);ifd++;eld++;} ;

assign :  ID '='{add('o');} E ';'{$1.nd = mknode(NULL,NULL,$1.name);
	  $$.nd=mknode($1.nd,$4.nd,"=");
	  strcpy($$.name,"=");add('t');
	  int i=search($1.name);
	  int j=search($4.name);
	  if(i!=0&&j!=0) 
	  {
	  type_check($1.name,$4.name);
	  printf("= \t %s\t %s \n",$4.name,$1.name);
		strcpy(intermediate_code[code].op,"=");
		strcpy(intermediate_code[code].res,$1.name);
		strcpy(intermediate_code[code].op1,$4.name);
		code++;
		} 
	  else {printf("Variable not declared at line no: %d\n", yylineno);
	  exit(0);}} |ID '(' Arg ')' ';'{add('t');};

E :	E '+'{add('o');} E {$$.nd=mknode($1.nd,$4.nd,"+");strcpy($$.name,"+");
	int i=search($1.name);
	int j=search($4.name);
	sprintf($$.name,"t%d",c);c++;
	addTo(temptype($1.name,$4.name),$$.name);
	if(i!=0 && j!=0) {printf("%s\t%s\t%s\t%s\n","+",$1.name,$4.name,$$.name);strcpy(intermediate_code[code].op,"+");
		strcpy(intermediate_code[code].res,$$.name);
		strcpy(intermediate_code[code].op1,$1.name);
		strcpy(intermediate_code[code].op2,$4.name);
		code++;}
	 else {printf(" Variable not declared at line no: %d\n", yylineno);exit(0);}}


	| E '-' {add('o');}E { $$.nd=mknode($1.nd,$4.nd,"-");
	strcpy($$.name,"-");
	int i=search($1.name);
	int j=search($4.name);
	sprintf($$.name,"t%d",c);c++;
	addTo(temptype($1.name,$4.name),$$.name);
	if(i!=0 && j!=0) {printf("%s\t%s\t%s\t%s\n","-",$1.name,$4.name,$$.name); strcpy(intermediate_code[code].op,"-");
		strcpy(intermediate_code[code].res,$$.name);
		strcpy(intermediate_code[code].op1,$1.name);
		strcpy(intermediate_code[code].op2,$4.name);
		code++;} 
	else {printf(" Variable not declared at line no: %d\n", yylineno);exit(0);}}
	| F{$$.nd=$1.nd;};
	
F :	 F '*'{add('o');} F {$$.nd=mknode($1.nd,$4.nd,"*");
	 strcpy($$.name,"*");
	 int i=search($1.name);
	 int j=search($4.name);
	 sprintf($$.name,"t%d",c);c++;
	 addTo(temptype($1.name,$4.name),$$.name);
	 if(i!=0 && j!=0) {printf("%s\t%s\t%s\t%s\n","*",$1.name,$4.name,$$.name);strcpy(intermediate_code[code].op,"*");
		strcpy(intermediate_code[code].res,$$.name);
		strcpy(intermediate_code[code].op1,$1.name);
		strcpy(intermediate_code[code].op2,$4.name);
		code++;}
	 else {printf(" Variable not declared at line no: %d\n", yylineno);exit(0);}}

	| F '/' {add('o');}F {$$.nd=mknode($1.nd,$4.nd,"/");strcpy($$.name,"/"); 
	int i=search($1.name);
	int j=search($4.name);
	sprintf($$.name,"%d",c);
	strcat($$.name,"t");c++;
	addTo(temptype($1.name,$4.name),$$.name);
	if(i!=0 && j!=0) 
	{
	printf("%s\t%s\t%s\t%s\n","/",$1.name,$4.name,$$.name);strcpy(intermediate_code[code].op,"/");
		strcpy(intermediate_code[code].res,$$.name);
		strcpy(intermediate_code[code].op1,$1.name);
		strcpy(intermediate_code[code].op2,$4.name);
		code++;
	}
	 else {printf(" Variable not declared at line no: %d\n", yylineno);
	 exit(0);}}

	| T {$$.nd=$1.nd;};
	
T :	T '^'{add('o');} T {$$.nd=mknode($1.nd,$4.nd,"^");
	strcpy($$.name,"^");
	int i=search($1.name);
	int j=search($4.name);
	sprintf($$.name,"%d",c);
	strcat($$.name,"t");c++;
	addTo(temptype($1.name,$4.name),$$.name);
	if(i!=0 && j!=0) {
	printf("%s\t%s\t%s\t%s\n","^",$1.name,$4.name,$$.name);strcpy(intermediate_code[code].op,"^");
		strcpy(intermediate_code[code].res,$$.name);
		strcpy(intermediate_code[code].op1,$1.name);
		strcpy(intermediate_code[code].op2,$4.name);
		code++;} 
	else {printf(" Variable not declared at line no: %d\n", yylineno);exit(0);}}

	| Q {$$.nd=$1.nd;};
	
Q : '('{add('t');} E ')'{add('t'); $$=$3;} | ID {insert_type_table();} G {$$.nd=mknode(NULL,NULL,$1.name);strcpy($$.name,$1.name);}| NUM{add('n');}{$$.nd=mknode(NULL,NULL,$1.name);
	strcpy($$.name,$1.name);} ;


relop : LE {add('r');} | GE {add('r');}| LT {add('r');} | GT {add('r');}| EQ {add('r');};



%%
int main()
{
	
	extern int yylineno;
	x.val=10;
	printf("\n\n#######################################################################################\n");
	printf("\t\t\tIntermediate code\n");
	printf("#######################################################################################\n");
	yyparse();
	
	printf("\nParsing is Successful\n");	
	printf("\n\n#######################################################################################\n");
	printf("\t\t\tSymbol table\n");
	printf("#######################################################################################\n");	
	printf("\nsymbol \t type  \t identify \t line number\n");
	printf("_______________________________________________________________________________________\n");
	int i=0;
	for(i=0;i<100;i++){
		if(symbolTable[i].id_name!=NULL)
		printf("%s\t%s\t%s\t%d\t\n",symbolTable[i].id_name,symbolTable[i].data_type,symbolTable[i].type,symbolTable[i].line_no);
		
	}
	for(i=0;i<count;i++){
		free(symbolTable[i].id_name);
		free(symbolTable[i].type);
	}
	return 0;
}
void yyerror(const char* s)
{
	printf("Not accepted\n");
	exit(0);
}
//insert the type into symboltable
void insert_type(){

	
	strcpy(type,yytext);
	//printf("hey");
	q=search(type);
	//printf("qval=%d",q);
	if(q==0){
		
		symbolTable[count].id_name=strdup(yytext);
		symbolTable[count].data_type=strdup("N/A");
		symbolTable[count].line_no = countn;
		symbolTable[count].type=strdup("KEYWORD\t");
		count++;
	}
	
	
}

struct node1* mknode(struct node1 *left, struct node1 *right, char *token)
{
	
  struct node1 *newnode = (struct node1 *)malloc(sizeof(struct node1));
  char *newstr = (char *)malloc(strlen(token)+1);
  strcpy(newstr, token);
  newnode->left = left;
  newnode->right = right;
  newnode->token = newstr;
  return(newnode);
}
void pop()
{
	int i;
	//printf("count %d\n",count);
	int temp=count-1;
	for(i=temp;i>=0;i--)
	{
		if(strcmp(symbolTable[i].id_name,"{")!=0)
		{
			//printf("$$\n");
			count=count-1;;
		}
		else
		{
			count=count-1;
			break;
		}
	}	
	

}
//add declaration of data to symboltable
void addTo(char i,char *n)
{
	if(i=='i')
	{
			symbolTable[count].id_name=strdup(n);
			symbolTable[count].data_type="int";
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("variable");
			count++;
	}
	else if(i=='f')
	{
			symbolTable[count].id_name=strdup(n);
			symbolTable[count].data_type="float";
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("variable");
			count++;
	}
	else if(i=='c')
	{
			symbolTable[count].id_name=strdup(n);
			symbolTable[count].data_type="char";
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("variable");
			count++;
	}
	else if(i=='{')
	{
			symbolTable[count].id_name=strdup("{");;
			symbolTable[count].data_type="N/A";
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("punctuation");
			count++;
	}
	else if(i=='}')
	{
			symbolTable[count].id_name=strdup("}");;
			symbolTable[count].data_type="N/A";
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("punctuation");
			count++;
	}


}
char temptype(char* one,char* two)
{
		int y;
	char* onetype;
	char* twotype;
	for(y = 0;y<count;y++)
	{
		if(strcmp(symbolTable[y].id_name,one)==0) onetype=symbolTable[y].data_type;
		if(strcmp(symbolTable[y].id_name,two)==0) twotype=symbolTable[y].data_type;	
	}
	if((strcmp(onetype,"float")==0) || (strcmp(twotype,"float")==0))
		return 'f';
	else
		return 'i';
}
void insert_type_table(){
	
		q=search(yytext);
	
		if(q==0){
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup(type);
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("IDENTIFIER");
			count++;
		}
	
	
}
void type_check(char* one, char* two)
{
	int y;
	char* onetype;
	char* twotype;
	for(y = 0;y<count;y++)
	{
		if(strcmp(symbolTable[y].id_name,one)==0) onetype=symbolTable[y].data_type;
		if(strcmp(symbolTable[y].id_name,two)==0) twotype=symbolTable[y].data_type;	
	}
	if(strcmp(onetype,twotype)>0){ printf("type error at lineno %d\n",yylineno);exit(0);}
}
//ADD the recent parsed string into symboltable
void add(char c)
{
	q=search(yytext);
	if(q==0){
		if(c=='H')
		{
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup(type);
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("Header");
			count++;
		}
		else if(c=='t')
		{	
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("N/A");
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("Punctuation");
			count++;
		}
		else if(c=='o')
		{
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("N/A");
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("Operator");
			count++;
		}
		else if(c=='r')
		{
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("N/A");
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("Rel Op\t");
			count++;
		}
		else if(c=='k')
		{
						
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("N/A");
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("KEYWORD\t");
			//printf("ADDDDDDDDD%s\n",symbolTable[count].id_name);
			count++;
		}
		else if(c=='n')
		{
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("int");
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("NUMBER\t");
			count++;
		}
	else if(c=='f')
		{
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("N/A");
			symbolTable[count].line_no = countn;
			symbolTable[count].type=strdup("FUNCTION\t");
			count++;
		}
	}
}
int  sym_search(char *type)
{
	int i;
	for(i=count -1 ;i>=0&&(strcmp(symbolTable[i].id_name,"{")!=0);i--)
	{
		if(strcmp(symbolTable[i].id_name,type)==0)
		{
			return -1;
			break;
		}
	
	}
	return 0;
}
//Search in the Symbol table whether the parsed String is present in Symbol table already
int  search(char *type)
{
	int i;
	for(i=count -1 ;i>=0;i--)
	{
		if(strcmp(symbolTable[i].id_name,type)==0)
		{
			return -1;
			break;
		}
	
	}
	return 0;
}
void add_ptr(){
	strcat(type,"*");
}
//print the abstract syntax tree
void printtree(struct node1* tree)
{
  int i;

  
 
  if (tree->left)
	{

		printtree(tree->left);
	}
 printf(" %s , ", tree->token);
  if (tree->right)
	{
   
		printtree(tree->right);
	}
 
}
void optimized()
{

int i;
int j;
int n,m;
int k;
char yay[10];
int len;
int rem;
for (i=0;i<code;i++)// Common Subexpression Elimination
    for(j=i+1;j<code;j++)
        if(strcmp(intermediate_code[i].op,intermediate_code[j].op)==0)
            {
            if(strcmp(intermediate_code[i].op1,intermediate_code[j].op1)==0)
                if(strcmp(intermediate_code[i].op2,intermediate_code[j].op2)==0 && strcmp(intermediate_code[i].op1,intermediate_code[i].res)!=0 && strcmp(intermediate_code[i].op2,intermediate_code[i].res)!=0 )
                    {
                        for(k=i+1;k<j;k++)
			if(strcmp(intermediate_code[j].op1,intermediate_code[k].res)==0 ||strcmp(intermediate_code[j].op2,intermediate_code[k].res)==0)
			break;
			if(k==j)
			{
                        strcpy(intermediate_code[j].op,"=");
                        strcpy(intermediate_code[j].op1,intermediate_code[i].res);
                        strcpy(intermediate_code[j].op2,"");
                        }
                    }
        
           if(strcmp(intermediate_code[i].op1,intermediate_code[j].op2)==0 && strcmp(intermediate_code[i].op2,intermediate_code[j].op1)==0    &&(strcmp(intermediate_code[i].op,"+")==0 || strcmp(intermediate_code[i].op,"*")==0))
                    {
                     for(k=i+1;k<j;k++)
			if(strcmp(intermediate_code[j].op1,intermediate_code[k].res)==0 ||strcmp(intermediate_code[j].op2,intermediate_code[k].res)==0)
			break;
			if(k==j)
			{
                        strcpy(intermediate_code[j].op,"=");
                        strcpy(intermediate_code[j].op1,intermediate_code[i].res);
                        strcpy(intermediate_code[j].op2,"");
			}
                    }
            }

//constant Folding
for(i=0;i<code;i++)
    {
        n=strlen(intermediate_code[i].op1);
        m=strlen(intermediate_code[i].op2);
        for(k=0;k<n;k++)
            if(isdigit(intermediate_code[i].op1[k])==0)
                break;
        for(j=0;j<m;j++)
            if(isdigit(intermediate_code[i].op1[j])==0)
                break;
            if(j==m && k==n)
            {
                j=atoi(intermediate_code[i].op1);
                k=atoi(intermediate_code[i].op2);
                if(strcmp(intermediate_code[i].op,"*")==0)
                {
                    m=j*k;
                }
                else if(strcmp(intermediate_code[i].op,"+")==0)
                {
                    m=j+k;
                }
                else if(strcmp(intermediate_code[i].op,"-")==0)
                {
                    m=j-k;
                }
                else if(strcmp(intermediate_code[i].op,"/")==0)
                {
                    m=j/k;
                }
               /* j = m;
                while (j != 0)
                {
                    len++;
                    j /= 10;
                }
                for (i = 0; i < len; i++)
                {
                    rem = j % 10;
                    j = j / 10;
                    yay[len - (i + 1)] = rem + '0';
                }
                yay[len] = '\0';*/
                strcpy(intermediate_code[i].op,"=");
		sprintf(intermediate_code[i].op1,"%d",m);
                //strcpy(intermediate_code[i].op1,yay);
                strcpy(intermediate_code[i].op2,"");
                
            }
    }
            

    printf("\n\n_______________________________________________________________________________________\n");
    printf("Optimized  code\n");
printf("_______________________________________________________________________________________\n");

for (i=0;i<code;i++)
    printf("%s\t%s\t%s\t%s\n",intermediate_code[i].op,intermediate_code[i].op1,intermediate_code[i].op2,intermediate_code[i].res);
}


