%{
  import java.io.*;
%}

%token NL RETORNE LEIA ESCREVA PROGRAMA CAR INT LEIA ESCREVA NOVALINHA
%token SE ENTAO SENAO ENQUANTO EXECUTE RETORNE
%token OR AND EQEQ DIF LESS_THAN GREATER_THAN LESS_THAN_EQ GREATER_THAN_EQ
%token <ival> INTCONST
%token <sval> CONSTSTRING ID CARCONST

%left '-' '+'
%left '*' '/'
%left NEG          /* negation--unary minus */

%%

Programa:
    DeclFuncVar DeclProg
  ;

DeclFuncVar:
    /* vazio */
  | Tipo ID DeclVar ';' DeclFuncVar
  | Tipo ID '['INTCONST']' DeclVar ';' DeclFuncVar
  | Tipo ID DeclFunc DeclFuncVar
  ;

DeclProg :
    PROGRAMA Bloco
  ;

DeclVar :
    /* vazio */
  | ',' ID DeclVar
  | ',' ID '['INTCONST']' DeclVar
  ;

DeclFunc :
    '('ListaParametros')' Bloco
  ;

ListaParametros :
    /* vazio */
  | ListaParametrosCont
  ;

ListaParametrosCont:
    Tipo ID
  | Tipo ID '['']'
  | Tipo ID ',' ListaParametrosCont
  | Tipo ID '['']' ',' ListaParametrosCont
  ;

Bloco :
    '{'ListaDeclVar ListaComando'}'
  | '{'ListaDeclVar'}'
  ;

ListaDeclVar :
    /* vazio */
  | Tipo ID DeclVar ';' ListaDeclVar
  | Tipo ID '['INTCONST']' DeclVar ';' ListaDeclVar
  ;

Tipo :
    INT
  | CAR
  ;

ListaComando :
    Comando
  | Comando ListaComando
  ;

Comando :
    ';'
  | Expr ';'
  | RETORNE Expr ';'
  | LEIA LValueExpr ';'
  | ESCREVA Expr ';'
  | ESCREVA CONSTSTRING ';'
  | NOVALINHA ';'
  | SE '('Expr')' ENTAO Comando
  | SE '('Expr')' ENTAO Comando SENAO Comando
  | ENQUANTO '('Expr')' EXECUTE Comando
  | Bloco
  ;

Expr :
    AssignExpr
  ;

AssignExpr :
    CondExpr
  | LValueExpr '=' AssignExpr
  ;

CondExpr :
    OrExpr
  | OrExpr '?' Expr ':' CondExpr
  ;

OrExpr :
    OrExpr OR AndExpr
  | AndExpr
  ;

AndExpr :
    AndExpr AND EqExpr
  | EqExpr
  ;

EqExpr :
    EqExpr EQEQ DesigExpr
  | EqExpr DIF DesigExpr
  | DesigExpr
  ;

DesigExpr :
    DesigExpr LESS_THAN AddExpr
  | DesigExpr GREATER_THAN AddExpr
  | DesigExpr GREATER_THAN_EQ AddExpr
  | DesigExpr LESS_THAN_EQ AddExpr
  | AddExpr

AddExpr :
    AddExpr '+' MulExpr
  | AddExpr '-' MulExpr
  | MulExpr
  ;

MulExpr :
    MulExpr '*' UnExpr
  | MulExpr '/' UnExpr
  | MulExpr '%' UnExpr
  | UnExpr
  ;

UnExpr :
    '-'PrimExpr %prec NEG
  | '!'PrimExpr
  | PrimExpr
  ;

LValueExpr :
    ID '['Expr']'
  | ID
  ;

PrimExpr :
    ID '('ListExpr')'
  | ID '('')'
  | ID '['Expr']'
  | ID
  | CARCONST
  | INTCONST
  | '('Expr')'
  ;

ListExpr :
    AssignExpr
  | ListExpr ',' AssignExpr
  ;


%%

  private Yylex lexer;


  private int yylex () {
    int yyl_return = -1;
    try {
      yylval = new ParserVal(0);
      yyl_return = lexer.yylex();
    }
    catch (IOException e) {
      System.err.println("IO error :"+e);
    }
    return yyl_return;
  }


  public void yyerror (String error) {
    System.err.println ("ERROR: "+error);
    lexer.printLexError();
  }


  public Parser(Reader r) {
    lexer = new Yylex(r, this);
  }


  static boolean interactive;

  public static void main(String args[]) throws IOException {
    System.out.println("Analizador lexico e sintatico, usando BYACC/Java e JFlex, para Cafezinho");

    Parser yyparser;
    if ( args.length > 0 ) {
      yyparser = new Parser(new FileReader(args[0]));
      if ( yyparser.yyparse() == 0 )
        System.out.println("## Análise feita com sucesso ##");
    }
    else {
      System.out.println("Argumento não encontrado!");
    }

  }
