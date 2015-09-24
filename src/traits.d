// Compiler implementation of the D programming language
// Copyright (c) 1999-2015 by Digital Mars
// All Rights Reserved
// written by Walter Bright
// http://www.digitalmars.com
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt

module ddmd.traits;

import core.stdc.stdio;
import core.stdc.string;
import ddmd.aggregate;
import ddmd.arraytypes;
import ddmd.attrib;
import ddmd.canthrow;
import ddmd.dclass;
import ddmd.declaration;
import ddmd.denum;
import ddmd.dimport;
import ddmd.dscope;
import ddmd.dstruct;
import ddmd.dsymbol;
import ddmd.dtemplate;
import ddmd.errors;
import ddmd.expression;
import ddmd.func;
import ddmd.globals;
import ddmd.hdrgen;
import ddmd.id;
import ddmd.identifier;
import ddmd.mtype;
import ddmd.nogc;
import ddmd.root.aav;
import ddmd.root.array;
import ddmd.root.rootobject;
import ddmd.root.speller;
import ddmd.root.stringtable;
import ddmd.tokens;
import ddmd.visitor;

enum LOGSEMANTIC = false;

/************************ TraitsExp ************************************/

extern (C++) __gshared StringTable traitsStringTable;

extern (C++) void initTraitsStringTable()
{
    __gshared const char*[] names =
    [
        "isAbstractClass",
        "isArithmetic",
        "isAssociativeArray",
        "isFinalClass",
        "isPOD",
        "isNested",
        "isFloating",
        "isIntegral",
        "isScalar",
        "isStaticArray",
        "isUnsigned",
        "isVirtualFunction",
        "isVirtualMethod",
        "isAbstractFunction",
        "isFinalFunction",
        "isOverrideFunction",
        "isStaticFunction",
        "isRef",
        "isOut",
        "isLazy",
        "hasMember",
        "identifier",
        "getProtection",
        "parent",
        "getMember",
        "getOverloads",
        "getVirtualFunctions",
        "getVirtualMethods",
        "classInstanceSize",
        "allMembers",
        "derivedMembers",
        "isSame",
        "compiles",
        "parameters",
        "getAliasThis",
        "getAttributes",
        "getFunctionAttributes",
        "getUnitTests",
        "getVirtualIndex",
        "getPointerBitmap",
    ];

    traitsStringTable._init(40);
    foreach (s; names)
    {
        StringValue* sv = traitsStringTable.insert(s, strlen(s));
        sv.ptrvalue = cast(void*)s;
    }
}

/**
 * get an array of size_t values that indicate possible pointer words in memory
 *  if interpreted as the type given as argument
 * the first array element is the size of the type for independent interpretation
 *  of the array
 * following elements bits represent one word (4/8 bytes depending on the target
 *  architecture). If set the corresponding memory might contain a pointer/reference.
 *
 *  [T.sizeof, pointerbit0-31/63, pointerbit32/64-63/128, ...]
 */
