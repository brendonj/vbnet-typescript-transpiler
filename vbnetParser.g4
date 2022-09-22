parser grammar vbnetParser;

options { tokenVocab=vbnetLexer; }

start
    : DIGIT+
    | enumDeclaration
    | interfaceDeclaration
    ;

interfaceDeclaration
    : INTERFACE_JUNK PUBLIC INTERFACE IDENTIFIER interfaceStatements+ END INTERFACE
    ;

interfaceStatements
    : interfaceProperty
    | interfaceFunction
    | interfaceSub
    | enumDeclaration
    ;

interfaceProperty
    : propertyModifier? PROPERTY IDENTIFIER AS typeName
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
    : IDENTIFIER
    | NOTHING
    | literal
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
    : ENUM IDENTIFIER enumMember+ END ENUM
    ;

enumMember
    : IDENTIFIER
    ;

typeName
    : IDENTIFIER                                                 # simpleType
    | LIST OPENPAREN OF typeName CLOSEPAREN                      # arrayType
    | QUEUE OPENPAREN OF typeName CLOSEPAREN                     # arrayType
    | ACTION OPENPAREN OF typeName COMMA typeName CLOSEPAREN     # mapType
    | DICTIONARY OPENPAREN OF typeName COMMA typeName CLOSEPAREN # mapType
    ;

//identifier
//    : IDENT_NONDIGIT+
//    ;
