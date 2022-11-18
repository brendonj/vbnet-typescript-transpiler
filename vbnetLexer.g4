lexer grammar vbnetLexer;

ACTION: 'Action';
AS: 'As';
BOOLEAN: 'Boolean';
BYREF: 'ByRef';
BYVAL: 'ByVal';
CLASS: 'Class';
DICTIONARY: 'Dictionary';
DOUBLE: 'Double';
END_CLASS: 'End Class';
END_ENUM: 'End Enum';
END_FUNCTION: 'End Function';
END_INTERFACE: 'End Interface';
END_NAMESPACE: 'End Namespace';
END_PROPERTY: 'End Property';
END_SUB: 'End Sub';
ENUM: 'Enum';
FRIEND: 'Friend';
FUNC: 'Func';
FUNCTION: 'Function';
IMPLEMENTS: 'Implements';
IMPORTS: 'Imports';
INHERITS: 'Inherits';
INTEGER: 'Integer';
INTERFACE: 'Interface';
LIST: 'List' | 'System.Collections.Generic.List';
MUST_INHERIT: 'MustInherit';
NAMESPACE: 'Namespace';
NEW: 'New';
NOTHING: 'Nothing';
NULLABLE: 'Nullable';
OF: 'Of';
OPTIONAL: 'Optional';
OVERLOADS: 'Overloads';
OVERRIDES: 'Overrides';
OVERRIDABLE: 'Overridable';
PRIVATE: 'Private';
PROPERTY: 'Property';
PUBLIC: 'Public';
QUEUE: 'Queue';
READONLY: 'ReadOnly';
SHARED: 'Shared';
SUB: 'Sub';
STRING: 'String';
TUPLE: 'Tuple';
WITH: 'With';

TRUE: 'True';
FALSE: 'False';

COMMA: ',';
EQUALS: '=';
OPENPAREN: '(';
CLOSEPAREN: ')';
DOUBLEQUOTE: '"';

//DIGIT
//    : [0-9]
//    ;

NUMBER
    : '-'? [0-9]+ ('.'? [0-9]+)?
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

CLASS_JUNK
    : '<Serializable()>' -> skip
    ;

INTERFACE_JUNK
    : '<InterfaceType(ComInterfaceType.InterfaceIsIDispatch)>' -> skip
    ;

PROPERTY_JUNK
    : '<Xml.Serialization.XmlIgnore>' -> skip
    ;

REGION_START_JUNK
    : '#Region' ~[\n]* '\n' -> skip
    ;

REGION_END_JUNK
    : '#End Region' -> skip
    ;

COMMENT
    : '\'' ~[\n]* '\n' -> skip
    ;

CONNECTION_POINT_DEFAULT_JUNK
    : '{.IsEnergyConnector = True}'
    ;

CONTINUANCE
    : ' _' -> skip
    ;

HASH
    : '#' -> skip
    ;

WHITESPACE
    : [ \t\r\n] -> skip
    ;

/* TODO can I read a whole line somehow? */
FUNCTION_BODY_JUNK
    : .
    ;
