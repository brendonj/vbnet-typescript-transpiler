parser grammar vbnetParser;

options { tokenVocab=vbnetLexer; }

start
    : statement+
    ;

statement
    : enumDeclaration
    | interfaceDeclaration
    | importStatement
    | namespaceDeclaration
    | classDeclaration
    ;

importStatement
    : IMPORTS IDENTIFIER ( EQUALS IDENTIFIER )?
    ;

namespaceDeclaration
    : NAMESPACE IDENTIFIER statement+ END_NAMESPACE
    ;

interfaceDeclaration
    : PUBLIC INTERFACE IDENTIFIER interfaceStatements+ END_INTERFACE
    ;

interfaceStatements
    : interfaceProperty
    | interfaceFunction
    | interfaceSub
    | enumDeclaration
    ;

interfaceProperty
    : propertyModifier? PROPERTY IDENTIFIER ( OPENPAREN CLOSEPAREN )? AS typeName
    ;

propertyModifier
    : READONLY
    ;

interfaceFunction
    : FUNCTION IDENTIFIER OPENPAREN parameterList? CLOSEPAREN AS typeName
    ;

interfaceSub
    : SUB IDENTIFIER OPENPAREN parameterList? CLOSEPAREN
    ;

inheritsStatement
    : INHERITS IDENTIFIER
    ;

implementsStatement
    : IMPLEMENTS IDENTIFIER ( COMMA IDENTIFIER )?
    ;

//classModifier
//    : PUBLIC
//    ;

classDeclaration
    : PUBLIC? MUST_INHERIT? CLASS IDENTIFIER inheritsStatement? implementsStatement? classStatement+ END_CLASS
    ;

classStatement
    : classProperty
    | classFunction
    | classConstructor
    | classSub
    ;

classProperty
    : PUBLIC? OVERRIDABLE? PROPERTY IDENTIFIER ( OPENPAREN CLOSEPAREN )? AS NEW? typeName ( EQUALS (simpleExpression | complexExpression) )? implementsStatement? ( functionBody+ END_PROPERTY )?
    ;

classFunction
    : PUBLIC? SHARED? OVERRIDABLE? OVERRIDES? OVERLOADS? FUNCTION IDENTIFIER OPENPAREN parameterList? CLOSEPAREN ( AS typeName )? implementsStatement? functionBody+ END_FUNCTION
    ;

classSub
    : PUBLIC? OVERRIDABLE? OVERRIDES? SUB IDENTIFIER OPENPAREN parameterList? CLOSEPAREN ( AS typeName )? implementsStatement? functionBody* END_SUB
    ;

classConstructor
    : PUBLIC? OVERRIDABLE? OVERRIDES? SUB NEW OPENPAREN parameterList? CLOSEPAREN ( AS typeName )? implementsStatement? functionBody* END_SUB
    ;

/* XXX this needs to be a whole line of stuff if I want to print it nicely */
functionBody
    : IDENTIFIER
    | FUNCTION_BODY_JUNK
    | AS
    | OPENPAREN
    | CLOSEPAREN
    | EQUALS
    | LIST
    | OF
    | COMMA
    | TRUE
    | FALSE
    | NUMBER
    | STRINGLITERAL
    | NOTHING
    | BYVAL
    | BOOLEAN
    | DOUBLE
    | INTEGER
    | STRING
    | NEW
    | WITH
    ;

parameterList
    : parameter ( COMMA parameter )*
    ;

parameter
    : parameterModifier* IDENTIFIER AS typeName ( EQUALS simpleExpression )?
    ;

parameterModifier
    : BYVAL
    | OPTIONAL
    ;

simpleExpression
    : ( NEW )? IDENTIFIER
    | NOTHING
    | literal
    ;

complexExpression
    : NEW IDENTIFIER OPENPAREN CLOSEPAREN WITH CONNECTION_POINT_DEFAULT_JUNK
    ;

literal
    : booleanLiteral
    | stringLiteral
    | numericLiteral
    ;

booleanLiteral
    : TRUE
    | FALSE
    ;

stringLiteral
    : STRINGLITERAL
    ;

numericLiteral
    : NUMBER
    ;

enumDeclaration
    : ENUM IDENTIFIER enumMember+ END_ENUM
    ;

enumMember
    : IDENTIFIER
    ;

typeName
    : typeAtom                                                   # simpleType
    | TUPLE OPENPAREN OF typeName COMMA typeName CLOSEPAREN      # tupleType
    | typeName OPENPAREN CLOSEPAREN                              # arrayType
    | LIST OPENPAREN OF typeName CLOSEPAREN                      # arrayType
    | QUEUE OPENPAREN OF typeName CLOSEPAREN                     # arrayType
    | ACTION OPENPAREN OF typeName CLOSEPAREN                    # arrayType
    | ACTION OPENPAREN OF typeName COMMA typeName CLOSEPAREN     # mapType
    | DICTIONARY OPENPAREN OF typeName COMMA typeName CLOSEPAREN # mapType
    | FUNC OPENPAREN OF typeName COMMA typeName CLOSEPAREN       # functionType
    ;

typeAtom
    : BOOLEAN
    | DOUBLE
    | INTEGER
    | STRING
    | ACTION
    | IDENTIFIER
    ;
