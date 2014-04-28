
// Compiler implementation of the D programming language
// Copyright (c) 1999-2011 by Digital Mars
// All Rights Reserved
// written by Walter Bright
// http://www.digitalmars.com
// License for redistribution is by either the Artistic License
// in artistic.txt, or the GNU General Public License in gnu.txt.
// See the included readme.txt for details.

#include <stdio.h>
#include <assert.h>

#include "mars.h"
#include "init.h"
#include "expression.h"
#include "template.h"
#include "statement.h"
#include "mtype.h"
#include "utf.h"
#include "declaration.h"
#include "aggregate.h"
#include "scope.h"
#include "attrib.h"

bool Dsymbol_canThrow(Dsymbol *s, FuncDeclaration *func);
bool walkPostorder(Expression *e, StoppableVisitor *v);

/********************************************
 * Returns true if the expression may throw exceptions.
 */

bool canThrow(Expression *e, FuncDeclaration *func)
{
    //printf("Expression::canThrow() %s\n", toChars());

    // stop walking if we determine this expression can throw
    class CanThrow : public StoppableVisitor
    {
        FuncDeclaration *func;

    public:
        CanThrow(FuncDeclaration *func)
            : func(func)
        {
        }

        void visit(Expression *)
        {
        }

        void visit(DeclarationExp *de)
        {
            stop = Dsymbol_canThrow(de->declaration, func);
        }

        void visit(CallExp *ce)
        {
            if (global.errors && !ce->e1->type)
                return;                       // error recovery

            /* If calling a function or delegate that is typed as nothrow,
             * then this expression cannot throw.
             * Note that pure functions can throw.
             */
            Type *t = ce->e1->type->toBasetype();
            if (ce->f && ce->f == func)
                ;
            else if (t->ty == Tfunction && ((TypeFunction *)t)->isnothrow)
                ;
            else if (t->ty == Tdelegate && ((TypeFunction *)((TypeDelegate *)t)->next)->isnothrow)
                ;
            else
            {
                stop = true;
            }
        }

        void visit(NewExp *ne)
        {
            if (ne->member)
            {
                // See if constructor call can throw
                Type *t = ne->member->type->toBasetype();
                if (t->ty == Tfunction && !((TypeFunction *)t)->isnothrow)
                {
                    stop = true;
                }
            }
            // regard storage allocation failures as not recoverable
        }

        void visit(AssignExp *ae)
        {
            // blit-init cannot throw
            if (ae->op == TOKblit)
                return;

            /* Element-wise assignment could invoke postblits.
             */
            Type *t;
            if (ae->type->toBasetype()->ty == Tsarray)
                t = ae->type;
            else if (ae->e1->op == TOKslice)
                t = ((SliceExp *)ae->e1)->e1->type;
            else
                return;

            Type *tv = t->baseElemOf();
            if (tv->ty != Tstruct)
                return;
            StructDeclaration *sd = ((TypeStruct *)tv)->sym;
            if (!sd->postblit || sd->postblit->type->ty != Tfunction)
                return;

            if (((TypeFunction *)sd->postblit->type)->isnothrow)
                ;
            else
            {
                stop = true;
            }
        }

        void visit(NewAnonClassExp *)
        {
            assert(0);          // should have been lowered by semantic()
        }
    };

    CanThrow ct(func);
    return walkPostorder(e, &ct);
}

/**************************************
 * Does symbol, when initialized, throw?
 * Mirrors logic in Dsymbol_toElem().
 */

bool Dsymbol_canThrow(Dsymbol *s, FuncDeclaration *func)
{
    AttribDeclaration *ad;
    VarDeclaration *vd;
    TemplateMixin *tm;
    TupleDeclaration *td;

    //printf("Dsymbol_toElem() %s\n", s->toChars());
    ad = s->isAttribDeclaration();
    if (ad)
    {
        Dsymbols *decl = ad->include(NULL, NULL);
        if (decl && decl->dim)
        {
            for (size_t i = 0; i < decl->dim; i++)
            {
                s = (*decl)[i];
                if (Dsymbol_canThrow(s, func))
                    return true;
            }
        }
    }
    else if ((vd = s->isVarDeclaration()) != NULL)
    {
        s = s->toAlias();
        if (s != vd)
            return Dsymbol_canThrow(s, func);
        if (vd->storage_class & STCmanifest)
            ;
        else if (vd->isStatic() || vd->storage_class & (STCextern | STCtls | STCgshared))
            ;
        else
        {
            if (vd->init)
            {
                ExpInitializer *ie = vd->init->isExpInitializer();
                if (ie && canThrow(ie->exp, func))
                    return true;
            }
            if (vd->edtor && !vd->noscope)
                return canThrow(vd->edtor, func);
        }
    }
    else if ((tm = s->isTemplateMixin()) != NULL)
    {
        //printf("%s\n", tm->toChars());
        if (tm->members)
        {
            for (size_t i = 0; i < tm->members->dim; i++)
            {
                Dsymbol *sm = (*tm->members)[i];
                if (Dsymbol_canThrow(sm, func))
                    return true;
            }
        }
    }
    else if ((td = s->isTupleDeclaration()) != NULL)
    {
        for (size_t i = 0; i < td->objects->dim; i++)
        {
            RootObject *o = (*td->objects)[i];
            if (o->dyncast() == DYNCAST_EXPRESSION)
            {
                Expression *eo = (Expression *)o;
                if (eo->op == TOKdsymbol)
                {
                    DsymbolExp *se = (DsymbolExp *)eo;
                    if (Dsymbol_canThrow(se->s, func))
                        return true;
                }
            }
        }
    }
    return false;
}
