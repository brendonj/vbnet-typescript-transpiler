lexer grammar vbnetLexer;

ACTION: 'Action';
AS: 'As';
BYVAL: 'ByVal';
DICTIONARY: 'Dictionary';
END_CLASS: 'End Class';
END_ENUM: 'End Enum';
END_FUNCTION: 'End Function';
END_INTERFACE: 'End Interface';
END_NAMESPACE: 'End Namespace';
END_SUB: 'End Sub';
ENUM: 'Enum';
FUNC: 'Func';
FUNCTION: 'Function';
IMPORTS: 'Imports';
INTERFACE: 'Interface';
LIST: 'List' | 'System.Collections.Generic.List';
NOTHING: 'Nothing';
OF: 'Of';
OPTIONAL: 'Optional';
PROPERTY: 'Property';
PUBLIC: 'Public';
READONLY: 'ReadOnly';
SUB: 'Sub';
TUPLE: 'Tuple';
QUEUE: 'Queue';

TRUE: 'True';
FALSE: 'False';

COMMA: ',';
EQUALS: '=';
OPENPAREN: '(';
CLOSEPAREN: ')';
DOUBLEQUOTE: '"';

DIGIT
    : [0-9]
    ;

NUMBER
    : [0-9]+
    ;

STRINGLITERAL
    : '"' STRINGCHARACTER* '"'
    ;

fragment
STRINGCHARACTER
    : ~["\\\r\n]
    ;

IDENTIFIER
    : [a-zA-Z_][a-zA-Z0-9_.]*
    ;

INTERFACE_JUNK
    : '<InterfaceType(ComInterfaceType.InterfaceIsIDispatch)>' -> skip
    ;

PROPERTY_JUNK
    : '<Xml.Serialization.XmlIgnore>' -> skip
    ;

COMMENT
    : '\'' ~[\n]* '\n' -> skip
    ;

WHITESPACE
    : [ \t\r\n] -> skip
    ;
