 %{
#include <iostream>
#include <string>
#include <map>

using namespace std;

struct Atributos {
  string v;
};

// Tipo dos atributos: YYSTYPE é o tipo usado para os atributos.
#define YYSTYPE Atributos

void erro( string msg );
void print( string st );

// protótipo para o analisador léxico (gerado pelo lex)
int yylex();
void yyerror( const char* );

%}

// Tokens
// %token	 ID NUM PRINT STRING

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
