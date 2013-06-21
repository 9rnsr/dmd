
// Compiler implementation of the D programming language
// Copyright (c) 1999-2012 by Digital Mars
// All Rights Reserved
// written by Walter Bright
// http://www.digitalmars.com
// License for redistribution is by either the Artistic License
// in artistic.txt, or the GNU General Public License in gnu.txt.
// See the included readme.txt for details.

#include <stdio.h>
#include <string.h>
#include <assert.h>

#include "rmem.h"
#include "speller.h"
#include "aav.h"

#include "mars.h"
#include "dsymbol.h"
#include "aggregate.h"
#include "identifier.h"
#include "module.h"
#include "mtype.h"
#include "expression.h"
#include "statement.h"
#include "declaration.h"
#include "id.h"
#include "scope.h"
#include "init.h"
#include "import.h"
#include "template.h"
#include "attrib.h"
#include "enum.h"

const char* Pprotectionnames[] = {NULL, "none", "private", "package", "protected", "public", "export"};


/****************************** Dsymbol ******************************/

Dsymbol::Dsymbol()
{
    //printf("Dsymbol::Dsymbol(%p)\n", this);
    this->ident = NULL;
    this->parent = NULL;
    this->csym = NULL;
    this->isym = NULL;
    this->loc = Loc();
    this->comment = NULL;
    this->scope = NULL;
    this->errors = false;
    this->depmsg = NULL;
    this->userAttributes = NULL;
    this->unittest = NULL;
}

Dsymbol::Dsymbol(Identifier *ident)
{
    //printf("Dsymbol::Dsymbol(%p, ident)\n", this);
    this->ident = ident;
    this->parent = NULL;
    this->csym = NULL;
    this->isym = NULL;
    this->loc = Loc();
    this->comment = NULL;
    this->scope = NULL;
    this->errors = false;
    this->depmsg = NULL;
    this->userAttributes = NULL;
    this->unittest = NULL;
}

bool Dsymbol::equals(RootObject *o)
{
    if (this == o)
        return true;
    Dsymbol *s = (Dsymbol *)(o);
    // Overload sets don't have an ident
    if (s && ident && s->ident && ident->equals(s->ident))
        return true;
    return false;
}

/**************************************
 * Copy the syntax.
 * Used for template instantiations.
 * If s is NULL, allocate the new object, otherwise fill it in.
 */

Dsymbol *Dsymbol::syntaxCopy(Dsymbol *s)
{
    print();
    printf("%s %s\n", kind(), toChars());
    assert(0);
    return NULL;
}

/**************************************
 * Determine if this symbol is only one.
 * Returns:
 *      false, *ps = NULL: There are 2 or more symbols
 *      true,  *ps = NULL: There are zero symbols
 *      true,  *ps = symbol: The one and only one symbol
 */

bool Dsymbol::oneMember(Dsymbol **ps, Identifier *ident)
{
    //printf("Dsymbol::oneMember()\n");
    *ps = this;
    return true;
}

/*****************************************
 * Same as Dsymbol::oneMember(), but look at an array of Dsymbols.
 */

bool Dsymbol::oneMembers(Dsymbols *members, Dsymbol **ps, Identifier *ident)
{
    //printf("Dsymbol::oneMembers() %d\n", members ? members->dim : 0);
    Dsymbol *s = NULL;

    if (members)
    {
        for (size_t i = 0; i < members->dim; i++)
        {   Dsymbol *sx = (*members)[i];

            bool x = sx->oneMember(ps, ident);
            //printf("\t[%d] kind %s = %d, s = %p\n", i, sx->kind(), x, *ps);
            if (!x)
            {
                //printf("\tfalse 1\n");
                assert(*ps == NULL);
                return false;
            }
            if (*ps)
            {
                if (ident)
                {
                    if (!(*ps)->ident || !(*ps)->ident->equals(ident))
                        continue;
                }
                if (!s)
                    s = *ps;
                else if (s->isOverloadable() && (*ps)->isOverloadable())
                    ;   // keep head of overload set
                else                    // more than one symbol
                {   *ps = NULL;
                    //printf("\tfalse 2\n");
                    return false;
                }
            }
        }
    }
    *ps = s;            // s is the one symbol, NULL if none
    //printf("\ttrue\n");
    return true;
}

/*****************************************
 * Is Dsymbol a variable that contains pointers?
 */

bool Dsymbol::hasPointers()
{
    //printf("Dsymbol::hasPointers() %s\n", toChars());
    return false;
}

bool Dsymbol::hasStaticCtorOrDtor()
{
    //printf("Dsymbol::hasStaticCtorOrDtor() %s\n", toChars());
    return FALSE;
}

void Dsymbol::setFieldOffset(AggregateDeclaration *ad, unsigned *poffset, bool isunion)
{
}

Identifier *Dsymbol::getIdent()
{
    return ident;
}

char *Dsymbol::toChars()
{
    return ident ? ident->toChars() : (char *)"__anonymous";
}

const char *Dsymbol::toPrettyChars()
{   Dsymbol *p;
    char *s;
    char *q;
    size_t len;

    //printf("Dsymbol::toPrettyChars() '%s'\n", toChars());
    if (!parent)
        return toChars();

    len = 0;
    for (p = this; p; p = p->parent)
        len += strlen(p->toChars()) + 1;

    s = (char *)mem.malloc(len);
    q = s + len - 1;
    *q = 0;
    for (p = this; p; p = p->parent)
    {
        char *t = p->toChars();
        len = strlen(t);
        q -= len;
        memcpy(q, t, len);
        if (q == s)
            break;
        q--;
        *q = '.';
    }
    return s;
}

Loc& Dsymbol::getLoc()
{
    if (!loc.filename)  // avoid bug 5861.
    {
        Module *m = getModule();

        if (m && m->srcfile)
            loc.filename = m->srcfile->toChars();
    }
    return loc;
}

char *Dsymbol::locToChars()
{
    return getLoc().toChars();
}

const char *Dsymbol::kind()
{
    return "symbol";
}

/*********************************
 * If this symbol is really an alias for another,
 * return that other.
 */

Dsymbol *Dsymbol::toAlias()
{
    return this;
}

Dsymbol *Dsymbol::toParent()
{
    return parent ? parent->pastMixin() : NULL;
}

