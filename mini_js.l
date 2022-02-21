%{

int linha = 1;
int coluna = 1;
int ultimo_token = -1;
int i = 0;

int token( int );

%}

D  	[0-9]
L   	[A-Za-z_]
INT     {D}+
DOUBLE  {D}+"."{D}+([Ee][+\-]?{D}+)?
ID      {L}({L}|{D})*
CHAR 	"'"[^'\\]|(\\"n"|\\"t"|\\\\)"'"
STRING  (\"([^\"\n]|(\\\")|\"\")+\")|(\'([^\'\n]|(\\\')|\'\')+\')
BOOL	"true"|"false"
WS      [ \n\r\t]

%%

"\t" { coluna += 4; }
" "  { coluna++; }
"\n" { linha++; coluna = 1; }

"\n"/{WS}({DOUBLE}|{STRING}|{ID}|{BOOL}|{INT}) {
				            if( ultimo_token == ID 
				              || ultimo_token == DOUBLE 
					      || ultimo_token == STRING
					      || ultimo_token == BOOL 
					      || ultimo_token == ')' 
					      || ultimo_token == ']' ) {
					        return token( ';' );
				            }
					  }

{INT}    { return token( INT ); }
{DOUBLE} { return token( DOUBLE ); }
{STRING} { return token( STRING ); }
{BOOL}   { return token( STRING ); }
      
"let"   { return token( LET ); }
"var"   { return token( VAR ); }
"const" { return token( CONST ); }
      
"if"    { return token( IF ); }
"else"  { return token( ELSE ); }
"while" { return token( WHILE ); }
"for"   { return token( FOR ); }	
      
"{}" { return token( EMPTY_OBJ ); }
"[]" { return token( EMPTY_ARRAY); }
"||" { return token( OR ); }
"&&" { return token( AND ); }
"==" { return token( EGUAL ); }
"!=" { return token( NOT_EGUAL ); }
">=" { return token( MAIOR_IGUAL ); }
"<=" { return token( MENOR_IGUAL ); }
"+=" { return token( MAIS_EGUAL ); }
"-=" { return token( MENOS_EGUAL ); }
"*=" { return token( VEZES_EGUAL ); }
"/=" { return token( DIVISAO_EGUAL ); }
"++" { return token( MAIS_MAIS ); }
"--" { return token( MENOS_MENOS ); }
                                   
{ID} { return token( ID ); }
      
. { return token( yytext[0] ); }

%%

int token( int tk ) { 
  coluna += strlen(yytext);
  yylval.v = auxiliar + yytext;
  ultimo_token = tk;
  
  return tk;
}
