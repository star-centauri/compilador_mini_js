 %{
#include <iostream>
#include <vector>
#include <string>
#include <map>

using namespace std;

struct Atributos {
  string v;
};

#define YYSTYPE Atributos

void erro( string msg );
void print( string st );

int yylex();
void yyerror( const char* );

%}

%right '='
%left '(' ')'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS


// Tokens
%token ID INT DOUBLE STRING BOOL EMPTY_OBJ EMPTY_ARRAY 
%token IF WHILE FOR LET VAR CONST
%token OR AND EGUAL NOT_EGUAL MAIOR_IGUAL MENOR_IGUAL

%start S

%%

S : CMDs { cout << $1.v << endl << "." << endl; }
  ;

CMDs : CMD CMDs { $$.v = $1.v + $2.v; }
     | CMD
     ;
     
CMD : CMD_DECLARACAO '=' CMD_RVALUE CMD_TERMINO      { $$.v = $1.v + " " + $3.v + " " + "= ^ "; }
    | CMD_DECLARACAO CMD_TERMINO { $$.v = $1.v; }
    | CMD_DECLARACAO_PROP '=' CMD_RVALUE CMD_TERMINO { $$.v = $1.v + " " + $3.v + " " + "[=] ^ "; }
    | CMD_FOR { $$.v = $1.v }
    ;
    
CMD_DECLARACAO : VAR CMD_LVALUE   { $$.v = $2.v; }
               | LET CMD_LVALUE   { $$.v = $2.v; }
               | CONST CMD_LVALUE { $$.v = $2.v; }
               | CMD_LVALUE { $$.v = $1.v; }
               ;
               
CMD_DECLARACAO_PROP : VAR CMD_LVALUE_PROP   { $$.v = $2.v; }
                    | LET CMD_LVALUE_PROP   { $$.v = $2.v; }
                    | CONST CMD_LVALUE_PROP { $$.v = $2.v; }
                    | CMD_LVALUE_PROP { $$.v = $1.v; }
                    ; 

CMD_LVALUE : ID {  $$.v = $1.v; }
           | ID ',' CMD_LVALUE { $$.v = $1.v + "&" + " " + $3.v + "&" + " ";  }
           ;
           
CMD_LVALUE_PROP : ID '.' ID         { $$.v = $1.v + "@" + " " + $3.v; }
		 | ID '[' STRING ']' { $$.v = $1.v + "@" + " " + $3.v; }
		 | ID '[' INT ']'    { $$.v = $1.v + "@" + " " + $3.v; }
		 | ID '[' DOUBLE ']' { $$.v = $1.v + "@" + " " + $3.v; }
		 ;


CMD_RVALUE : ID { $$.v = $1.v + "@"; }
           | CMD_RVALUE '+' CMD_RVALUE { $$.v = $1.v + " " + $3.v + " " + $2.v; }
           | CMD_RVALUE '-' CMD_RVALUE { $$.v = $1.v + " " + $3.v + " " + $2.v; }
           | CMD_RVALUE '*' CMD_RVALUE { $$.v = $1.v + " " + $3.v + " " + $2.v; }
           | CMD_RVALUE '/' CMD_RVALUE { $$.v = $1.v + " " + $3.v + " " + $2.v; }
           | INT
           | DOUBLE
           | STRING
           | BOOL
           | '-' CMD_RVALUE %prec UMINUS
           | EMPTY_OBJ 
           | EMPTY_ARRAY
           | '(' CMD_RVALUE ')'
           ;
           
CMD_FOR : FOR '(' CMD ';' CMD_RVALUE ';' CMD_RVALUE ')' '{' CMD '}';
           
CMD_TERMINO : ';' 
            | '\n'
            |
            ;


%%

#include "lex.yy.c"

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