Dsymbol *Dsymbol::pastMixin()
{
    Dsymbol *s = this;

    //printf("Dsymbol::pastMixin() %s\n", toChars());
    while (s && s->isTemplateMixin())
        s = s->parent;
    return s;
}

/**********************************
 * Use this instead of toParent() when looking for the
 * 'this' pointer of the enclosing function/class.
 * This skips over both TemplateInstance's and TemplateMixin's.
 */

Dsymbol *Dsymbol::toParent2()
{
    Dsymbol *s = parent;
    while (s && s->isTemplateInstance())
        s = s->parent;
    return s;
}

TemplateInstance *Dsymbol::inTemplateInstance()
{
    for (Dsymbol *parent = this->parent; parent; parent = parent->parent)
    {
        TemplateInstance *ti = parent->isTemplateInstance();
        if (ti)
            return ti;
    }
    return NULL;
}

// Check if this function is a member of a template which has only been
// instantiated speculatively, eg from inside is(typeof()).
// Return the speculative template instance it is part of,
// or NULL if not speculative.
TemplateInstance *Dsymbol::isSpeculative()
{
    Dsymbol * par = parent;
    while (par)
    {
        TemplateInstance *ti = par->isTemplateInstance();
        if (ti && ti->speculative)
            return ti;
        par = par->toParent();
    }
    return NULL;
}

bool Dsymbol::isAnonymous()
{
    return ident == NULL;
}

/*************************************
 * Set scope for future semantic analysis so we can
 * deal better with forward references.
 */

void Dsymbol::setScope(Scope *sc)
{
    //printf("Dsymbol::setScope() %p %s, %p stc = %llx\n", this, toChars(), sc, sc->stc);
    if (!sc->nofree)
        sc->setNoFree();                // may need it even after semantic() finishes
    scope = sc;
    if (sc->depmsg)
        depmsg = sc->depmsg;
}

void Dsymbol::importAll(Scope *sc)
{
}

/*************************************
 * Does semantic analysis on the public face of declarations.
 */

void Dsymbol::semantic0(Scope *sc)
{
}

void Dsymbol::semantic(Scope *sc)
{
    error("%p has no semantic routine", this);
}

/*************************************
 * Does semantic analysis on initializers and members of aggregates.
 */

void Dsymbol::semantic2(Scope *sc)
{
    // Most Dsymbols have no further semantic analysis needed
}

/*************************************
 * Does semantic analysis on function bodies.
 */

void Dsymbol::semantic3(Scope *sc)
{
    // Most Dsymbols have no further semantic analysis needed
}

/*************************************
 * Look for function inlining possibilities.
 */

void Dsymbol::inlineScan()
{
    // Most Dsymbols aren't functions
}

/*********************************************
 * Search for ident as member of s.
 * Input:
 *      flags:  1       don't find private members
 *              2       don't give error messages
 *              4       return NULL if ambiguous
 *              8       don't find imported FQNs
 * Returns:
 *      NULL if not found
 */

Dsymbol *Dsymbol::search(Loc loc, Identifier *ident, int flags)
{
    //printf("Dsymbol::search(this=%p,%s, ident='%s')\n", this, toChars(), ident->toChars());
    return NULL;
}

/***************************************************
 * Search for symbol with correct spelling.
 */

void *symbol_search_fp(void *arg, const char *seed)
{
    /* If not in the lexer's string table, it certainly isn't in the symbol table.
     * Doing this first is a lot faster.
     */
    size_t len = strlen(seed);
    if (!len)
        return NULL;
    StringValue *sv = Lexer::stringtable.lookup(seed, len);
    if (!sv)
        return NULL;
    Identifier *id = (Identifier *)sv->ptrvalue;
    assert(id);

    Dsymbol *s = (Dsymbol *)arg;
    Module::clearCache();
    return (void *)s->search(Loc(), id, 4|2);
}

Dsymbol *Dsymbol::search_correct(Identifier *ident)
{
    if (global.gag)
        return NULL;            // don't do it for speculative compiles; too time consuming

    return (Dsymbol *)speller(ident->toChars(), &symbol_search_fp, this, idchars);
}

/***************************************
 * Search for identifier id as a member of 'this'.
 * id may be a template instance.
 * Returns:
 *      symbol found, NULL if not
 */

Dsymbol *Dsymbol::searchX(Loc loc, Scope *sc, RootObject *id)
{
    //printf("Dsymbol::searchX(this=%p,%s, ident='%s')\n", this, toChars(), ident->toChars());
    Dsymbol *s = toAlias();
    Dsymbol *sm;

    switch (id->dyncast())
    {
        case DYNCAST_IDENTIFIER:
            sm = s->search(loc, (Identifier *)id, 0);
            break;

        case DYNCAST_DSYMBOL:
        {   // It's a template instance
            //printf("\ttemplate instance id\n");
            Dsymbol *st = (Dsymbol *)id;
            TemplateInstance *ti = st->isTemplateInstance();
            Identifier *id = ti->name;
            sm = s->search(loc, id, 0);
            if (!sm)
            {
                sm = s->search_correct(id);
                if (sm)
                    error("template identifier '%s' is not a member of '%s %s', did you mean '%s %s'?",
                          id->toChars(), s->kind(), s->toChars(), sm->kind(), sm->toChars());
                else
                    error("template identifier '%s' is not a member of '%s %s'",
                          id->toChars(), s->kind(), s->toChars());
                return NULL;
            }
            sm = sm->toAlias();
            TemplateDeclaration *td = sm->isTemplateDeclaration();
            if (!td)
            {
                error("%s is not a template, it is a %s", id->toChars(), sm->kind());
                return NULL;
            }
            ti->tempdecl = td;
            if (!ti->semanticRun)
                ti->semantic(sc);
            sm = ti->toAlias();
            break;
        }

        default:
            assert(0);
    }
    return sm;
}

bool Dsymbol::overloadInsert(Dsymbol *s)
{
    //printf("Dsymbol::overloadInsert('%s')\n", s->toChars());
    return false;
}

void Dsymbol::toCBuffer(OutBuffer *buf, HdrGenState *hgs)
{
    buf->writestring(toChars());
}

unsigned Dsymbol::size(Loc loc)
{
    error("Dsymbol '%s' has no size", toChars());
    return 0;
}

bool Dsymbol::isforwardRef()
{
    return false;
}

AggregateDeclaration *Dsymbol::isThis()
{
    return NULL;
}

