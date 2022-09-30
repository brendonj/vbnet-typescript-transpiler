import antlr4

from vbnetLexer import vbnetLexer
from vbnetParser import vbnetParser
from vbnetParserListener import vbnetParserListener
from vbnetParserVisitor import vbnetParserVisitor

# antlr4 -Dlanguage=Python3 -visitor vbnetLexer.g4 vbnetParser.g4
# cat foo | python3 vbnet.py | js-beautify

class vbnetPrintVisitor(vbnetParserVisitor):
    def defaultResult(self):
        return []

    def aggregateResult(self, aggregate, nextResult):
        if nextResult:
            aggregate.extend(nextResult)
            #aggregate.append(nextResult)
        return aggregate

    def visitImportStatement(self, ctx):
        alias = ""
        namespace = ""

        if len(ctx.IDENTIFIER()) == 1:
            namespace = ctx.IDENTIFIER(0).getText()
        else:
            alias = " as %s" % ctx.IDENTIFIER(0).getText()
            namespace = ctx.IDENTIFIER(1).getText()

        print("// import %s%s" % (namespace, alias))

    def visitEnumDeclaration(self, ctx):
        # TODO when should we not export an enum?
        print("export enum %s {" % (ctx.IDENTIFIER().getText()))
        #members = self.visit(ctx.enumMember())
        members = self.visitChildren(ctx)
        #members = []
        #for i in ctx.enumMember():
        #    members += self.visit(i)
        print(",".join(members))
        print("}")
        print()

    def visitEnumMember(self, ctx):
        value = ""
        if ctx.simpleExpression():
            value = self.visit(ctx.simpleExpression())
        return ["%s%s" % (
            ctx.IDENTIFIER().getText(),
            " = %s" % value if value else "")
        ]

    def visitInterfaceDeclaration(self, ctx):
        print("%sinterface %s {" % (
            "export " if ctx.PUBLIC() else "",
            ctx.IDENTIFIER().getText()))
        self.visitChildren(ctx)
        print("}")
        print()

    # FUNCTION IDENTIFIER OPENPAREN parameterList? CLOSEPAREN AS typeName
    def visitInterfaceFunction(self, ctx):
        identifier = ctx.IDENTIFIER().getText()
        params = []
        #params = self.visitChildren(ctx)
        if ctx.parameterList():
            params = self.visit(ctx.parameterList())
        #returnType = ctx.typeName().getText()
        returnType = self.visit(ctx.typeName())
        print("%s(%s): %s;" % (identifier, ", ".join(params), returnType))

    def visitInterfaceSub(self, ctx):
        identifier = ctx.IDENTIFIER().getText()
        params = []
        if ctx.parameterList():
            params = self.visit(ctx.parameterList())
        print("%s(%s): void;" % (identifier, ", ".join(params)))

    # parameterModifier* IDENTIFIER AS typeName ( EQUALS simpleExpression )?
    def visitParameter(self, ctx):
        default = ""
        if ctx.simpleExpression():
            #default = ctx.simpleExpression().getText()
            default = self.visit(ctx.simpleExpression())
        modifiers = ctx.parameterModifier()
        optional = "?" if any([x.OPTIONAL() for x in modifiers]) else ""
        return ["%s%s: %s%s" % (
            ctx.IDENTIFIER().getText(),
            optional,
            self.visit(ctx.typeName()),
            " = %s" % default if default else "")
        ]

    def visitInterfaceProperty(self, ctx):
        # XXX could move modifiers into same rule, then check ctx.READONLY()
        modifiers = ctx.propertyModifier()
        readonly = True if modifiers and modifiers.READONLY() else False
        returnType = "Object"
        if ctx.typeName():
            returnType = self.visit(ctx.typeName())
        print("%s%s: %s;" % (
            "readonly " if readonly else "",
            ctx.IDENTIFIER().getText(),
            returnType))

    def visitNamespaceDeclaration(self, ctx):
        print("namespace %s {" % ctx.IDENTIFIER().getText())
        self.visitChildren(ctx)
        print("}")
        print()

    def visitImplementsStatement(self, ctx):
        ifaces = []
        if len(ctx.IDENTIFIER()) == 1:
            ifaces = [ctx.IDENTIFIER().getText()]
        else:
            for i in ctx.IDENTIFIER():
                ifaces.append(i.getText())
        return ifaces

    # classModifier? CLASS IDENTIFIER inheritsStatement? classStatement+ END CLASS
    def visitClassDeclaration(self, ctx):
        base = ""
        iface = ""
        if ctx.inheritsStatement():
            base = ctx.inheritsStatement().IDENTIFIER().getText()
        if ctx.implementsStatement():
            iface = ", ".join(self.visit(ctx.implementsStatement()))
        print("%s%sclass %s%s%s {" % (
            "public " if ctx.PUBLIC() else "",
            "abstract " if ctx.MUST_INHERIT() else "",
            ctx.IDENTIFIER().getText(),
            " extends %s" % base if base else "",
            " implements %s" % iface if iface else ""))
        self.visitChildren(ctx)
        print("}")
        print()

    # XXX check if this will actually be different to interface properties
    def visitClassProperty(self, ctx):
        default = ""
        if ctx.simpleExpression():
            #default = ctx.simpleExpression().getText()
            default = self.visit(ctx.simpleExpression())
        elif ctx.complexExpression():
            #default = "XXX"
            pass
        print("%s: %s%s;" % (
            ctx.IDENTIFIER().getText(),
            self.visit(ctx.typeName()),
            " = %s" % default if default else "",
            ))

    def visitClassFunction(self, ctx):
        identifier = ctx.IDENTIFIER().getText()
        params = []
        #params = self.visitChildren(ctx)
        if ctx.parameterList():
            params = self.visit(ctx.parameterList())
        #returnType = ctx.typeName().getText()
        returnType = "unknown"
        if ctx.typeName():
            returnType = self.visit(ctx.typeName())
        print("%s%s(%s): %s {" % (
            "static " if ctx.SHARED() else "",
            identifier,
            ", ".join(params),
            returnType))
        print("throw new Error('not implemented');")
        print("}")
        print()

    def visitClassSub(self, ctx):
        identifier = ctx.IDENTIFIER().getText()
        params = []
        #params = self.visitChildren(ctx)
        if ctx.parameterList():
            params = self.visit(ctx.parameterList())
        print("%s(%s) {" % (identifier, ", ".join(params)))
        print("throw new Error('not implemented');")
        print("}")
        print()

    def visitClassConstructor(self, ctx):
        params = []
        if ctx.parameterList():
            params = self.visit(ctx.parameterList())
        print("constructor(%s) {" % (", ".join(params)))
        print("throw new Error('not implemented');")
        print("}")
        print()

    def visitSimpleExpression(self, ctx):
        if ctx.NOTHING():
            return "null"
        elif ctx.literal() and ctx.literal().booleanLiteral():
            return ctx.literal().booleanLiteral().getText().lower()
        return ctx.getText()

    def visitTypeAtom(self, ctx):
        atom = ctx.getText()
        types = {
            "Boolean": "boolean",
            "String": "string",
            "Integer": "number",
            "Double": "number",
        }
        return types.get(atom, atom)

    def visitSimpleType(self, ctx):
        # return it directly as a string rather than aggregate type
        return self.visit(ctx.typeAtom())

    def visitNullableType(self, ctx):
        return "%s | null" % self.visit(ctx.typeName())

    def visitTupleType(self, ctx):
        return "[%s, %s]" % (
            self.visit(ctx.typeName(0)),
            self.visit(ctx.typeName(1)))

    def visitArrayType(self, ctx):
        return "%s[]" % self.visit(ctx.typeName())

    def visitMapType(self, ctx):
        key = self.visit(ctx.typeName(0))
        value = self.visit(ctx.typeName(1))

        if key == "string":
            return "{ [key: string]: %s }" % value

        return "Map<%s, %s>" % (key, value)

    # looks like the last type is the return type?
    def visitFunctionType(self, ctx):
        inparams = []
        outparam = "void"
        params = ctx.typeName()
        if params:
            outparam = self.visit(params[-1:][0])
            for i, param in enumerate(params[:-1]):
                inparams.append("%s: %s" % (
                    chr(ord("a") + i), self.visit(param)))
        return "(%s) => %s" % (", ".join(inparams), outparam)


def main():
    lexer = vbnetLexer(antlr4.StdinStream())
    stream = antlr4.CommonTokenStream(lexer)

    debugLexer = False
    if debugLexer:
        stream.fill()
        for token in stream.tokens:
            if token.text != '<EOF>':
                print("%s: %s" % (token.text,
                    vbnetLexer.symbolicNames[token.type]))

    parser = vbnetParser(stream)
    tree = parser.start()

    vbnetPrintVisitor().visit(tree)


if __name__ == "__main__":
    main()
