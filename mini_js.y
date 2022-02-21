 %{
#include <iostream>
#include <vector>
#include <string>
#include <map>

using namespace std;

struct Atributos {
  string v;
  vector<string> c;
};

#define YYSTYPE Atributos

void erro( string msg );
void print( string st );
vector<string> concatena( vector<string> a, vector<string> b );
string gera_label( string prefixo );
vector<string> resolve_enderecos( vector<string> entrada );

int yylex();
void yyerror( const char* );

%}

%right '='
%left OR
%left AND 
%nonassoc '<' '>' EGUAL NOT_EGUAL MAIOR_IGUAL MENOR_IGUAL 
%left '+' '-'
%left '*' '/' '%'
%nonassoc UMINUS
%right '^'


// Tokens
%token ID INT DOUBLE STRING BOOL EMPTY_OBJ EMPTY_ARRAY 
%token IF WHILE FOR LET VAR CONST
%token OR AND EGUAL NOT_EGUAL MAIOR_IGUAL MENOR_IGUAL

%start S

%%

S : CMDs { cout << $1.v + " " + "." << endl; }
  ;

CMDs : CMD ';' CMDs { 
                   $$.v = $1.v + $3.v; 
                   $$.c = concatena( $1.c, $3.c );
                }
     | { $$.v = ""; }
     ;
     
CMD : CMD_DECLARACOES {$$.v = $1.v; }
    | CMD_FOR { $$.v = $1.v; }
    | CMD_IF { $$.v = $1.v; }
    | CMD_WHILE { $$.v = $1.v; }
    ;
    
CMD_DECLARACOES : CMD_ATRIB { $$.v = $1.v + " ^ "; }
                | LET CMD_MULT_DECLARACAO { $$.v = $2.v; }
                | VAR CMD_MULT_DECLARACAO { $$.v = $2.v; }
                | CONST CMD_MULT_DECLARACAO { $$.v = $2.v; }
                ; 
                
CMD_MULT_DECLARACAO : CMD_DECLARACAO ',' CMD_MULT_DECLARACAO { $$.v = $1.v + " " + $3.v; }
                    | CMD_DECLARACAO
                    ;
                
CMD_DECLARACAO : ID '=' CMD_RVALUE { $$.v = $1.v + "& " + $1.v + " " +  $3.v + " = ^ "; }
               | ID                { $$.v = $1.v + "& "; }
               ;

CMD_ATRIB : ID '=' CMD_ATRIB { $$.v = $1.v + " " + $3.v + " = "; }
          | CMD_RVALUE
          ;

CMD_RVALUE : ID { $$.v = $1.v + "@"; }
           | CMD_RVALUE '^' CMD_RVALUE { $$.v = $1.v + " " + $3.v + " " + $2.v; }
           | CMD_RVALUE '<' CMD_RVALUE { $$.v = $1.v + " " + $3.v + " " + $2.v; }
           | CMD_RVALUE EGUAL CMD_RVALUE { $$.v = $1.v + " " + $3.v + " " + $2.v; }
           | CMD_RVALUE NOT_EGUAL CMD_RVALUE { $$.v = $1.v + " " + $3.v + " " + $2.v; }
           | CMD_RVALUE MENOR_IGUAL CMD_RVALUE { $$.v = $1.v + " " + $3.v + " " + $2.v; }
           | CMD_RVALUE MAIOR_IGUAL CMD_RVALUE { $$.v = $1.v + " " + $3.v + " " + $2.v; }
           | CMD_RVALUE AND CMD_RVALUE { $$.v = $1.v + " " + $3.v + " " + $2.v; }
           | CMD_RVALUE OR CMD_RVALUE { $$.v = $1.v + " " + $3.v + " " + $2.v; }
           | CMD_RVALUE '*' CMD_RVALUE { $$.v = $1.v + " " + $3.v + " " + $2.v; }
           | CMD_RVALUE '+' CMD_RVALUE { $$.v = $1.v + " " + $3.v + " " + $2.v; }
           | CMD_RVALUE '-' CMD_RVALUE { $$.v = $1.v + " " + $3.v + " " + $2.v; }
           | CMD_RVALUE '/' CMD_RVALUE { $$.v = $1.v + " " + $3.v + " " + $2.v; }
           | CMD_RVALUE '>' CMD_RVALUE { $$.v = $1.v + " " + $3.v + " " + $2.v; }
           | CMD_RVALUE '%' CMD_RVALUE { $$.v = $1.v + " " + $3.v + " " + $2.v; }
           | INT 
           | DOUBLE 
           | STRING 
           | BOOL 
           | '-' CMD_RVALUE %prec UMINUS { $$.v = $1.v + $2.v; }
           | EMPTY_OBJ
           | EMPTY_ARRAY
           | '(' CMD_RVALUE ')' { $$.v = $2.v; }
           ;
           
CMD_FOR : FOR '(' CMD ';' CMD_RVALUE ';' CMD_RVALUE ')' '{' CMD '}';

CMD_IF : IF '(' CMD_RVALUE ')' '{' CMD '}' ;
           
CMD_WHILE : WHILE '(' CMD_RVALUE ')' '{' CMD '}' {
					             $$.v = $3.v + " ! " + gera_label("end_while") +                                                         " ? " + $6.v + gera_label(":end_while");
                                                 }
          ;
           
%%

#include "lex.yy.c"

vector<string> concatena( vector<string> a, vector<string> b ) {
  for( i = 0; i < b.size(); i++ )
    a.push_back( b[i] );
  return a;
}

string gera_label( string prefixo ) {
  static int n = 0;
  return prefixo + "_" + to_string( ++n ) + ":";
}

vector<string> resolve_enderecos( vector<string> entrada ) {
  map<string,int> label;
  vector<string> saida;
  for( int i = 0; i < entrada.size(); i++ ) 
    if( entrada[i][0] == ':' ) 
        label[entrada[i].substr(1)] = saida.size();
    else
      saida.push_back( entrada[i] );
  
  for( int i = 0; i < saida.size(); i++ ) 
    if( label.count( saida[i] ) > 0 )
        saida[i] = to_string(label[saida[i]]);
    
  return saida;
}

void yyerror( const char* msg ) {
  cout << endl << "Erro: " << msg << endl
       << "Perto de : '" << yylval.v << "'" <<endl;
  exit( 0 );
}

void print( string st ) {
  cout << st << " ";
}

int main() {
  yyparse();
  cout << endl;
}