AggregateDeclaration *Dsymbol::isAggregateMember()      // are we a member of an aggregate?
{
    Dsymbol *parent = toParent();
    if (parent && parent->isAggregateDeclaration())
        return (AggregateDeclaration *)parent;
    return NULL;
}

AggregateDeclaration *Dsymbol::isAggregateMember2()     // are we a member of an aggregate?
{
    Dsymbol *parent = toParent2();
    if (parent && parent->isAggregateDeclaration())
        return (AggregateDeclaration *)parent;
    return NULL;
}

ClassDeclaration *Dsymbol::isClassMember()      // are we a member of a class?
{
    AggregateDeclaration *ad = isAggregateMember();
    return ad ? ad->isClassDeclaration() : NULL;
}

void Dsymbol::defineRef(Dsymbol *s)
{
    assert(0);
}

bool Dsymbol::isExport()
{
    return false;
}

bool Dsymbol::isImportedSymbol()
{
    return false;
}

bool Dsymbol::isDeprecated()
{
    return false;
}

#if DMDV2
bool Dsymbol::isOverloadable()
{
    return false;
}

bool Dsymbol::hasOverloads()
{
    return false;
}
#endif

LabelDsymbol *Dsymbol::isLabel()                // is this a LabelDsymbol()?
{
    return NULL;
}

AggregateDeclaration *Dsymbol::isMember()       // is this a member of an AggregateDeclaration?
{
    //printf("Dsymbol::isMember() %s\n", toChars());
    Dsymbol *parent = toParent();
    //printf("parent is %s %s\n", parent->kind(), parent->toChars());
    return parent ? parent->isAggregateDeclaration() : NULL;
}

Type *Dsymbol::getType()
{
    return NULL;
}

bool Dsymbol::needThis()
{
    return false;
}

int Dsymbol::apply(Dsymbol_apply_ft_t fp, void *param)
{
    return (*fp)(this, param);
}

int Dsymbol::addMember(Scope *sc, ScopeDsymbol *sd, int memnum)
{
    //printf("Dsymbol::addMember('%s')\n", toChars());
    //printf("Dsymbol::addMember(this = %p, '%s' scopesym = '%s')\n", this, toChars(), sd->toChars());
    //printf("Dsymbol::addMember(this = %p, '%s' sd = %p, sd->symtab = %p)\n", this, toChars(), sd, sd->symtab);
    parent = sd;
    if (!isAnonymous())         // no name, so can't add it to symbol table
    {
        if (!sd->symtabInsert(this))    // if name is already defined
        {
            Dsymbol *s2;

            s2 = sd->symtab->lookup(ident);
            if (!s2->overloadInsert(this))
            {
                sd->multiplyDefined(Loc(), this, s2);
            }
        }
        if (sd->isAggregateDeclaration() || sd->isEnumDeclaration())
        {
            if (ident == Id::__sizeof || ident == Id::__xalignof || ident == Id::mangleof)
                error(".%s property cannot be redefined", ident->toChars());
        }
        return 1;
    }
    return 0;
}

void Dsymbol::error(const char *format, ...)
{
    va_list ap;
    va_start(ap, format);
    ::verror(getLoc(), format, ap, kind(), toPrettyChars());
    va_end(ap);
}

void Dsymbol::error(Loc loc, const char *format, ...)
{
    va_list ap;
    va_start(ap, format);
    ::verror(loc, format, ap, kind(), toPrettyChars());
    va_end(ap);
}

void Dsymbol::deprecation(Loc loc, const char *format, ...)
{
    va_list ap;
    va_start(ap, format);
    ::vdeprecation(loc, format, ap, kind(), toPrettyChars());
    va_end(ap);
}

void Dsymbol::deprecation(const char *format, ...)
{
    va_list ap;
    va_start(ap, format);
    ::vdeprecation(getLoc(), format, ap, kind(), toPrettyChars());
    va_end(ap);
}

void Dsymbol::checkDeprecated(Loc loc, Scope *sc)
{
    if (global.params.useDeprecated != 1 && isDeprecated())
    {
        // Don't complain if we're inside a deprecated symbol's scope
        for (Dsymbol *sp = sc->parent; sp; sp = sp->parent)
        {   if (sp->isDeprecated())
                goto L1;
        }

        for (Scope *sc2 = sc; sc2; sc2 = sc2->enclosing)
        {
            if (sc2->scopesym && sc2->scopesym->isDeprecated())
                goto L1;

            // If inside a StorageClassDeclaration that is deprecated
            if (sc2->stc & STCdeprecated)
                goto L1;
        }

        char *message = NULL;
        for (Dsymbol *p = this; p; p = p->parent)
        {
            message = p->depmsg;
            if (message)
                break;
        }

        if (message)
            deprecation(loc, "is deprecated - %s", message);
        else
            deprecation(loc, "is deprecated");
    }

  L1:
    Declaration *d = isDeclaration();
    if (d && d->storage_class & STCdisable)
    {
        if (!(sc->func && sc->func->storage_class & STCdisable))
        {
            if (d->ident == Id::cpctor && d->toParent())
                d->toParent()->error(loc, "is not copyable because it is annotated with @disable");
            else
                error(loc, "is not callable because it is annotated with @disable");
        }
    }
}

/**********************************
 * Determine which Module a Dsymbol is in.
 */

Module *Dsymbol::getModule()
{
    //printf("Dsymbol::getModule()\n");
    TemplateDeclaration *td = getFuncTemplateDecl(this);
    if (td)
        return td->getModule();

    Dsymbol *s = this;
    while (s)
    {
        //printf("\ts = %s '%s'\n", s->kind(), s->toPrettyChars());
        Module *m = s->isModule();
        if (m)
            return m;
        s = s->parent;
    }
    return NULL;
}

/**********************************
 * Determine which Module a Dsymbol is in, as far as access rights go.
 */

Module *Dsymbol::getAccessModule()
{
    //printf("Dsymbol::getAccessModule()\n");
    TemplateDeclaration *td = getFuncTemplateDecl(this);
    if (td)
        return td->getAccessModule();

    Dsymbol *s = this;
    while (s)
    {
        //printf("\ts = %s '%s'\n", s->kind(), s->toPrettyChars());
        Module *m = s->isModule();
        if (m)
            return m;
        TemplateInstance *ti = s->isTemplateInstance();
        if (ti && ti->enclosing)
            /* Because of local template instantiation, the parent isn't where the access
             * rights come from - it's the template declaration
             */
            s = ti->tempdecl;
        else
            s = s->parent;
    }
    return NULL;
}

