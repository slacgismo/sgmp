import numpy as np
import pandas as pd

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
        "sin": lambda arr: arr.apply(np.sin),
        "cos": lambda arr: arr.apply(np.cos),
        "tan": lambda arr: arr.apply(np.tan),
        "abs": lambda arr: arr.apply(np.abs),
        "exp": lambda arr: arr.apply(np.exp),
        "pos": lambda arr: arr.where(arr > 0, 0),
        "neg": lambda arr: arr.where(arr < 0, 0),
        "avg": lambda arr, period: arr.groupby(lambda ts: (ts - (ts % period))).mean()
    }

    opn = {
        "+": operator.add,
        "-": operator.sub,
        "*": operator.mul,
        "/": operator.truediv,
        "^": operator.pow
    }

    def __init__(self):
        self.expr_stack = []
        self.ctxt = {}

    def parse_expression(self, expr):
        self.expr_stack[:] = []
        parser = self._get_parser()
        parser.parseString(expr, parseAll=True)
        return self.expr_stack[:]

    def collect_identifiers(self):
        idents = set()
        
        def is_identifier(op):
            if isinstance(op, tuple):
                return False
            if op == "unary -":
                return False
            if op in "+-*/^":
                return False
            elif op == "PI" or op == "E":
                return False
            elif op in self.fn:
                return False
            return op[0].isalpha()

        for item in self.expr_stack:
            if is_identifier(item):
                idents.add(item)

        return list(idents)

    def evaluate(self, ctxt):
        self.ctxt = ctxt
        return self._evaluate(self.expr_stack[:])

    def _get_parser(self):
        e = CaselessKeyword('E')
        pi = CaselessKeyword('PI')

        fnumber = Regex(r"[=-]?\d+(?:\.\d*)?(?:[eE][+=]?\d+)?")
        ident = Word(alphas, alphanums + "_$.:")

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
            if op in self.ctxt:
                return self.ctxt[op]
            raise Exception('identifier not found in context: %s' % op)
        else:
            try:
                return int(op)
            except ValueError:
                return float(op)
