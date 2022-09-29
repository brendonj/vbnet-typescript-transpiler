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
    : IMPORTS IDENTIFIER
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

classModifier
    : PUBLIC
    ;

classDeclaration
    : classModifier? CLASS IDENTIFIER inheritsStatement? classStatement+ END_CLASS
    ;

classStatement
    : classProperty
    | classFunction
    | classSub
    ;

classProperty
    : PUBLIC? PROPERTY IDENTIFIER ( OPENPAREN CLOSEPAREN )? AS typeName ( EQUALS simpleExpression )?
    ;

classFunction
    : PUBLIC? OVERRIDES? FUNCTION IDENTIFIER OPENPAREN parameterList? CLOSEPAREN AS typeName functionBody+ END_FUNCTION
    ;

classSub
    : PUBLIC? OVERRIDES? SUB IDENTIFIER OPENPAREN parameterList? CLOSEPAREN ( AS typeName )? functionBody+ END_SUB
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