/*************************************
 */

PROT Dsymbol::prot()
{
    return PROTpublic;
}

/*************************************
 * Do syntax copy of an array of Dsymbol's.
 */


Dsymbols *Dsymbol::arraySyntaxCopy(Dsymbols *a)
{

    Dsymbols *b = NULL;
    if (a)
    {
        b = a->copy();
        for (size_t i = 0; i < b->dim; i++)
        {
            Dsymbol *s = (*b)[i];

            s = s->syntaxCopy(NULL);
            (*b)[i] = s;
        }
    }
    return b;
}


/****************************************
 * Add documentation comment to Dsymbol.
 * Ignore NULL comments.
 */

void Dsymbol::addComment(unsigned char *comment)
{
    //if (comment)
        //printf("adding comment '%s' to symbol %p '%s'\n", comment, this, toChars());

    if (!this->comment)
        this->comment = comment;
#if 1
    else if (comment && strcmp((char *)comment, (char *)this->comment) != 0)
    {   // Concatenate the two
        this->comment = Lexer::combineComments(this->comment, comment);
    }
#endif
}

/********************************* OverloadSet ****************************/

#if DMDV2
OverloadSet::OverloadSet(Identifier *ident)
    : Dsymbol(ident)
{
}

void OverloadSet::push(Dsymbol *s)
{
    a.push(s);
}

const char *OverloadSet::kind()
{
    return "overloadset";
}
#endif


/********************************* ScopeDsymbol ****************************/

ScopeDsymbol::ScopeDsymbol()
    : Dsymbol()
{
    members = NULL;
    symtab = NULL;
    imports = NULL;
    prots = NULL;
    pkgtree = NULL;
}

ScopeDsymbol::ScopeDsymbol(Identifier *id)
    : Dsymbol(id)
{
    members = NULL;
    symtab = NULL;
    imports = NULL;
    prots = NULL;
    pkgtree = NULL;
}

Dsymbol *ScopeDsymbol::syntaxCopy(Dsymbol *s)
{
    //printf("ScopeDsymbol::syntaxCopy('%s')\n", toChars());

    ScopeDsymbol *sd;
    if (s)
        sd = (ScopeDsymbol *)s;
    else
        sd = new ScopeDsymbol(ident);
    sd->members = arraySyntaxCopy(members);
    return sd;
}