extern (C++) Expression pointerBitmap(TraitsExp e)
{
    if (!e.args || e.args.dim != 1)
    {
        error(e.loc, "a single type expected for trait pointerBitmap");
        return new ErrorExp();
    }
    Type t = getType((*e.args)[0]);
    if (!t)
    {
        error(e.loc, "%s is not a type", (*e.args)[0].toChars());
        return new ErrorExp();
    }
    d_uns64 sz = t.size(e.loc);
    if (t.ty == Tclass && !(cast(TypeClass)t).sym.isInterfaceDeclaration())
        sz = (cast(TypeClass)t).sym.AggregateDeclaration.size(e.loc);
    d_uns64 sz_size_t = Type.tsize_t.size(e.loc);
    d_uns64 bitsPerWord = sz_size_t * 8;
    d_uns64 cntptr = (sz + sz_size_t - 1) / sz_size_t;
    d_uns64 cntdata = (cntptr + bitsPerWord - 1) / bitsPerWord;
    Array!(d_uns64) data;
    data.setDim(cast(size_t)cntdata);
    data.zero();

    extern (C++) final class PointerBitmapVisitor : Visitor
    {
        alias visit = super.visit;
    public:
        extern (D) this(Array!(d_uns64)* _data, d_uns64 _sz_size_t)
        {
            this.data = _data;
            this.sz_size_t = _sz_size_t;
        }

        void setpointer(d_uns64 off)
        {
            d_uns64 ptroff = off / sz_size_t;
            (*data)[cast(size_t)(ptroff / (8 * sz_size_t))] |= 1L << (ptroff % (8 * sz_size_t));
        }

        override void visit(Type t)
        {
            Type tb = t.toBasetype();
            if (tb != t)
                tb.accept(this);
        }

        override void visit(TypeError t)
        {
            visit(cast(Type)t);
        }

        override void visit(TypeNext t)
        {
            assert(0);
        }

        override void visit(TypeBasic t)
        {
            if (t.ty == Tvoid)
                setpointer(offset);
        }

        override void visit(TypeVector t)
        {
        }

        override void visit(TypeArray t)
        {
            assert(0);
        }

        override void visit(TypeSArray t)
        {
            d_uns64 arrayoff = offset;
            d_uns64 nextsize = t.next.size();
            d_uns64 dim = t.dim.toInteger();
            for (d_uns64 i = 0; i < dim; i++)
            {
                offset = arrayoff + i * nextsize;
                t.next.accept(this);
            }
            offset = arrayoff;
        }

        override void visit(TypeDArray t)
        {
            setpointer(offset + sz_size_t);
        }

        // dynamic array is {length,ptr}
        override void visit(TypeAArray t)
        {
            setpointer(offset);
        }

        override void visit(TypePointer t)
        {
            if (t.nextOf().ty != Tfunction) // don't mark function pointers
                setpointer(offset);
        }

        override void visit(TypeReference t)
        {
            setpointer(offset);
        }

        override void visit(TypeClass t)
        {
            setpointer(offset);
        }

        override void visit(TypeFunction t)
        {
        }

        override void visit(TypeDelegate t)
        {
            setpointer(offset);
        }

        // delegate is {context, function}
        override void visit(TypeQualified t)
        {
            assert(0);
        }

        // assume resolved
        override void visit(TypeIdentifier t)
        {
            assert(0);
        }

        override void visit(TypeInstance t)
        {
            assert(0);
        }

        override void visit(TypeTypeof t)
        {
            assert(0);
        }

        override void visit(TypeReturn t)
        {
            assert(0);
        }

        override void visit(TypeEnum t)
        {
            visit(cast(Type)t);
        }

        override void visit(TypeTuple t)
        {
            visit(cast(Type)t);
        }

        override void visit(TypeSlice t)
        {
            assert(0);
        }

        override void visit(TypeNull t)
        {
            assert(0);
        }

        override void visit(TypeStruct t)
        {
            d_uns64 structoff = offset;
            for (size_t i = 0; i < t.sym.fields.dim; i++)
            {
                VarDeclaration v = t.sym.fields[i];
                offset = structoff + v.offset;
                if (v.type.ty == Tclass)
                    setpointer(offset);
                else
                    v.type.accept(this);
            }
            offset = structoff;
        }

        // a "toplevel" class is treated as an instance,
        // while TypeClass fields are treated as references
        void visitClass(TypeClass t)
        {
            d_uns64 classoff = offset;
            // skip vtable-ptr and monitor
            if (t.sym.baseClass)
                visitClass(cast(TypeClass)t.sym.baseClass.type);
            for (size_t i = 0; i < t.sym.fields.dim; i++)
            {
                VarDeclaration v = t.sym.fields[i];
                offset = classoff + v.offset;
                v.type.accept(this);
            }
            offset = classoff;
        }

        Array!(d_uns64)* data;
        d_uns64 offset;
        d_uns64 sz_size_t;
    }

    scope PointerBitmapVisitor pbv = new PointerBitmapVisitor(&data, sz_size_t);
    if (t.ty == Tclass)
        pbv.visitClass(cast(TypeClass)t);
    else
        t.accept(pbv);

    auto exps = new Expressions();
    exps.push(new IntegerExp(e.loc, sz, Type.tsize_t));
    for (d_uns64 i = 0; i < cntdata; i++)
        exps.push(new IntegerExp(e.loc, data[cast(size_t)i], Type.tsize_t));

    auto ale = new ArrayLiteralExp(e.loc, exps);
    ale.type = Type.tsize_t.sarrayOf(cntdata + 1);
    return ale;
}

