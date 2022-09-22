parser grammar vbnetParser;

options { tokenVocab=vbnetLexer; }

start
    : statement+
    ;

statement
    : enumDeclaration
    | interfaceDeclaration
    | importStatement
    ;

importStatement
    : IMPORTS IDENTIFIER
    ;

interfaceDeclaration
    : PUBLIC INTERFACE IDENTIFIER interfaceStatements+ END INTERFACE
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
    | ACTION                                                     # simpleType
    | TUPLE OPENPAREN OF typeName COMMA typeName CLOSEPAREN      # tupleType
    | IDENTIFIER OPENPAREN CLOSEPAREN                            # arrayType
    | LIST OPENPAREN OF typeName CLOSEPAREN                      # arrayType
    | QUEUE OPENPAREN OF typeName CLOSEPAREN                     # arrayType
    | ACTION OPENPAREN OF typeName CLOSEPAREN                    # arrayType
    | ACTION OPENPAREN OF typeName COMMA typeName CLOSEPAREN     # mapType
    | DICTIONARY OPENPAREN OF typeName COMMA typeName CLOSEPAREN # mapType
    | FUNC OPENPAREN OF typeName COMMA typeName CLOSEPAREN       # functionType
    ;