Dsymbol *ScopeDsymbol::search(Loc loc, Identifier *ident, int flags)
{
    //printf("%s->ScopeDsymbol::search(ident='%s', flags=x%x)\n", toChars(), ident->toChars(), flags);
    //if (strcmp(ident->toChars(),"c") == 0) *(char*)0=0;

    Package *pkg = isPackage();
    if (pkg)
    {
        if (Module *m = pkg->isPackageMod())
        {
            /* Prefer symbols declared in package.d.
             *
             *  import std.algorithm;
             *  import std; // std/package.d
             *  void main() {
             *      map!(a=>a*2)([1,2,3]);
             *      std.map!(a=>a*2)([1,2,3]);
             *      std.algorithm.map!(a=>a*2)([1,2,3]);
             *      // iff std/package.d doesn't have a symbol named "algorithm",
             *      // std/algorithm.d would hit.
             *  }
             */
            Dsymbol *s = m->search(loc, ident, flags);
            if (s)
                return s;
            //printf("[%s] through pkdmod: %s\n", loc.toChars(), pkg->toChars());
            return pkg->symtab ? pkg->symtab->lookup(ident) : NULL;
        }
        pkg = pkg->enclosingPkg();
    }

    // Look in symbols declared in this module
    Dsymbol *s = symtab ? symtab->lookup(ident) : NULL;
    //printf("\ts = %p, imports = %p, %d\n", s, imports, imports ? imports->dim : 0);
    if (!s && pkg)
    {
        //printf("[%s] pkg = %s, ident = %s\n", loc.toChars(), pkg->toChars(), ident->toChars());
        s = pkg->search(loc, ident, flags);
    }
    if (s)
    {
        //printf("\ts = '%s.%s'\n",toChars(),s->toChars());
    }
    else if (imports)
    {
        OverloadSet *a = NULL;

        // Look in imported modules
        for (size_t i = 0; i < imports->dim; i++)
        {
            // If private import, don't search it
            if ((flags & 1) && prots[i] == PROTprivate)
                continue;

            //printf("\tscanning imports[%d] : %s '%s', prots = %d\n",
            //       i, (*imports)[i]->kind(), (*imports)[i]->toChars(), prots[i]);
            Dsymbol *ss = (*imports)[i];
            Dsymbol *s2 = ss->search(loc, ident, 0);
            if (!s)
                s = s2;
            else if (s2 && s != s2)
            {
                if (s->toAlias() == s2->toAlias() ||
                    s->getType() == s2->getType() && s->getType())
                {
                    /* After following aliases, we found the same
                     * symbol, so it's not an ambiguity.  But if one
                     * alias is deprecated or less accessible, prefer
                     * the other.
                     */
                    if (s->isDeprecated() ||
                        s2->prot() > s->prot() && s2->prot() != PROTnone)
                        s = s2;
                }
                else
                {
                    /* Two imports of the same module should be regarded as
                     * the same.
                     */
                    Import *i1 = s->isImport();
                    Import *i2 = s2->isImport();
                    if (!(i1 && i2 &&
                          (i1->mod == i2->mod ||
                           (!i1->parent->isImport() && !i2->parent->isImport() &&
                            i1->ident->equals(i2->ident))
                          )
                         )
                       )
                    {
                        /* Bugzilla 8668:
                         * Public selective import adds AliasDeclaration in module.
                         * To make an overload set, resolve aliases in here and
                         * get actual overload roots which accessible via s and s2.
                         */
                        s = s->toAlias();
                        s2 = s2->toAlias();

                        /* If both s2 and s are overloadable (though we only
                         * need to check s once)
                         */
                        if (s2->isOverloadable() && (a || s->isOverloadable()))
                        {   if (!a)
                                a = new OverloadSet(s->ident);
                            /* Don't add to a[] if s2 is alias of previous sym
                             */
                            for (size_t j = 0; j < a->a.dim; j++)
                            {   Dsymbol *s3 = a->a[j];
                                if (s2->toAlias() == s3->toAlias())
                                {
                                    if (s3->isDeprecated() ||
                                        s2->prot() > s3->prot() && s2->prot() != PROTnone)
                                        a->a[j] = s2;
                                    goto Lcontinue;
                                }
                            }
                            a->push(s2);
                        Lcontinue:
                            continue;
                        }
                        if (flags & 4)          // if return NULL on ambiguity
                            return NULL;
                        if (!(flags & 2))
                            ScopeDsymbol::multiplyDefined(loc, s, s2);
                        break;
                    }
                }
            }
        }

        if (s)
        {
            /* Build special symbol if we had multiple finds
             */
            if (a)
            {
                a->push(s);
                s = a;
            }

            if (!(flags & 2) && !s->isOverloadable())
            {
                Declaration *d = s->isDeclaration();
                if (d && d->protection == PROTprivate &&
                    !d->parent->isTemplateMixin())
                    error(loc, "%s is private", d->toPrettyChars());

                AggregateDeclaration *ad = s->isAggregateDeclaration();
                if (ad && ad->protection == PROTprivate &&
                    !ad->parent->isTemplateMixin())
                    error(loc, "%s is private", ad->toPrettyChars());

                EnumDeclaration *ed = s->isEnumDeclaration();
                if (ed && ed->protection == PROTprivate &&
                    !ed->parent->isTemplateMixin())
                    error(loc, "%s is private", ed->toPrettyChars());

                //TemplateDeclaration *td = s->isTemplateDeclaration();
                //if (td && td->protection == PROTprivate &&
                //    !td->parent->isTemplateMixin())
                //    error(loc, "%s is private", td->toPrettyChars());
            }
        }
        else if (!(flags & 8))
        {
            for (size_t i = 0; i < imports->dim; i++)
            {
                Dsymbol *ss = (*imports)[i];
                Dsymbol *s2 = NULL;

                if (Import *imp = ss->isImport())
                {
                    Identifier *id;
                    if (imp->aliasId)
                    {
                        if (ident == imp->aliasId)
                            s2 = imp->mod;
                    }
                    else
                    {
                        if (imp->packages && imp->packages->dim)
                            id = (*imp->packages)[0];
                        else
                            id = imp->mod->ident;
                        if (ident == id)
                        {
                            //printf("weak package name lookup : id=%s, ident=%s @, imp = %s\n", id->toChars(), ident->toChars(), imp->loc.toChars());
                        #if 1
                            //if (!imp->parent)
                            //{
                            //    // TODO: function local import
                            //    s2 = imp->pkg;
                            //}
                            //else
                            if (!imp->packages || !imp->packages->dim)
                            {
                                s2 = imp->pkg;
                                //printf("!?-> s2 = %s %s\n", s2->kind(), s2->toChars());
                            }
                            else
                            {
                                //ScopeDsymbol *sds = imp->parent->isScopeDsymbol();
                                //assert(sds);    // todo
                                //if (!sds->pkgtree)
                                //{
                                //    printf("[%s] imp = %s imp->ident = %s\n", imp->loc.toChars(), imp->toChars(), imp->ident->toChars());
                                //}
                                //assert(sds->pkgtree);
                                ScopeDsymbol *sds = this;
                                assert(sds->imports && sds->pkgtree);
                                Dsymbol *sx = sds->pkgtree->lookup(id/*imp->ident*/);
                                if (!sx)
                                {
                                    printf("sds->pkgtree = %p\n", sds->pkgtree);
                                    printf("[%s] imp = %s imp->ident = %s\n", imp->loc.toChars(), imp->toChars(), imp->ident->toChars());
                                }
                                assert(sx);
                                s2 = sx;
                                //printf("!!-> s2 = %s %s\n", s2->kind(), s2->toChars());
                            }
                        #else
                            //DsymbolTable *dst = Package::resolve(/*local-pkg-tree, */imp->packages, NULL, NULL);
                            //s2 = dst->lookup(id);
                            s2 = imp->pkg;  // leftmost package/module
                        #endif
                        }
                    }
                }
                if (!s)
                    s = s2;
                else if (s2 && s != s2)
                {
                    /* never reachable? */
                }
            }
        }
    }
    return s;
}

void ScopeDsymbol::importScope(Dsymbol *s, PROT protection)
{
    //printf("%s->ScopeDsymbol::importScope(%s, %d)\n", toChars(), s->toChars(), protection);

    // No circular or redundant import's
    if (s != this)
    {
        if (!imports)
            imports = new Dsymbols();
        else
        {
            for (size_t i = 0; i < imports->dim; i++)
            {
                Dsymbol *ss = (*imports)[i];
                if (ss == s)                    // if already imported
                {
                    if (protection > prots[i])
                        prots[i] = protection;  // upgrade access
                    return;
                }
            }
        }
        imports->push(s);
        prots = (unsigned char *)mem.realloc(prots, imports->dim * sizeof(prots[0]));
        prots[imports->dim - 1] = protection;
    }
}

Package *findPackage(DsymbolTable *dst, Identifiers *packages, size_t dim)
{
    if (packages && dim)
    {
        assert(dim <= packages->dim);
        Package *pkg;
        for (size_t i = 0; i < dim; i++)
        {
            assert(dst);
            Identifier *pid = (*packages)[i];
            Dsymbol *p = dst->lookup(pid);
            if (!p)
                return NULL;
            pkg = p->isPackage();
            assert(pkg);
            dst = pkg->symtab;
        }
        return pkg;
    }
    return NULL;
}

