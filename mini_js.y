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

// Tokens
%token	 ID DOUBLE STRING BOOL IF WHILE FOR EMPTY_OBJ EMPTY_ARRAY

%%

CMDs : A { cout << endl; } CMDs   
     |  // Vazio, epsilon
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
