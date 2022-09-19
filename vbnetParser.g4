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
    : IDENTIFIER AS typeName ( EQUALS simpleExpression )?
    ;

simpleExpression
    : IDENTIFIER
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
    : IDENTIFIER
    | IDENTIFIER OPENPAREN OF typeName CLOSEPAREN
    | IDENTIFIER OPENPAREN OF typeName COMMA typeName CLOSEPAREN
    ;

//identifier
//    : IDENT_NONDIGIT+
//    ;
