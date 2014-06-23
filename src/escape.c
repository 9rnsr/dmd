
/* Compiler implementation of the D programming language
 * Copyright (c) 1999-2014 by Digital Mars
 * All Rights Reserved
 * written by Walter Bright
 * http://www.digitalmars.com
 * Distributed under the Boost Software License, Version 1.0.
 * http://www.boost.org/LICENSE_1_0.txt
 * https://github.com/D-Programming-Language/dmd/blob/master/src/escape.c
 */

#include <stdio.h>

#include "expression.h"
#include "declaration.h"
#include "mtype.h"

/************************************
 * Detect cases where pointers to the stack can 'escape' the
 * lifetime of the stack frame.
 */

#define LOGESC      0

void checkEscape(Expression *e)
{
    class CheckEscape : public Visitor
    {
        void visit(Expression *e)
        {
#if LOGESC
            printf("\tExpression::checkEscape e = %s\n", e->toChars());
#endif
        }

        void visit(SymOffExp *e)
        {
#if LOGESC
            printf("\tSymOffExp::checkEscape e = %s\n", e->toChars());
#endif
            VarDeclaration *v = e->var->isVarDeclaration();
            if (v && !v->isDataseg() && !(v->storage_class & (STCref | STCout)))
            {
                /* BUG: This should be allowed:
                 *   void foo() {
                 *     int a;
                 *     int* bar() { return &a; }
                 *   }
                 */
                e->error("escaping reference to local %s", v->toChars());
            }
        }

        void visit(VarExp *e)
        {
#if LOGESC
            printf("\tVarExp::checkEscape e = %s\n", e->toChars());
#endif
            VarDeclaration *v = e->var->isVarDeclaration();
            if (v)
            {
                Type *tb = v->type->toBasetype();
                // if reference type
                if (tb->ty == Tarray || tb->ty == Tsarray || tb->ty == Tclass || tb->ty == Tdelegate)
                {
                    if (v->isScope() && (!v->noscope || tb->ty == Tclass))
                        e->error("escaping reference to scope local %s", v->toChars());
                    else if (v->storage_class & STCvariadic)
                        e->error("escaping reference to variadic parameter %s", v->toChars());
                }
            }
        }

        void visit(TupleExp *e)
        {
#if LOGESC
            printf("\tTupleExp::checkEscape e = %s\n", e->toChars());
#endif
            for (size_t i = 0; i < e->exps->dim; i++)
            {
                (*e->exps)[i]->accept(this);
            }
        }

        void visit(AddrExp *e)
        {
#if LOGESC
            printf("\tAddrExp::checkEscape e = %s\n", e->toChars());
#endif
            e->e1->checkEscapeRef();
        }

        void visit(CastExp *e)
        {
#if LOGESC
            printf("\tCastExp::checkEscape e = %s\n", e->toChars());
#endif
            Type *tb = e->type->toBasetype();
            if (tb->ty == Tarray && e->e1->op == TOKvar &&
                e->e1->type->toBasetype()->ty == Tsarray)
            {
                VarExp *ve = (VarExp *)e->e1;
                VarDeclaration *v = ve->var->isVarDeclaration();
                if (v && !v->isDataseg() && !v->isParameter())
                    e->error("escaping reference to local %s", v->toChars());
            }
        }

        void visit(SliceExp *e)
        {
#if LOGESC
            printf("\tSliceExp::checkEscape e = %s\n", e->toChars());
#endif
            e->e1->accept(this);
        }

        void visit(CommaExp *e)
        {
#if LOGESC
            printf("\tCommaExp::checkEscape e = %s\n", e->toChars());
#endif
            e->e2->accept(this);
        }

        void visit(CondExp *e)
        {
#if LOGESC
            printf("\tCondExp::checkEscape e = %s\n", e->toChars());
#endif
            e->e1->accept(this);
            e->e2->accept(this);
        }
    };

    CheckEscape v;
    e->accept(&v);
}

void checkEscapeRef(Expression *e)
{
    class CheckEscapeRef : public Visitor
    {
        void visit(Expression *e)
        {
#if LOGESC
            printf("\tExpression::checkEscapeRef e = %s\n", e->toChars());
#endif
        }

        void visit(VarExp *e)
        {
#if LOGESC
            printf("\tVarExp::checkEscapeRef e = %s\n", e->toChars());
#endif
            VarDeclaration *v = e->var->isVarDeclaration();
            if (v && !v->isDataseg() && !(v->storage_class & (STCref | STCout)))
                e->error("escaping reference to local variable %s", v->toChars());
        }

        void visit(PtrExp *e)
        {
#if LOGESC
            printf("\tPtrExp::checkEscapeRef e = %s\n", e->toChars());
#endif
            e->e1->checkEscape();
        }

        void visit(SliceExp *e)
        {
#if LOGESC
            printf("\tSliceExp::checkEscapeRef e = %s\n", e->toChars());
#endif
            e->e1->accept(this);
        }

        void visit(CommaExp *e)
        {
#if LOGESC
            printf("\tCommaExp::checkEscapeRef e = %s\n", e->toChars());
#endif
            e->e2->accept(this);
        }

        void visit(CondExp *e)
        {
#if LOGESC
            printf("\tCondExp::checkEscapeRef e = %s\n", e->toChars());
#endif
            e->e1->accept(this);
            e->e2->accept(this);
        }
    };

    CheckEscapeRef v;
    e->accept(&v);
}
