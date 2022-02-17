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

// Tokens
%token ID INT DOUBLE STRING BOOL IF WHILE FOR EMPTY_OBJ EMPTY_ARRAY LET VAR CONST

%start S

%%

S : CMDs { cout << $1.v << endl << "." << endl; }
  ;

CMDs : CMD CMDs { $$.v = $1.v + $2.v; }
     | CMD
     ;
     
CMD : CMD_LVALUE '=' CMD_RVALUE ';'      { $$.v = $1.v + " " + $3.v + " " + "= ^ "; }
    | CMD_LVALUE '=' CMD_RVALUE          { $$.v = $1.v + " " + $3.v + " " + "= ^ "; }
    | CMD_LVALUE_PROP '=' CMD_RVALUE ';' { $$.v = $1.v + " " + $3.v + " " + "[=] ^ "; }
    | CMD_LVALUE_PROP '=' CMD_RVALUE     { $$.v = $1.v + " " + $3.v + " " + "[=] ^ "; }
    ;
    
CMD_LVALUE : ID { $$.v = $1.v; };

CMD_LVALUE_PROP : ID '.' ID         { $$.v = $1.v + "@" + " " + $3.v; }
		 | ID '[' STRING ']' { $$.v = $1.v + "@" + " " + $3.v; }
		 | ID '[' INT ']'    { $$.v = $1.v + "@" + " " + $3.v; }
		 | ID '[' DOUBLE ']' { $$.v = $1.v + "@" + " " + $3.v; }
		 ;

CMD_RVALUE : ID { $$.v = $1.v + "@"; }
           | INT
           | DOUBLE
           | STRING
           | BOOL
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