void ScopeDsymbol::importScope2(Scope *sc, Identifiers *packages, Dsymbol *s)
{
    //printf("%s->ScopeDsymbol::importScope2(%s)\n", toChars(), s->toChars());

    // No circular or redundant import's
    if (s == this)
        return;

    Module *mod = s->isModule();
    if (!sc || !mod)
        return;

    if (!pkgtree)
        pkgtree = new DsymbolTable();
    DsymbolTable *dst = Package::resolve(pkgtree, packages, NULL, NULL);
    if (!dst->insert(mod))
    {
        // conflict error is already reported in Module::parse()
        return;
    }

    /* Make links from inner packages to the corresponding outer packages.
     *
     *  import std.algorithm;
     *  // In here, local package tree [A] have a Package 'std' (a),
     *  // and it contains a module 'algorithm'.
     *
     *  class C {
     *    import std.range;
     *    // In here, local package tree [B] contains a Package 'std' (b),
     *    // and it contains a module 'range'.
     *
     *    void test() {
     *      std.algorith.map!(a=>a*2)(...);
     *      // 'algorithm' doesn't exist in (b)->symtab, so (b) should have
     *      // a link to (a).
     *    }
     *  }
     *
     * After that, (b)->enclosingPkg() will return (a).
     */
    if (packages)
    {
        dst = pkgtree;
        //printf("insert mod %s into pkgtree(%p) under %s\n", mod->toChars(), pkgtree, parent->toChars());

        // Find enclosing scope
        Scope *scx = sc;
        while (scx && scx->scopesym != this)
            scx = scx->enclosing;
        assert(scx && scx->scopesym == this);
        scx = scx->enclosing;
        if (!scx)
            return;

        for (size_t i = 0; i < packages->dim; i++)
        {
            assert(dst);
            Dsymbol *s = dst->lookup((*packages)[i]);
            assert(s);
            Package *inn_pkg = s->isPackage();
            assert(inn_pkg);

            Package *out_pkg = NULL;
            for (; scx; scx = scx->enclosing)
            {
                if (!scx->scopesym)
                    continue;
                //printf("\t+ scx->scopesym = x%p %s\n", scx->scopesym, scx->scopesym->toChars());
                if (!scx->scopesym->pkgtree)
                    continue;

                out_pkg = findPackage(scx->scopesym->pkgtree, packages, i + 1);
                if (!out_pkg)
                    continue;

                /* Importing package.d hides outer scope imports, so
                 * further searching is not necessary.
                 *
                 *  import std.algorithm;
                 *  class C1 {
                 *    import std;
                 *    // Here is 'scx->scopesym'
                 *    // out_pkg == 'std' (isPackageMod() != NULL)
                 *
                 *    class C2 {
                 *      import std.range;
                 *      // Here is 'this'
                 *      // inn_pkg == 'std' (isPackageMod() == NULL)
                 *
                 *      void test() {
                 *        auto r1 = std.range.iota(10);   // OK
                 *        auto r2 = std.algorithm.map!(a=>a*2)([1,2,3]);   // NG
                 *        // std.range is accessible, but
                 *        // std.algorithm isn't. Because identifier
                 *        // 'algorithm' is found in std/package.d
                 *      }
                 *    }
                 *  }
                 */
                if (out_pkg->isPkgMod == PKGmodule)
                    return;

                //printf("link out(%s:%p) to (%s:%p)\n", out_pkg->toPrettyChars(), out_pkg, inn_pkg->toPrettyChars(), inn_pkg);
                inn_pkg->aliased = out_pkg;
                break;
            }

            /* There's no corresponding package in enclosing scope, so
             * further searching is not necessary.
             */
            if (!out_pkg)
                break;

            dst = inn_pkg->symtab;
        }
    }
}

bool ScopeDsymbol::isforwardRef()
{
    return (members == NULL);
}

void ScopeDsymbol::defineRef(Dsymbol *s)
{
    ScopeDsymbol *ss;

    ss = s->isScopeDsymbol();
    members = ss->members;
    ss->members = NULL;
}

void ScopeDsymbol::multiplyDefined(Loc loc, Dsymbol *s1, Dsymbol *s2)
{
#if 0
    printf("ScopeDsymbol::multiplyDefined()\n");
    printf("s1 = %p, '%s' kind = '%s', parent = %s\n", s1, s1->toChars(), s1->kind(), s1->parent ? s1->parent->toChars() : "");
    printf("s2 = %p, '%s' kind = '%s', parent = %s\n", s2, s2->toChars(), s2->kind(), s2->parent ? s2->parent->toChars() : "");
#endif
    if (loc.filename)
    {   ::error(loc, "%s at %s conflicts with %s at %s",
            s1->toPrettyChars(),
            s1->locToChars(),
            s2->toPrettyChars(),
            s2->locToChars());
    }
    else
    {
        s1->error(s1->loc, "conflicts with %s %s at %s",
            s2->kind(),
            s2->toPrettyChars(),
            s2->locToChars());
    }
}

Dsymbol *ScopeDsymbol::nameCollision(Dsymbol *s)
{
    Dsymbol *sprev;

    // Look to see if we are defining a forward referenced symbol

    sprev = symtab->lookup(s->ident);
    assert(sprev);
    if (s->equals(sprev))               // if the same symbol
    {
        if (s->isforwardRef())          // if second declaration is a forward reference
            return sprev;
        if (sprev->isforwardRef())
        {
            sprev->defineRef(s);        // copy data from s into sprev
            return sprev;
        }
    }
    multiplyDefined(Loc(), s, sprev);
    return sprev;
}

const char *ScopeDsymbol::kind()
{
    return "ScopeDsymbol";
}

Dsymbol *ScopeDsymbol::symtabInsert(Dsymbol *s)
{
    return symtab->insert(s);
}

/****************************************
 * Return true if any of the members are static ctors or static dtors, or if
 * any members have members that are.
 */

bool ScopeDsymbol::hasStaticCtorOrDtor()
{
    if (members)
    {
        for (size_t i = 0; i < members->dim; i++)
        {   Dsymbol *member = (*members)[i];

            if (member->hasStaticCtorOrDtor())
                return TRUE;
        }
    }
    return FALSE;
}

/***************************************
 * Determine number of Dsymbols, folding in AttribDeclaration members.
 */

#if DMDV2
static int dimDg(void *ctx, size_t n, Dsymbol *)
{
    ++*(size_t *)ctx;
    return 0;
}

size_t ScopeDsymbol::dim(Dsymbols *members)
{
    size_t n = 0;
    foreach(NULL, members, &dimDg, &n);
    return n;
}
#endif

/***************************************
 * Get nth Dsymbol, folding in AttribDeclaration members.
 * Returns:
 *      Dsymbol*        nth Dsymbol
 *      NULL            not found, *pn gets incremented by the number
 *                      of Dsymbols
 */

#if DMDV2
struct GetNthSymbolCtx
{
    size_t nth;
    Dsymbol *sym;
};

static int getNthSymbolDg(void *ctx, size_t n, Dsymbol *sym)
{
    GetNthSymbolCtx *p = (GetNthSymbolCtx *)ctx;
    if (n == p->nth)
    {   p->sym = sym;
        return 1;
    }
    return 0;
}

