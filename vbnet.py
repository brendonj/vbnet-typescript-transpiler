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
        print("// import %s" % ctx.IDENTIFIER().getText())

    def visitEnumDeclaration(self, ctx):
        print("enum %s {" % (ctx.IDENTIFIER().getText()))
        #members = self.visit(ctx.enumMember())
        members = self.visitChildren(ctx)
        #members = []
        #for i in ctx.enumMember():
        #    members += self.visit(i)
        print(",".join(members))
        print("}")

    def visitEnumMember(self, ctx):
        return ["%s" % ctx.IDENTIFIER().getText()]

    def visitInterfaceDeclaration(self, ctx):
        print("interface %s {" % ctx.IDENTIFIER().getText())
        self.visitChildren(ctx)
        print("}")

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
        print("%s%s: %s;" % (
            "readonly " if readonly else "",
            ctx.IDENTIFIER().getText(),
            self.visit(ctx.typeName())))

    def visitNamespaceDeclaration(self, ctx):
        print("namespace %s {" % ctx.IDENTIFIER().getText())
        self.visitChildren(ctx)
        print("}")

    # classModifier? CLASS IDENTIFIER inheritsStatement? classStatement+ END CLASS
    def visitClassDeclaration(self, ctx):
        base = ""
        if ctx.inheritsStatement():
            base = ctx.inheritsStatement().IDENTIFIER().getText()
        print("class %s%s {" % (
            ctx.IDENTIFIER().getText(),
            " extends %s" % base if base else ""))
        self.visitChildren(ctx)
        print("}")

    # XXX check if this will actually be different to interface properties
    def visitClassProperty(self, ctx):
        default = ""
        if ctx.simpleExpression():
            #default = ctx.simpleExpression().getText()
            default = self.visit(ctx.simpleExpression())
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
        returnType = self.visit(ctx.typeName())
        print("%s(%s): %s {" % (identifier, ", ".join(params), returnType))
        print("/* TODO implement function body */")
        print("}")

    def visitClassSub(self, ctx):
        identifier = ctx.IDENTIFIER().getText()
        params = []
        #params = self.visitChildren(ctx)
        if ctx.parameterList():
            params = self.visit(ctx.parameterList())
        print("%s(%s) {" % (identifier, ", ".join(params)))
        print("/* TODO implement function body */")
        print("}")

    def visitSimpleExpression(self, ctx):
        if ctx.NOTHING():
            return "null"
        elif ctx.literal() and ctx.literal().booleanLiteral():
            return ctx.literal().booleanLiteral().getText().lower()
        return ctx.getText()

    def visitSimpleType(self, ctx):
        name = "UNKNOWN"
        if ctx.IDENTIFIER():
            name = ctx.IDENTIFIER().getText()
        elif ctx.ACTION():
            name = ctx.ACTION().getText()
        types = {
            "Boolean": "boolean",
            "String": "string",
            "Integer": "number",
            "Double": "number",
        }
        return types.get(name, name)

    def visitTupleType(self, ctx):
        return "[%s, %s]" % (
            self.visit(ctx.typeName(0)),
            self.visit(ctx.typeName(1)))

    def visitArrayType(self, ctx):
        if ctx.IDENTIFIER():
            return "%s[]" % ctx.IDENTIFIER().getText()
        #return "%s[]" % ctx.typeName().getText()
        return "%s[]" % self.visit(ctx.typeName())

    def visitMapType(self, ctx):
        return "Map<%s, %s>" % (
            self.visit(ctx.typeName(0)),
            self.visit(ctx.typeName(1)))
            #ctx.typeName(0).getText(),
            #ctx.typeName(1).getText())

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
