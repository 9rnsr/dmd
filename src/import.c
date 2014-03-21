
// Compiler implementation of the D programming language
// Copyright (c) 1999-2012 by Digital Mars
// All Rights Reserved
// written by Walter Bright
// http://www.digitalmars.com
// License for redistribution is by either the Artistic License
// in artistic.txt, or the GNU General Public License in gnu.txt.
// See the included readme.txt for details.

#include <stdio.h>
#include <assert.h>

#include "root.h"
#include "dsymbol.h"
#include "import.h"
#include "identifier.h"
#include "module.h"
#include "scope.h"
#include "hdrgen.h"
#include "mtype.h"
#include "declaration.h"
#include "id.h"
#include "attrib.h"

Package *findPackage(DsymbolTable *dst, Identifiers *packages, size_t dim)
{
    if (!packages || !dim)
        return NULL;
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

/********************************* Import ****************************/

Import::Import(Loc loc, Identifiers *packages, Identifier *id, Identifier *aliasId,
        int isstatic)
    : Dsymbol(NULL)
{
    assert(id);
#if 0
    printf("Import::Import(");
    if (packages && packages->dim)
    {
        for (size_t i = 0; i < packages->dim; i++)
        {
            Identifier *id = (*packages)[i];
            printf("%s.", id->toChars());
        }
    }
    printf("%s)\n", id->toChars());
#endif
    this->loc = loc;
    this->packages = packages;
    this->id = id;
    this->aliasId = aliasId;
    this->isstatic = isstatic;
    this->protection = PROTprivate; // default to private
    this->pkg = NULL;
    this->mod = NULL;
    this->overnext = NULL;

    // Set symbol name (bracketed)
    if (aliasId)
    {
        // import [cstdio] = std.stdio;
        this->ident = aliasId;
    }
    else if (packages && packages->dim)
    {
        // import [std].stdio;
        this->ident = (*packages)[0];
    }
    else
    {
        // import [foo];
        this->ident = id;
    }
}

void Import::addAlias(Identifier *name, Identifier *alias)
{
    if (isstatic)
        error("cannot have an import bind list");

    if (!aliasId)
        this->ident = NULL;     // make it an anonymous import

    names.push(name);
    aliases.push(alias);
}

const char *Import::kind()
{
    return isstatic ? (char *)"static import" : (char *)"import";
}

PROT Import::prot()
{
    return protection;
}

Dsymbol *Import::syntaxCopy(Dsymbol *s)
{
    assert(!s);

    Import *si = new Import(loc, packages, id, aliasId, isstatic);

    for (size_t i = 0; i < names.dim; i++)
    {
        si->addAlias(names[i], aliases[i]);
    }

    return si;
}

void Import::load(Scope *sc)
{
    //printf("Import::load('%s') %p\n", toPrettyChars(), this);

    // See if existing module
    Package *pkg = NULL;    // hide this->pkg
    DsymbolTable *dst = Package::resolve(packages, NULL, &pkg);
#if 0
    if (pkg && pkg->isModule())
    {
        ::error(loc, "can only import from a module, not from a member of module %s. Did you mean `import %s : %s`?",
             pkg->toChars(), pkg->toPrettyChars(), id->toChars());
        mod = pkg->isModule(); // Error recovery - treat as import of that module
        return;
    }
#endif
    Dsymbol *s = dst->lookup(id);
    if (s)
    {
        if (s->isModule())
            mod = (Module *)s;
        else
        {
            if (s->isAliasDeclaration())
            {
                ::error(loc, "%s %s conflicts with %s", s->kind(), s->toPrettyChars(), id->toChars());
            }
            else if (Package *p = s->isPackage())
            {
                if (p->isPkgMod == PKGunknown)
                {
                    mod = Module::load(loc, packages, id);
                    if (!mod)
                        p->isPkgMod = PKGpackage;
                    else
                        assert(p->isPkgMod == PKGmodule);
                }
                else
                {
                    mod = p->isPackageMod();
                }
                if (!mod)
                {
                    ::error(loc, "can only import from a module, not from package %s.%s",
                        p->toPrettyChars(), id->toChars());
                }
            }
            else if (pkg)
            {
                ::error(loc, "can only import from a module, not from package %s.%s",
                    pkg->toPrettyChars(), id->toChars());
            }
            else
            {
                ::error(loc, "can only import from a module, not from package %s",
                    id->toChars());
            }
        }
    }

    if (!mod)
    {
        // Load module
        mod = Module::load(loc, packages, id);
        if (mod)
        {
            dst->insert(id, mod);           // id may be different from mod->ident,
                                            // if so then insert alias
        }
    }
    if (mod && !mod->importedFrom)
        mod->importedFrom = sc ? sc->module->importedFrom : Module::rootModule;
//    if (!pkg)
//        pkg = mod;

    //printf("-Import::load('%s'), pkg = %p\n", toChars(), pkg);
}

void Import::importAll(Scope *sc)
{
    if (!mod)
    {
        load(sc);
        if (mod)                // if successfully loaded module
        {
            mod->importAll(NULL);

            if (sc->explicitProtection)
                protection = sc->protection;
            importScope(sc);
        }
    }
}

/********************************************
 * Add import declaration in scope local package tree.
 *  --> should be moved in importAll?
 */
void Import::importScope(Scope *sc)
{
#if 0
    {
        OutBuffer buf;
        HdrGenState hgs;
        toCBuffer(&buf, &hgs);
#if _WIN32
        buf.data[buf.offset - 2] = 0;   // overwrite '\r\n'
#else
        buf.data[buf.offset - 1] = 0;   // overwrite '\n'
#endif
        printf("importScope('%s') [%s] isPackageFile = %d\n", buf.data, loc.toChars(), mod->isPackageFile);
    }
#endif

    Scope *scx = sc;
    for (; scx; scx = scx->enclosing)
    {
        if (scx->scopesym)
            break;
    }
    if (!scx)
        return;
    // add 'this' to sds->imports
    ScopeDsymbol *sds = scx->scopesym;

    if (!isstatic && !aliasId)  // If 'this' is basic import
        sds->importScope(this, protection);

    if (!sds->pkgtab)
        sds->pkgtab = new DsymbolTable();

    /* Insert the fully qualified name of imported module
     * in local package tree.
     */
    Package *pkg = NULL;    // rightmost package
    DsymbolTable *dst;      // rightmost DsymbolTable
    Identifier *id;         // rightmost import identifier:
    Dsymbol *ss = this;     // local package tree stores Import instead of Module
    if (aliasId)
    {
        dst = sds->pkgtab;
        id = aliasId;       // import [A] = std.stdio;
        this->pkg = mod;
    }
    else
    {
        dst = Package::resolve(sds->pkgtab, packages, &pkg, &this->pkg);
        id = this->id;      // import std.[stdio];
        if (!this->pkg)
            this->pkg = mod;

        if (mod->isPackageFile)
        {
            /* If the loaded module is a package.d, it will be storead
             * in local package tree as Package.
             */
            Package *p = new Package(id);
            p->parent = pkg;    // may be NULL
            p->isPkgMod = PKGmodule;
            p->aliassym = this;
            p->symtab = new DsymbolTable();
            ss = p;
        }
    }
    if (dst->insert(id, ss))
    {
        /* Make links from inner packages to the corresponding outer packages.
         *
         *  import std.algorithm;
         *  // In here, local pkgtab have a Package 'std' (a),
         *  // and it contains a module 'algorithm'.
         *
         *  class C {
         *    import std.range;
         *    // In here, local pkgtab contains a Package 'std' (b),
         *    // and it contains a module 'range'.
         *
         *    void test() {
         *      std.algorithm.map!(a=>a*2)(...);
         *      // 'algorithm' doesn't exist in (b)->symtab, so (b) should have
         *      // a link to (a).
         *    }
         *  }
         *
         * After following, (b)->enclosingPkg() will return (a).
         */
        if (!pkg)
            return;
        assert(packages);
        dst = sds->pkgtab;
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
                if (!scx->scopesym || !scx->scopesym->pkgtab)
                    continue;

                out_pkg = findPackage(scx->scopesym->pkgtab, packages, i + 1);
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
                if (out_pkg->isPackageMod())
                    return;

                //printf("link out(%s:%p) to (%s:%p)\n", out_pkg->toPrettyChars(), out_pkg, inn_pkg->toPrettyChars(), inn_pkg);
                inn_pkg->aliassym = out_pkg;
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
    else
    {
        Dsymbol *prev = dst->lookup(id);
        assert(prev);
        if (Import *imp = prev->isImport())
        {
            if (imp == this)
                return;
            if (imp->mod == mod)
            {
                /* OK:
                 *  import A = std.algorithm : find;
                 *  import A = std.algorithm : filter;
                 */
                Import **pimp = &imp->overnext;
                while (*pimp)
                {
                    if (*pimp == this)
                        return;
                    pimp = &(*pimp)->overnext;
                }
                (*pimp) = this;
            }
            else
            {
                /* NG:
                 *  import A = std.algorithm;
                 *  import A = std.stdio;
                 */
                error("import '%s' conflicts with import '%s'", toChars(), prev->toChars());
            }
        }
        else
        {
            Package *pkg = prev->isPackage();
            assert(pkg);
            //printf("[%s] pkg = %d, pkg->aliassym = %p, mod = %p, mod->isPackageFile = %d\n", loc.toChars(), pkg->isPkgMod, pkg->aliassym, mod, mod->isPackageFile);
            if (pkg->isPkgMod == PKGunknown && mod->isPackageFile)
            {
                /* OK:
                 *  import std.datetime;
                 *  import std;  // std/package.d
                 */
                pkg->isPkgMod = PKGmodule;
                pkg->aliassym = this;
            }
            else if (pkg->isPackageMod() == mod)
            {
                /* OK:
                 *  import std;  // std/package.d
                 *  import std: writeln;
                 */
                Import *imp = pkg->aliassym->isImport();
                assert(imp);
                Import **pimp = &imp->overnext;
                while (*pimp)
                {
                    if (*pimp == this)
                        return;
                    pimp = &(*pimp)->overnext;
                }
                (*pimp) = this;
            }
            else
            {
                /* NG:
                 *  import std.stdio;
                 *  import std = std.algorithm;
                 */
                error("import '%s' conflicts with package '%s'", toChars(), prev->toChars());
            }
        }
    }
}

void Import::semantic(Scope *sc)
{
    //printf("Import::semantic('%s')\n", toPrettyChars());

    if (scope)
    {
        sc = scope;
        scope = NULL;
    }

    // Load if not already done so
    importAll(sc);

    if (mod)
    {
        // Modules need a list of each imported module
        //printf("%s imports %s\n", sc->module->toChars(), mod->toChars());
        sc->module->aimports.push(mod);

        mod->semantic();

        if (mod->needmoduleinfo)
        {
            //printf("module4 %s because of %s\n", sc->module->toChars(), mod->toChars());
            sc->module->needmoduleinfo = 1;
        }

        sc = sc->push(mod);
        /* BUG: Protection checks can't be enabled yet. The issue is
         * that Dsymbol::search errors before overload resolution.
         */
#if 0
        sc->protection = protection;
#else
        sc->protection = PROTpublic;
#endif
        for (size_t i = 0; i < names.dim; i++)
        {
            AliasDeclaration *ad = aliasdecls[i];
            //printf("\tImport alias semantic('%s')\n", ad->toChars());
            if (mod->search(loc, names[i]))
            {
                ad->semantic(sc);
            }
            else
            {
                Dsymbol *s = mod->search_correct(names[i]);
                if (s)
                    mod->error(loc, "import '%s' not found, did you mean '%s %s'?", names[i]->toChars(), s->kind(), s->toChars());
                else
                    mod->error(loc, "import '%s' not found", names[i]->toChars());
                ad->type = Type::terror;
            }
        }
        sc = sc->pop();
    }

    // object self-imports itself, so skip that (Bugzilla 7547)
    // don't list pseudo modules __entrypoint.d, __main.d (Bugzilla 11117, 11164)
    if (global.params.moduleDeps != NULL &&
        !(id == Id::object && sc->module->ident == Id::object) &&
        sc->module->ident != Id::entrypoint &&
        strcmp(sc->module->ident->string, "__main") != 0)
    {
        /* The grammar of the file is:
         *      ImportDeclaration
         *          ::= BasicImportDeclaration [ " : " ImportBindList ] [ " -> "
         *      ModuleAliasIdentifier ] "\n"
         *
         *      BasicImportDeclaration
         *          ::= ModuleFullyQualifiedName " (" FilePath ") : " Protection|"string"
         *              " [ " static" ] : " ModuleFullyQualifiedName " (" FilePath ")"
         *
         *      FilePath
         *          - any string with '(', ')' and '\' escaped with the '\' character
         */

        OutBuffer *ob = global.params.moduleDeps;
        Module* imod = sc->instantiatingModule();
        if (!global.params.moduleDepsFile)
            ob->writestring("depsImport ");
        ob->writestring(imod->toPrettyChars());
        ob->writestring(" (");
        escapePath(ob,  imod->srcfile->toChars());
        ob->writestring(") : ");

        // use protection instead of sc->protection because it couldn't be
        // resolved yet, see the comment above
        ProtDeclaration::protectionToCBuffer(ob, protection);
        if (isstatic)
            StorageClassDeclaration::stcToCBuffer(ob, STCstatic);
        ob->writestring(": ");

        if (packages)
        {
            for (size_t i = 0; i < packages->dim; i++)
            {
                Identifier *pid = (*packages)[i];
                ob->printf("%s.", pid->toChars());
            }
        }

        ob->writestring(id->toChars());
        ob->writestring(" (");
        if (mod)
            escapePath(ob, mod->srcfile->toChars());
        else
            ob->writestring("???");
        ob->writeByte(')');

        for (size_t i = 0; i < names.dim; i++)
        {
            if (i == 0)
                ob->writeByte(':');
            else
                ob->writeByte(',');

            Identifier *name = names[i];
            Identifier *alias = aliases[i];

            if (!alias)
            {
                ob->printf("%s", name->toChars());
                alias = name;
            }
            else
                ob->printf("%s=%s", alias->toChars(), name->toChars());
        }

        if (aliasId)
                ob->printf(" -> %s", aliasId->toChars());

        ob->writenl();
    }

    //printf("-Import::semantic('%s'), pkg = %p\n", toChars(), pkg);
}

void Import::semantic2(Scope *sc)
{
    //printf("Import::semantic2('%s')\n", toChars());
    if (mod)
    {
        mod->semantic2();
        if (mod->needmoduleinfo)
        {
            //printf("module5 %s because of %s\n", sc->module->toChars(), mod->toChars());
            sc->module->needmoduleinfo = 1;
        }
    }
}

Dsymbol *Import::toAlias()
{
    if (aliasId)
        return mod;
    return this;
}

/*****************************
 * Add import to sd's symbol table.
 */

int Import::addMember(Scope *sc, ScopeDsymbol *sd, int memnum)
{
    int result = 0;

    if (names.dim == 0 || aliasId)
        result = Dsymbol::addMember(sc, sd, memnum);

    /* Instead of adding the import to sd's symbol table,
     * add each of the alias=name pairs
     */
    for (size_t i = 0; i < names.dim; i++)
    {
        Identifier *name = names[i];
        Identifier *alias = aliases[i];

        if (!alias)
            alias = name;

        TypeIdentifier *tname = new TypeIdentifier(loc, name);
        AliasDeclaration *ad = new AliasDeclaration(loc, alias, tname);
        ad->import = this;
        result |= ad->addMember(sc, sd, memnum);

        aliasdecls.push(ad);
    }

    return result;
}

Dsymbol *Import::search(Loc loc, Identifier *ident, int flags)
{
    printf("%p [%s].Import::search(ident = '%s', flags = x%x)\n", this, loc.toChars(), ident->toChars(), flags);
    printf("%p\tfrom [%s] mod = %p\n", this, this->loc.toChars(), mod);

    //printf("%p\tmod = %s\n", this, mod->toChars());

    Dsymbol *s = NULL;

    int saveflags = flags;
    if (!(flags & IgnoreImportedFQN) && isstatic)
    {
        goto Lskip;
    }

    // Don't find private members and import declarations
    flags |= (IgnorePrivateMembers | IgnoreImportedFQN);

    if (protection == PROTprivate && (flags & IgnorePrivateImports))
    {
        //printf("\t-->! supress\n");
    }
    else if (names.dim)
    {
        for (size_t i = 0; i < names.dim; i++)
        {
            Identifier *name = names[i];
            Identifier *alias = aliases[i];
            if ((alias ? alias : name) == ident)
            {
                // Forward it to the module
                s = mod->search(loc, name, flags | IgnorePrivateImports);
                break;
            }
        }
    }
    else
    {
        // Forward it to the module
        s = mod->search(loc, ident, flags | IgnorePrivateImports);
    }
Lskip:
    if (!s && overnext)
    {
        s = overnext->search(loc, ident, saveflags);
    }

    return s;
}

bool Import::overloadInsert(Dsymbol *s)
{
    /* Allow multiple imports with the same package base, but disallow
     * alias collisions (Bugzilla 5412).
     */
    assert(ident && ident == s->ident);
    Import *imp;
    if (!aliasId && (imp = s->isImport()) != NULL && !imp->aliasId)
        return true;
    else
        return false;
}

void Import::toCBuffer(OutBuffer *buf, HdrGenState *hgs)
{
    if (hgs->hdrgen && id == Id::object)
        return;         // object is imported by default

    if (isstatic)
        buf->writestring("static ");
    buf->writestring("import ");
    if (aliasId)
    {
        buf->printf("%s = ", aliasId->toChars());
    }
    if (packages && packages->dim)
    {
        for (size_t i = 0; i < packages->dim; i++)
        {   Identifier *pid = (*packages)[i];

            buf->printf("%s.", pid->toChars());
        }
    }
    buf->printf("%s", id->toChars());
    if (names.dim)
    {
        buf->writestring(" : ");
        for (size_t i = 0; i < names.dim; i++)
        {
            Identifier *name = names[i];
            Identifier *alias = aliases[i];

            if (alias)
                buf->printf("%s = %s", alias->toChars(), name->toChars());
            else
                buf->printf("%s", name->toChars());

            if (i < names.dim - 1)
                buf->writestring(", ");
        }
    }
    buf->printf(";");
    buf->writenl();
}