Dsymbol *ScopeDsymbol::getNth(Dsymbols *members, size_t nth, size_t *pn)
{
    GetNthSymbolCtx ctx = { nth, NULL };
    int res = foreach(NULL, members, &getNthSymbolDg, &ctx);
    return res ? ctx.sym : NULL;
}
#endif

/***************************************
 * Expands attribute declarations in members in depth first
 * order. Calls dg(void *ctx, size_t symidx, Dsymbol *sym) for each
 * member.
 * If dg returns !=0, stops and returns that value else returns 0.
 * Use this function to avoid the O(N + N^2/2) complexity of
 * calculating dim and calling N times getNth.
 */

#if DMDV2
int ScopeDsymbol::foreach(Scope *sc, Dsymbols *members, ScopeDsymbol::ForeachDg dg, void *ctx, size_t *pn)
{
    assert(dg);
    if (!members)
        return 0;

    size_t n = pn ? *pn : 0; // take over index
    int result = 0;
    for (size_t i = 0; i < members->dim; i++)
    {   Dsymbol *s = (*members)[i];

        if (AttribDeclaration *a = s->isAttribDeclaration())
            result = foreach(sc, a->include(sc, NULL), dg, ctx, &n);
        else if (TemplateMixin *tm = s->isTemplateMixin())
            result = foreach(sc, tm->members, dg, ctx, &n);
        else if (s->isTemplateInstance())
            ;
        else if (s->isUnitTestDeclaration())
            ;
        else
            result = dg(ctx, n++, s);

        if (result)
            break;
    }

    if (pn)
        *pn = n; // update index
    return result;
}
#endif

/*******************************************
 * Look for member of the form:
 *      const(MemberInfo)[] getMembers(string);
 * Returns NULL if not found
 */

#if DMDV2
FuncDeclaration *ScopeDsymbol::findGetMembers()
{
    Dsymbol *s = search_function(this, Id::getmembers);
    FuncDeclaration *fdx = s ? s->isFuncDeclaration() : NULL;

#if 0  // Finish
    static TypeFunction *tfgetmembers;

    if (!tfgetmembers)
    {
        Scope sc;
        Parameters *arguments = new Parameters;
        Parameters *arg = new Parameter(STCin, Type::tchar->constOf()->arrayOf(), NULL, NULL);
        arguments->push(arg);

        Type *tret = NULL;
        tfgetmembers = new TypeFunction(arguments, tret, 0, LINKd);
        tfgetmembers = (TypeFunction *)tfgetmembers->semantic(Loc(), &sc);
    }
    if (fdx)
        fdx = fdx->overloadExactMatch(tfgetmembers);
#endif
    if (fdx && fdx->isVirtual())
        fdx = NULL;

    return fdx;
}
#endif


/****************************** WithScopeSymbol ******************************/

WithScopeSymbol::WithScopeSymbol(WithStatement *withstate)
    : ScopeDsymbol()
{
    this->withstate = withstate;
}

Dsymbol *WithScopeSymbol::search(Loc loc, Identifier *ident, int flags)
{
    // Acts as proxy to the with class declaration
    return withstate->exp->type->toDsymbol(NULL)->search(loc, ident, 0);
}

/****************************** ArrayScopeSymbol ******************************/

ArrayScopeSymbol::ArrayScopeSymbol(Scope *sc, Expression *e)
    : ScopeDsymbol()
{
    assert(e->op == TOKindex || e->op == TOKslice || e->op == TOKarray);
    exp = e;
    type = NULL;
    td = NULL;
    this->sc = sc;
}

ArrayScopeSymbol::ArrayScopeSymbol(Scope *sc, TypeTuple *t)
    : ScopeDsymbol()
{
    exp = NULL;
    type = t;
    td = NULL;
    this->sc = sc;
}

ArrayScopeSymbol::ArrayScopeSymbol(Scope *sc, TupleDeclaration *s)
    : ScopeDsymbol()
{
    exp = NULL;
    type = NULL;
    td = s;
    this->sc = sc;
}

