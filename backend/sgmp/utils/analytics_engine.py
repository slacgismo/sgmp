import numpy as np

from pyparsing import (
    Literal,
    Word,
    Group,
    Forward,
    alphas,
    alphanums,
    Regex,
    ParseException,
    CaselessKeyword,
    Suppress,
    delimitedList,
)

import math
import operator

# The AnalyticsEngine is rewritten from https://github.com/pyparsing/pyparsing/blob/master/examples/fourFn.py
# which is under MIT License
class AnalyticsEngine:

    fn = {
        "sin": np.sin,
        "cos": np.cos,
        "tan": np.tan,
        "exp": np.exp,
        "abs": np.abs
    }

    opn = {
        "+": operator.add,
        "-": operator.sub,
        "*": operator.mul,
        "/": operator.truediv,
        "^": operator.pow
    }

    expr_stack = []
    ctxt = {}

    def __init__(self):
        self.expr_stack[:] = []
        self.ctxt = {}

    def evaluate(self, expr, ctxt):
        self.expr_stack[:] = []
        self.ctxt = ctxt
        parser = self._get_parser()
        parser.parseString(expr, parseAll=True)
        return self._evaluate(self.expr_stack[:])

    def _get_parser(self):
        e = CaselessKeyword('E')
        pi = CaselessKeyword('PI')

        fnumber = Regex(r"[=-]?\d+(?:\.\d*)?(?:[eE][+=]?\d+)?")
        ident = Word(alphas, alphanums + "_$")

        plus, minus, mult, div = map(Literal, "+-*/")
        lpar, rpar = map(Suppress, "()")
        addop = plus | minus
        multop = mult | div
        expop = Literal("^")

        expr = Forward()
        expr_list = delimitedList(Group(expr))

        def push_first(toks):
            self.expr_stack.append(toks[0])


        def push_unary_minus(toks):
            for t in toks:
                if t == "-":
                    self.expr_stack.append("unary -")
                else:
                    break

        def insert_fn_argcount_tuple(t):
            fn = t.pop(0)
            num_args = len(t[0])
            t.insert(0, (fn, num_args))

        fn_call = (ident + lpar - Group(expr_list) + rpar).setParseAction(
            insert_fn_argcount_tuple
        )

        atom = (
            addop[...]
            + (
                (fn_call | pi | e | fnumber | ident).setParseAction(push_first)
                | Group(lpar + expr + rpar)
            )
        ).setParseAction(push_unary_minus)

        factor = Forward()
        factor <<= atom + (expop + factor).setParseAction(push_first)[...]
        term = factor + (multop + factor).setParseAction(push_first)[...]
        expr <<= term + (addop + term).setParseAction(push_first)[...]

        return expr

    def _evaluate(self, s):
        op, num_args = s.pop(), 0

        if isinstance(op, tuple):
            op, num_args = op
        if op == "unary -":
            return -self._evaluate(s)
        if op in "+-*/^":
            op2 = self._evaluate(s)
            op1 = self._evaluate(s)
            return self.opn[op](op1, op2)
        elif op == "PI":
            return math.pi
        elif op == "E":
            return math.e
        elif op in self.fn:
            args = reversed([self._evaluate(s) for _ in range(num_args)])
            return self.fn[op](*args)
        elif op[0].isalpha():
            if op[0] in self.ctxt:
                return self.ctxt[op[0]]
            raise Exception('identifier not found in context: %s' % op[0])
        else:
            try:
                return int(op)
            except ValueError:
                return float(op)
