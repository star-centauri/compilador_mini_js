%{

int linha = 1;
int coluna = 1;
int ultimo_token = -1;

int token( int );

%}

D  	[0-9]
L   	[A-Za-z_]
INT	{D}+
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

"\n"/{WS}*({ID}|{NUM}){WS}* { linha++; coluna = 1;
                              if( ultimo_token != ';' ) {
                                ultimo_token = ';';
                                return ';';
                              } 
                            }

{DOUBLE} { return token( DOUBLE ); }
{STRING} { return token( STRING ); }
{BOOL}   { return token( STRING ); }
      
"if"    { return token( IF ); }
"while" { return token( WHILE ); }
"for"   { return token( FOR ); }	
      
"{}" { return token( EMPTY_OBJ ); }
"[]" { return token( EMPTY_ARRAY); }
                                   
 {ID} { return token( ID ); }
      
 . { return token( yytext[0] ); }

%%

int token( int tk ) { 
  coluna += strlen(yytext);
  yylval.v = yytext;
  ultimo_token = tk;
  
  return tk;
}