Dsymbol *ArrayScopeSymbol::search(Loc loc, Identifier *ident, int flags)
{
    //printf("ArrayScopeSymbol::search('%s', flags = %d)\n", ident->toChars(), flags);
    if (ident == Id::dollar)
    {   VarDeclaration **pvar;
        Expression *ce;

    L1:

        if (td)
        {   /* $ gives the number of elements in the tuple
             */
            VarDeclaration *v = new VarDeclaration(loc, Type::tsize_t, Id::dollar, NULL);
            Expression *e = new IntegerExp(Loc(), td->objects->dim, Type::tsize_t);
            v->init = new ExpInitializer(Loc(), e);
            v->storage_class |= STCstatic | STCconst;
            v->semantic(sc);
            return v;
        }

        if (type)
        {   /* $ gives the number of type entries in the type tuple
             */
            VarDeclaration *v = new VarDeclaration(loc, Type::tsize_t, Id::dollar, NULL);
            Expression *e = new IntegerExp(Loc(), type->arguments->dim, Type::tsize_t);
            v->init = new ExpInitializer(Loc(), e);
            v->storage_class |= STCstatic | STCconst;
            v->semantic(sc);
            return v;
        }

        if (exp->op == TOKindex)
        {   /* array[index] where index is some function of $
             */
            IndexExp *ie = (IndexExp *)exp;

            pvar = &ie->lengthVar;
            ce = ie->e1;
        }
        else if (exp->op == TOKslice)
        {   /* array[lwr .. upr] where lwr or upr is some function of $
             */
            SliceExp *se = (SliceExp *)exp;

            pvar = &se->lengthVar;
            ce = se->e1;
        }
        else if (exp->op == TOKarray)
        {   /* array[e0, e1, e2, e3] where e0, e1, e2 are some function of $
             * $ is a opDollar!(dim)() where dim is the dimension(0,1,2,...)
             */
            ArrayExp *ae = (ArrayExp *)exp;

            pvar = &ae->lengthVar;
            ce = ae->e1;
        }
        else
            /* Didn't find $, look in enclosing scope(s).
             */
            return NULL;

        while (ce->op == TOKcomma)
            ce = ((CommaExp *)ce)->e2;

        /* If we are indexing into an array that is really a type
         * tuple, rewrite this as an index into a type tuple and
         * try again.
         */
        if (ce->op == TOKtype)
        {
            Type *t = ((TypeExp *)ce)->type;
            if (t->ty == Ttuple)
            {   type = (TypeTuple *)t;
                goto L1;
            }
        }

        /* *pvar is lazily initialized, so if we refer to $
         * multiple times, it gets set only once.
         */
        if (!*pvar)             // if not already initialized
        {   /* Create variable v and set it to the value of $
             */
            VarDeclaration *v;
            Type *t;
            if (ce->op == TOKtuple)
            {   /* It is for an expression tuple, so the
                 * length will be a const.
                 */
                Expression *e = new IntegerExp(Loc(), ((TupleExp *)ce)->exps->dim, Type::tsize_t);
                v = new VarDeclaration(loc, Type::tsize_t, Id::dollar, new ExpInitializer(Loc(), e));
                v->storage_class |= STCstatic | STCconst;
            }
            else if (ce->type && (t = ce->type->toBasetype()) != NULL &&
                     (t->ty == Tstruct || t->ty == Tclass))
            {   // Look for opDollar
                assert(exp->op == TOKarray || exp->op == TOKslice);
                AggregateDeclaration *ad = NULL;

                if (t->ty == Tclass)
                {
                    ad = ((TypeClass *)t)->sym;
                }
                else if (t->ty == Tstruct)
                {
                    ad = ((TypeStruct *)t)->sym;
                }
                assert(ad);

                Dsymbol *s = ad->search(loc, Id::opDollar, 0);
                if (!s)  // no dollar exists -- search in higher scope
                    return NULL;
                s = s->toAlias();

                if (ce->hasSideEffect())
                {
                    /* Even if opDollar is needed, 'ce' should be evaluate only once. So
                     * Rewrite:
                     *      ce.opIndex( ... use of $ ... )
                     *      ce.opSlice( ... use of $ ... )
                     * as:
                     *      (ref __dop = ce, __dop).opIndex( ... __dop.opDollar ...)
                     *      (ref __dop = ce, __dop).opSlice( ... __dop.opDollar ...)
                     */
                    Identifier *id = Lexer::uniqueId("__dop");
                    ExpInitializer *ei = new ExpInitializer(loc, ce);
                    VarDeclaration *v = new VarDeclaration(loc, NULL, id, ei);
                    v->storage_class |= STCctfe | STCforeach | STCref;
                    DeclarationExp *de = new DeclarationExp(loc, v);
                    VarExp *ve = new VarExp(loc, v);
                    v->semantic(sc);
                    de->type = ce->type;
                    ve->type = ce->type;
                    ((UnaExp *)exp)->e1 = new CommaExp(loc, de, ve);
                    ce = ve;
                }

                Expression *e = NULL;
                // Check for multi-dimensional opDollar(dim) template.
                if (TemplateDeclaration *td = s->isTemplateDeclaration())
                {
                    dinteger_t dim;
                    if (exp->op == TOKarray)
                    {
                        dim = ((ArrayExp *)exp)->currentDimension;
                    }
                    else if (exp->op == TOKslice)
                    {
                        dim = 0; // slices are currently always one-dimensional
                    }

                    Objects *tdargs = new Objects();
                    Expression *edim = new IntegerExp(Loc(), dim, Type::tsize_t);
                    edim = edim->semantic(sc);
                    tdargs->push(edim);

                    //TemplateInstance *ti = new TemplateInstance(loc, td, tdargs);
                    //ti->semantic(sc);

                    e = new DotTemplateInstanceExp(loc, ce, td->ident, tdargs);
                }
                else
                {   /* opDollar exists, but it's not a template.
                     * This is acceptable ONLY for single-dimension indexing.
                     * Note that it's impossible to have both template & function opDollar,
                     * because both take no arguments.
                     */
                    if (exp->op == TOKarray && ((ArrayExp *)exp)->arguments->dim != 1)
                    {
                        exp->error("%s only defines opDollar for one dimension", ad->toChars());
                        return NULL;
                    }
                    Declaration *d = s->isDeclaration();
                    assert(d);
                    e = new DotVarExp(loc, ce, d);
                }
                e = e->semantic(sc);
                if (!e->type)
                    exp->error("%s has no value", e->toChars());
                t = e->type->toBasetype();
                if (t && t->ty == Tfunction)
                    e = new CallExp(e->loc, e);
                v = new VarDeclaration(loc, NULL, Id::dollar, new ExpInitializer(Loc(), e));
            }
            else
            {   /* For arrays, $ will either be a compile-time constant
                 * (in which case its value in set during constant-folding),
                 * or a variable (in which case an expression is created in
                 * toir.c).
                 */
                VoidInitializer *e = new VoidInitializer(Loc());
                e->type = Type::tsize_t;
                v = new VarDeclaration(loc, Type::tsize_t, Id::dollar, e);
                v->storage_class |= STCctfe; // it's never a true static variable
            }
            *pvar = v;
        }
        (*pvar)->semantic(sc);
        return (*pvar);
    }
    return NULL;
}


/****************************** DsymbolTable ******************************/

DsymbolTable::DsymbolTable()
{
    tab = NULL;
}

Dsymbol *DsymbolTable::lookup(Identifier *ident)
{
    //printf("DsymbolTable::lookup(%s)\n", (char*)ident->string);
    return (Dsymbol *)_aaGetRvalue(tab, ident);
}

Dsymbol *DsymbolTable::insert(Dsymbol *s)
{
    //printf("DsymbolTable::insert(this = %p, '%s')\n", this, s->ident->toChars());
    Identifier *ident = s->ident;
    Dsymbol **ps = (Dsymbol **)_aaGet(&tab, ident);
    if (*ps)
        return NULL;            // already in table
    *ps = s;
    return s;
}

Dsymbol *DsymbolTable::insert(Identifier *ident, Dsymbol *s)
{
    //printf("DsymbolTable::insert()\n");
    Dsymbol **ps = (Dsymbol **)_aaGet(&tab, ident);
    if (*ps)
        return NULL;            // already in table
    *ps = s;
    return s;
}

Dsymbol *DsymbolTable::update(Dsymbol *s)
{
    Identifier *ident = s->ident;
    Dsymbol **ps = (Dsymbol **)_aaGet(&tab, ident);
    *ps = s;
    return s;
}