extern (C++) Expression semanticTraits(TraitsExp e, Scope* sc)
{
    static if (LOGSEMANTIC)
    {
        printf("TraitsExp::semantic() %s\n", e.toChars());
    }
    if (e.ident != Id.compiles &&
        e.ident != Id.isSame &&
        e.ident != Id.identifier &&
        e.ident != Id.getProtection)
    {
        if (!TemplateInstance.semanticTiargs(e.loc, sc, e.args, 1))
            return new ErrorExp();
    }

    size_t dim = e.args ? e.args.dim : 0;

    Expression isTypeX(bool function(Type t) fp)
    {
        int result = 0;
        if (!e.args || !e.args.dim)
            goto Lfalse;
        foreach (o; *e.args)
        {
            auto t = getType(o);
            if (!t || !fp(t))
                goto Lfalse;
        }
        result = 1;
    Lfalse:
        return new IntegerExp(e.loc, result, Type.tbool);
    }
    if (e.ident == Id.isArithmetic)
        return isTypeX(t => t.isintegral() || t.isfloating());
    if (e.ident == Id.isFloating)
        return isTypeX(t => t.isfloating());
    if (e.ident == Id.isIntegral)
        return isTypeX(t => t.isintegral());
    if (e.ident == Id.isScalar)
        return isTypeX(t => t.isscalar());
    if (e.ident == Id.isUnsigned)
        return isTypeX(t => t.isunsigned());
    if (e.ident == Id.isAssociativeArray)
        return isTypeX(t => t.toBasetype().ty == Taarray);
    if (e.ident == Id.isStaticArray)
        return isTypeX(t => t.toBasetype().ty == Tsarray);
    if (e.ident == Id.isAbstractClass)
        return isTypeX(t => t.toBasetype().ty == Tclass &&
                               (cast(TypeClass)t.toBasetype()).sym.isAbstract());
    if (e.ident == Id.isFinalClass)
        return isTypeX(t => t.toBasetype().ty == Tclass &&
                            ((cast(TypeClass)t.toBasetype()).sym.storage_class & STCfinal) != 0);

    Expression isSymbolX(bool function(Dsymbol s) fp)
    {
        int result = 0;
        if (!e.args || !e.args.dim)
            goto Lfalse;
        for (size_t i = 0; i < e.args.dim; i++)
        {
            Dsymbol s = getDsymbol((*e.args)[i]);
            if (!s || !fp(s))
                goto Lfalse;
        }
        result = 1;
    Lfalse:
        return new IntegerExp(e.loc, result, Type.tbool);
    }
    if (e.ident == Id.isTemplate)
    {
        return isSymbolX((Dsymbol s)
        {
            return s.toAlias().isOverloadable() &&
                   overloadApply(s, sm => sm.isTemplateDeclaration() !is null) != 0;
        });
    }
    if (e.ident == Id.isPOD)
    {
        if (dim != 1)
            goto Ldimerror;
        auto o = (*e.args)[0];
        auto t = isType(o);
        if (!t)
        {
            e.error("type expected as second argument of __traits %s instead of %s",
                e.ident.toChars(), o.toChars());
            return new ErrorExp();
        }
        auto tb = t.baseElemOf();
        if (tb.ty == Tstruct)
        {
            if ((cast(TypeStruct)tb).sym.isPOD())
                goto Ltrue;
            else
                goto Lfalse;
        }
        goto Ltrue;
    }
    if (e.ident == Id.isNested)
    {
        if (dim != 1)
            goto Ldimerror;
        auto o = (*e.args)[0];
        auto s = getDsymbol(o);
        if (!s)
        {
        }
        else if (auto ad = s.isAggregateDeclaration())
        {
            if (ad.isNested())
                goto Ltrue;
            else
                goto Lfalse;
        }
        else if (auto fd = s.isFuncDeclaration())
        {
            if (fd.isNested())
                goto Ltrue;
            else
                goto Lfalse;
        }
        e.error("aggregate or function expected instead of '%s'", o.toChars());
        return new ErrorExp();
    }

    Expression isFuncX(bool function(FuncDeclaration f) fp)
    {
        int result = 0;
        if (!e.args || !e.args.dim)
            goto Lfalse;
        foreach (o; *e.args)
        {
            auto s = getDsymbol(o);
            if (!s)
                goto Lfalse;
            auto f = s.isFuncDeclaration();
            if (!f || !fp(f))
                goto Lfalse;
        }
        result = 1;
    Lfalse:
        return new IntegerExp(e.loc, result, Type.tbool);
    }
    if (e.ident == Id.isAbstractFunction)
        return isFuncX(f => f.isAbstract());
    if (e.ident == Id.isVirtualFunction)
        return isFuncX(f => f.isVirtual());
    if (e.ident == Id.isVirtualMethod)
        return isFuncX(f => f.isVirtualMethod());
    if (e.ident == Id.isFinalFunction)
        return isFuncX(f => f.isFinalFunc());
    if (e.ident == Id.isOverrideFunction)
        return isFuncX(f => f.isOverride());
    if (e.ident == Id.isStaticFunction)
        return isFuncX(f => !f.needThis() && !f.isNested());

    Expression isDeclX(bool function(Declaration d) fp)
    {
        int result = 0;
        if (!e.args || !e.args.dim)
            goto Lfalse;
        foreach (o; *e.args)
        {
            auto s = getDsymbol(o);
            if (!s)
                goto Lfalse;
            auto d = s.isDeclaration();
            if (!d || !fp(d))
                goto Lfalse;
        }
        result = 1;
    Lfalse:
        return new IntegerExp(e.loc, result, Type.tbool);
    }
    if (e.ident == Id.isRef)
        return isDeclX(d => d.isRef());
    if (e.ident == Id.isOut)
        return isDeclX(d => d.isOut());
    if (e.ident == Id.isLazy)
        return isDeclX(d => (d.storage_class & STClazy) != 0);

    if (e.ident == Id.identifier)
    {
        // Get identifier for symbol as a string literal
        /* Specify 0 for bit 0 of the flags argument to semanticTiargs() so that
         * a symbol should not be folded to a constant.
         * Bit 1 means don't convert Parameter to Type if Parameter has an identifier
         */
        if (!TemplateInstance.semanticTiargs(e.loc, sc, e.args, 2))
            return new ErrorExp();
        if (dim != 1)
            goto Ldimerror;
        auto o = (*e.args)[0];
        auto po = isParameter(o);
        Identifier id;
        if (po)
        {
            id = po.ident;
            assert(id);
        }
        else
        {
            auto s = getDsymbol(o);
            if (!s || !s.ident)
            {
                e.error("argument %s has no identifier", o.toChars());
                return new ErrorExp();
            }
            id = s.ident;
        }
        auto se = new StringExp(e.loc, id.toChars());
        return se.semantic(sc);
    }
    if (e.ident == Id.getProtection)
    {
        if (dim != 1)
            goto Ldimerror;
        Scope* sc2 = sc.push();
        sc2.flags = sc.flags | SCOPEnoaccesscheck;
        bool ok = TemplateInstance.semanticTiargs(e.loc, sc2, e.args, 1);
        sc2.pop();
        if (!ok)
            return new ErrorExp();
        auto o = (*e.args)[0];
        auto s = getDsymbol(o);
        if (!s)
        {
            if (!isError(o))
                e.error("argument %s has no protection", o.toChars());
            return new ErrorExp();
        }
        if (s._scope)
            s.semantic(s._scope);
        const(char)* protName = protectionToChars(s.prot().kind); // TODO: How about package(names)
        assert(protName);
        auto se = new StringExp(e.loc, cast(char*)protName);
        return se.semantic(sc);
    }
    if (e.ident == Id.parent)
    {
        if (dim != 1)
            goto Ldimerror;
        auto o = (*e.args)[0];
        auto s = getDsymbol(o);
        if (s)
        {
            if (FuncDeclaration fd = s.isFuncDeclaration()) // Bugzilla 8943
                s = fd.toAliasFunc();
            if (!s.isImport()) // Bugzilla 8922
                s = s.toParent();
        }
        if (!s || s.isImport())
        {
            e.error("argument %s has no parent", o.toChars());
            return new ErrorExp();
        }
        if (auto f = s.isFuncDeclaration())
        {
            if (auto td = getFuncTemplateDecl(f))
            {
                if (td.overroot) // if not start of overloaded list of TemplateDeclaration's
                    td = td.overroot; // then get the start
                Expression ex = new TemplateExp(e.loc, td, f);
                ex = ex.semantic(sc);
                return ex;
            }
            if (auto fld = f.isFuncLiteralDeclaration())
            {
                // Directly translate to VarExp instead of FuncExp
                Expression ex = new VarExp(e.loc, fld, 1);
                return ex.semantic(sc);
            }
        }
        return DsymbolExp.resolve(e.loc, sc, s, false);
    }
    if (e.ident == Id.hasMember ||
        e.ident == Id.getMember ||
        e.ident == Id.getOverloads ||
        e.ident == Id.getVirtualMethods ||
        e.ident == Id.getVirtualFunctions)
    {
        if (dim != 2)
            goto Ldimerror;
        auto o = (*e.args)[0];
        auto ex = isExpression((*e.args)[1]);
        if (!ex)
        {
            e.error("expression expected as second argument of __traits %s",
                e.ident.toChars());
            return new ErrorExp();
        }
        ex = ex.ctfeInterpret();
        auto se = ex.toStringExp();
        if (!se || se.length() == 0)
        {
            e.error("string expected as second argument of __traits %s instead of %s",
                e.ident.toChars(), ex.toChars());
            return new ErrorExp();
        }
        se = se.toUTF8(sc);
        if (se.sz != 1)
        {
            e.error("string must be chars");
            return new ErrorExp();
        }

        auto id = Identifier.idPool(cast(char*)se.string);

        /* Prefer dsymbol, because it might need some runtime contexts.
         */
        if (auto s = getDsymbol(o))
        {
            if (e.ident == Id.hasMember)
            {
                if (auto sm = s.search(e.loc, id))
                    goto Ltrue;
            }

            ex = new DsymbolExp(e.loc, s);
            ex = new DotIdExp(e.loc, ex, id);
        }
        else if (auto t = isType(o))
            ex = typeDotIdExp(e.loc, t, id);
        else if (auto x = isExpression(o))
            ex = new DotIdExp(e.loc, x, id);
        else
        {
            e.error("invalid first argument");
            return new ErrorExp();
        }
        if (e.ident == Id.hasMember)
        {
            /* Take any errors as meaning it wasn't found
             */
            Scope* sc2 = sc.push();
            ex = ex.trySemantic(sc2);
            sc2.pop();
            if (!ex)
                goto Lfalse;
            else
                goto Ltrue;
        }
        if (e.ident == Id.getMember)
        {
            ex = ex.semantic(sc);
            return ex;
        }
        if (e.ident == Id.getVirtualFunctions ||
            e.ident == Id.getVirtualMethods ||
            e.ident == Id.getOverloads)
        {
            uint errors = global.errors;
            Expression eorig = ex;
            ex = ex.semantic(sc);
            if (errors < global.errors)
                e.error("%s cannot be resolved", eorig.toChars());
            //ex->print();

            /* Create tuple of functions of ex
             */
            FuncDeclaration f;
            if (ex.op == TOKvar)
            {
                VarExp ve = cast(VarExp)ex;
                f = ve.var.isFuncDeclaration();
                ex = null;
            }
            else if (ex.op == TOKdotvar)
            {
                DotVarExp dve = cast(DotVarExp)ex;
                f = dve.var.isFuncDeclaration();
                if (dve.e1.op == TOKdottype || dve.e1.op == TOKthis)
                    ex = null;
                else
                    ex = dve.e1;
            }

            auto exps = new Expressions();
            overloadApply(f, (Dsymbol s)
            {
                auto fd = s.isFuncDeclaration();
                if (!fd)
                    return 0;
                if (e.ident == Id.getVirtualFunctions && !fd.isVirtual())
                    return 0;
                if (e.ident == Id.getVirtualMethods && !fd.isVirtualMethod())
                    return 0;
                auto fa = new FuncAliasDeclaration(fd.ident, fd, 0);
                fa.protection = fd.protection;
                Expression e = ex ? new DotVarExp(Loc(), ex, fa)
                                  : new DsymbolExp(Loc(), fa);
                exps.push(e);
                return 0;
            });

            auto tup = new TupleExp(e.loc, exps);
            return tup.semantic(sc);
        }
        else
            assert(0);
    }
    if (e.ident == Id.classInstanceSize)
    {
        if (dim != 1)
            goto Ldimerror;
        auto o = (*e.args)[0];
        auto s = getDsymbol(o);
        auto cd = s ? s.isClassDeclaration() : null;
        if (!cd)
        {
            e.error("first argument is not a class");
            return new ErrorExp();
        }

        if (cd.sizeok == SIZEOKnone && cd._scope)
            cd.semantic(cd._scope);
        if (cd.sizeok != SIZEOKdone)
        {
            e.error("%s %s is forward referenced", cd.kind(), cd.toChars());
            return new ErrorExp();
        }

        return new IntegerExp(e.loc, cd.structsize, Type.tsize_t);
    }
    if (e.ident == Id.getAliasThis)
    {
        if (dim != 1)
            goto Ldimerror;
        auto o = (*e.args)[0];
        auto s = getDsymbol(o);
        auto ad = s ? s.isAggregateDeclaration() : null;
        if (!ad)
        {
            e.error("argument is not an aggregate type");
            return new ErrorExp();
        }

        auto exps = new Expressions();
        if (ad.aliasthis)
            exps.push(new StringExp(e.loc, ad.aliasthis.ident.toChars()));
        Expression ex = new TupleExp(e.loc, exps);
        ex = ex.semantic(sc);
        return ex;
    }
    if (e.ident == Id.getAttributes)
    {
        if (dim != 1)
            goto Ldimerror;

        auto o = (*e.args)[0];
        auto s = getDsymbol(o);
        if (!s)
        {
            //if (auto x = isExpression(o)) printf("e = %s %s\n", Token.toChars(x.op), x.toChars());
            //if (auto t = isType(o))       printf("t = %d %s\n", t.ty, t.toChars());
            e.error("first argument is not a symbol");
            return new ErrorExp();
        }
        if (auto imp = s.isImport())
            s = imp.mod;

        //printf("getAttributes %s, attrs = %p, scope = %p\n", s->toChars(), s->userAttribDecl, s->scope);
        UserAttributeDeclaration udad = s.userAttribDecl;
        auto tup = new TupleExp(e.loc, udad ? udad.getAttributes() : new Expressions());
        return tup.semantic(sc);
    }

    if (e.ident == Id.getFunctionAttributes)
    {
        /// extract all function attributes as a tuple (const/shared/inout/pure/nothrow/etc) except UDAs.
        if (dim != 1)
            goto Ldimerror;
        auto o = (*e.args)[0];
        auto s = getDsymbol(o);
        auto t = isType(o);
        TypeFunction tf;
        if (s)
        {
            if (auto f = s.isFuncDeclaration())
                t = f.type;
            else if (auto v = s.isVarDeclaration())
                t = v.type;
        }
        if (t)
        {
            if (t.ty == Tfunction)
                tf = cast(TypeFunction)t;
            else if (t.ty == Tdelegate)
                tf = cast(TypeFunction)t.nextOf();
            else if (t.ty == Tpointer && t.nextOf().ty == Tfunction)
                tf = cast(TypeFunction)t.nextOf();
        }
        if (!tf)
        {
            e.error("first argument is not a function");
            return new ErrorExp();
        }

        auto mods = new Expressions();
        tf.modifiersApply((const(char)* str)
        {
            mods.push(new StringExp(Loc(), cast(char*)str));
            return 0;
        });
        tf.attributesApply(TRUSTformatSystem, (const(char)* str)
        {
            mods.push(new StringExp(Loc(), cast(char*)str));
            return 0;
        });

        auto tup = new TupleExp(e.loc, mods);
        return tup.semantic(sc);
    }
    if (e.ident == Id.allMembers || e.ident == Id.derivedMembers)
    {
        if (dim != 1)
            goto Ldimerror;
        auto o = (*e.args)[0];
        auto s = getDsymbol(o);
        if (!s)
        {
            e.error("argument has no members");
            return new ErrorExp();
        }
        if (auto imp = s.isImport())    // Bugzilla 9692
            s = imp.mod;
        auto sds = s.isScopeDsymbol();
        if (!sds || sds.isTemplateDeclaration())
        {
            e.error("%s %s has no members", s.kind(), s.toChars());
            return new ErrorExp();
        }

        auto idents = new Identifiers();

        int pushIdentsDg(size_t n, Dsymbol sm)
        {
            if (!sm)
                return 1;
            //printf("\t[%s] %s %s\n", sm.loc.toChars(), sm.kind(), sm.toChars());
            if (!sm.ident)
            {
                if (auto ed = sm.isEnumDeclaration())
                    ScopeDsymbol._foreach(null, ed.members, &pushIdentsDg);
                return 0;
            }

            if (sm.ident.string[0] == '_' &&
                sm.ident.string[1] == '_' &&
                sm.ident != Id.ctor &&
                sm.ident != Id.dtor &&
                sm.ident != Id.__xdtor &&
                sm.ident != Id.postblit &&
                sm.ident != Id.__xpostblit)
            {
                return 0;
            }
            if (sm.ident == Id.empty)
                return 0;
            //printf("\t%s\n", sm.ident.toChars());

            /* Skip if already present in idents[]
             */
            foreach (id; *idents)
            {
                if (id == sm.ident)
                    return 0;

                // Avoid using strcmp in the first place due to the performance impact in an O(N^2) loop.
                debug assert(strcmp(id.toChars(), sm.ident.toChars()) != 0);
            }
            idents.push(sm.ident);
            return 0;
        }

        ScopeDsymbol._foreach(sc, sds.members, &pushIdentsDg);
        auto cd = sds.isClassDeclaration();
        if (cd && e.ident == Id.allMembers)
        {
            if (cd._scope)
                cd.semantic(null); // Bugzilla 13668: Try to resolve forward reference

            void pushBaseMembersDg(ClassDeclaration cd)
            {
                foreach (b; *cd.baseclasses)
                {
                    auto cb = b.sym;
                    ScopeDsymbol._foreach(null, cb.members, &pushIdentsDg);
                    if (cb.baseclasses.dim)
                        pushBaseMembersDg(cb);
                }
            }
            pushBaseMembersDg(cd);
        }

        // Turn Identifiers into StringExps reusing the allocated array
        assert(Expressions.sizeof == Identifiers.sizeof);
        auto exps = cast(Expressions*)idents;
        foreach (i, id; *idents)
            (*exps)[i] = new StringExp(e.loc, id.toChars());

        /* Making this a tuple is more flexible, as it can be statically unrolled.
         * To make an array literal, enclose __traits in [ ]:
         *   [ __traits(allMembers, ...) ]
         */
        Expression ex = new TupleExp(e.loc, exps);
        ex = ex.semantic(sc);
        return ex;
    }
    if (e.ident == Id.compiles)
    {
        /* Determine if all the objects - types, expressions, or symbols -
         * compile without error
         */
        if (!dim)
            goto Lfalse;
        foreach (size_t i; 0 .. dim)
        {
            uint errors = global.startGagging();
            Scope* sc2 = sc.push();
            sc2.tinst = null;
            sc2.minst = null;
            sc2.flags = (sc.flags & ~(SCOPEctfe | SCOPEcondition)) | SCOPEcompile;
            bool err = false;
            auto o = (*e.args)[i];
            auto t = isType(o);
            auto x = t ? t.toExpression() : isExpression(o);
            if (!x && t)
            {
                Dsymbol s;
                t.resolve(e.loc, sc2, &x, &t, &s);
                if (t)
                {
                    t.semantic(e.loc, sc2);
                    if (t.ty == Terror)
                        err = true;
                }
                else if (s && s.errors)
                    err = true;
            }
            if (x)
            {
                x = x.semantic(sc2);
                x = resolvePropertiesOnly(sc2, x);
                x = x.optimize(WANTvalue);
                if (sc2.func && sc2.func.type.ty == Tfunction)
                {
                    TypeFunction tf = cast(TypeFunction)sc2.func.type;
                    canThrow(x, sc2.func, tf.isnothrow);
                }
                x = checkGC(sc2, x);
                if (x.op == TOKerror)
                    err = true;
            }
            sc2.pop();
            if (global.endGagging(errors) || err)
                goto Lfalse;
        }
        goto Ltrue;
    }
    if (e.ident == Id.isSame)
    {
        /* Determine if two symbols are the same
         */
        if (dim != 2)
            goto Ldimerror;
        if (!TemplateInstance.semanticTiargs(e.loc, sc, e.args, 0))
            return new ErrorExp();
        auto o1 = (*e.args)[0];
        auto o2 = (*e.args)[1];
        auto s1 = getDsymbol(o1);
        auto s2 = getDsymbol(o2);
        //printf("isSame: %s, %s\n", o1->toChars(), o2->toChars());
        version (none)
        {
            printf("o1: %p\n", o1);
            printf("o2: %p\n", o2);
            if (s1)                              printf("%s %s\n", s1.kind(), s1.toChars());
            else if (auto ea = isExpression(o1)) printf("%s\n", ea.toChars());
            else if (auto ta = isType(o1))       printf("%s\n", ta.toChars());
        }
        if (!s1 && !s2)
        {
            auto ea1 = isExpression(o1);
            auto ea2 = isExpression(o2);
            if (ea1 && ea2)
            {
                if (ea1.equals(ea2))
                    goto Ltrue;
            }
        }
        if (!s1 || !s2)
            goto Lfalse;
        s1 = s1.toAlias();
        s2 = s2.toAlias();
        if (auto fa1 = s1.isFuncAliasDeclaration())
            s1 = fa1.toAliasFunc();
        if (auto fa2 = s2.isFuncAliasDeclaration())
            s2 = fa2.toAliasFunc();
        if (s1 == s2)
            goto Ltrue;
        else
            goto Lfalse;
    }
    if (e.ident == Id.getUnitTests)
    {
        if (dim != 1)
            goto Ldimerror;
        auto o = (*e.args)[0];
        auto s = getDsymbol(o);
        if (!s)
        {
            e.error("argument %s to __traits(getUnitTests) must be a module or aggregate", o.toChars());
            return new ErrorExp();
        }
        if (auto imp = s.isImport())    // Bugzilla 10990
            s = imp.mod;
        auto sds = s.isScopeDsymbol();
        if (!sds)
        {
            e.error("argument %s to __traits(getUnitTests) must be a module or aggregate, not a %s", s.toChars(), s.kind());
            return new ErrorExp();
        }

        auto exps = new Expressions();
        if (sds.members && global.params.useUnitTests)
        {
            AA* setUnitTests = null;
            void collect(Dsymbols* a)
            {
                if (!a)
                    return;
                foreach (s; *a)
                {
                    if (auto ud = s.isUnitTestDeclaration())
                    {
                        if (dmd_aaGetRvalue(setUnitTests, cast(void*)ud))
                            continue;

                        auto fa = new FuncAliasDeclaration(ud.ident, ud, 0);
                        fa.protection = ud.protection;
                        exps.push(new DsymbolExp(Loc(), fa));

                        bool* pv = cast(bool*)dmd_aaGet(&setUnitTests, cast(void*)ud);
                        *pv = true;
                    }
                    else if (auto ad = s.isAttribDeclaration())
                    {
                        collect(ad.include(null, null));
                    }
                }
            }
            collect(sds.members);
        }
        auto tup = new TupleExp(e.loc, exps);
        return tup.semantic(sc);
    }
    if (e.ident == Id.getVirtualIndex)
    {
        if (dim != 1)
            goto Ldimerror;
        auto o = (*e.args)[0];
        auto s = getDsymbol(o);
        auto fd = s ? s.isFuncDeclaration() : null;
        if (!fd)
        {
            e.error("first argument to __traits(getVirtualIndex) must be a function");
            return new ErrorExp();
        }
        fd = fd.toAliasFunc(); // Neccessary to support multiple overloads.
        return new IntegerExp(e.loc, fd.vtblIndex, Type.tptrdiff_t);
    }
    if (e.ident == Id.getPointerBitmap)
    {
        return pointerBitmap(e);
    }

    extern (C++) void* trait_search_fp(void* arg, const(char)* seed, int* cost)
    {
        //printf("trait_search_fp('%s')\n", seed);
        size_t len = strlen(seed);
        if (!len)
            return null;
        *cost = 0;
        StringValue* sv = traitsStringTable.lookup(seed, len);
        return sv ? cast(void*)sv.ptrvalue : null;
    }
    assert(0);
    if (auto sub = cast(const(char)*)speller(e.ident.toChars(), &trait_search_fp, null, idchars))
        e.error("unrecognized trait '%s', did you mean '%s'?", e.ident.toChars(), sub);
    else
        e.error("unrecognized trait '%s'", e.ident.toChars());
    return new ErrorExp();

Ldimerror:
    e.error("wrong number of arguments %d", cast(int)dim);
    return new ErrorExp();
Lfalse:
    return new IntegerExp(e.loc, 0, Type.tbool);
Ltrue:
    return new IntegerExp(e.loc, 1, Type.tbool);
}
