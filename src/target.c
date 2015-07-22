
/* Compiler implementation of the D programming language
 * Copyright (c) 2013-2014 by Digital Mars
 * All Rights Reserved
 * written by Iain Buclaw
 * http://www.digitalmars.com
 * Distributed under the Boost Software License, Version 1.0.
 * http://www.boost.org/LICENSE_1_0.txt
 * https://github.com/D-Programming-Language/dmd/blob/master/src/target.c
 */

#include <assert.h>

#include "target.h"
#include "mars.h"
#include "aggregate.h"
#include "id.h"
#include "mtype.h"

int Target::ptrsize;
int Target::realsize;
int Target::realpad;
int Target::realalignsize;
bool Target::reverseCppOverloads;
int Target::c_longsize;
int Target::c_long_doublesize;
int Target::classinfosize;


void Target::init()
{
    // These have default values for 32 bit code, they get
    // adjusted for 64 bit code.
    ptrsize = 4;
    classinfosize = 0x4C;   // 76

    if (global.params.isLP64)
    {
        ptrsize = 8;
        classinfosize = 0x98;   // 152
    }

    if (global.params.isLinux || global.params.isFreeBSD
        || global.params.isOpenBSD || global.params.isSolaris)
    {
        realsize = 12;
        realpad = 2;
        realalignsize = 4;
        c_longsize = 4;
    }
    else if (global.params.isOSX)
    {
        realsize = 16;
        realpad = 6;
        realalignsize = 16;
        c_longsize = 4;
    }
    else if (global.params.isWindows)
    {
        realsize = 10;
        realpad = 0;
        realalignsize = 2;
        reverseCppOverloads = !global.params.is64bit;
        c_longsize = 4;
    }
    else
        assert(0);

    if (global.params.is64bit)
    {
        if (global.params.isLinux || global.params.isFreeBSD || global.params.isSolaris)
        {
            realsize = 16;
            realpad = 6;
            realalignsize = 16;
            c_longsize = 8;
        }
        else if (global.params.isOSX)
        {
            c_longsize = 8;
        }
    }

    c_long_doublesize = realsize;
    if (global.params.is64bit && global.params.isWindows)
        c_long_doublesize = 8;
}

/******************************
 * Return memory alignment size of type.
 */

unsigned Target::alignsize(Type* type)
{
    assert (type->isTypeBasic());

    switch (type->ty)
    {
        case Tfloat80:
        case Timaginary80:
        case Tcomplex80:
            return Target::realalignsize;

        case Tcomplex32:
            if (global.params.isLinux || global.params.isOSX || global.params.isFreeBSD
                || global.params.isOpenBSD || global.params.isSolaris)
                return 4;
            break;

        case Tint64:
        case Tuns64:
        case Tfloat64:
        case Timaginary64:
        case Tcomplex64:
            if (global.params.isLinux || global.params.isOSX || global.params.isFreeBSD
                || global.params.isOpenBSD || global.params.isSolaris)
                return global.params.is64bit ? 8 : 4;
            break;

        default:
            break;
    }
    return (unsigned)type->size(Loc());
}

/******************************
 * Return field alignment size of type.
 */

unsigned Target::fieldalign(Type* type)
{
    return type->alignsize();
}

/***********************************
 * Return size of OS critical section.
 * NOTE: can't use the sizeof() calls directly since cross compiling is
 * supported and would end up using the host sizes rather than the target
 * sizes.
 */
unsigned Target::critsecsize()
{
    if (global.params.isWindows)
    {
        // sizeof(CRITICAL_SECTION) for Windows.
        return global.params.isLP64 ? 40 : 24;
    }
    else if (global.params.isLinux)
    {
        // sizeof(pthread_mutex_t) for Linux.
        if (global.params.is64bit)
            return global.params.isLP64 ? 40 : 32;
        else
            return global.params.isLP64 ? 40 : 24;
    }
    else if (global.params.isFreeBSD)
    {
        // sizeof(pthread_mutex_t) for FreeBSD.
        return global.params.isLP64 ? 8 : 4;
    }
    else if (global.params.isOpenBSD)
    {
        // sizeof(pthread_mutex_t) for OpenBSD.
        return global.params.isLP64 ? 8 : 4;
    }
    else if (global.params.isOSX)
    {
        // sizeof(pthread_mutex_t) for OSX.
        return global.params.isLP64 ? 64 : 44;
    }
    else if (global.params.isSolaris)
    {
        // sizeof(pthread_mutex_t) for Solaris.
        return 24;
    }
    assert(0);
    return 0;
}

/***********************************
 * Returns a Type for the va_list type of the target.
 * NOTE: For Posix/x86_64 this returns the type which will really
 * be used for passing an argument of type va_list.
 */
Type *Target::va_listType()
{
    if (global.params.isWindows)
    {
        return Type::tchar->pointerTo();
    }
    else if (global.params.isLinux ||
             global.params.isFreeBSD ||
             global.params.isOpenBSD ||
             global.params.isSolaris ||
             global.params.isOSX)
    {
        if (global.params.is64bit)
        {
            return (new TypeIdentifier(Loc(), Identifier::idPool("__va_list_tag")))->pointerTo();
        }
        else
        {
            return Type::tchar->pointerTo();
        }
    }
    else
    {
        assert(0);
        return NULL;
    }
}

/******************************
 * Private helpers for Target::paintAsType.
 */

// Write the integer value of 'e' into a unsigned byte buffer.
static void encodeInteger(Expression *e, unsigned char *buffer)
{
    dinteger_t value = e->toInteger();
    int size = (int)e->type->size();

    for (int p = 0; p < size; p++)
    {
        int offset = p;     // Would be (size - 1) - p; on BigEndian
        buffer[offset] = ((value >> (p * 8)) & 0xFF);
    }
}

// Write the bytes encoded in 'buffer' into an integer and returns
// the value as a new IntegerExp.
static Expression *decodeInteger(Loc loc, Type *type, unsigned char *buffer)
{
    dinteger_t value = 0;
    int size = (int)type->size();

    for (int p = 0; p < size; p++)
    {
        int offset = p;     // Would be (size - 1) - p; on BigEndian
        value |= ((dinteger_t)buffer[offset] << (p * 8));
    }

    return new IntegerExp(loc, value, type);
}

// Write the real value of 'e' into a unsigned byte buffer.
static void encodeReal(Expression *e, unsigned char *buffer)
{
    switch (e->type->ty)
    {
        case Tfloat32:
        {
            float *p = (float *)buffer;
            *p = (float)e->toReal();
            break;
        }
        case Tfloat64:
        {
            double *p = (double *)buffer;
            *p = (double)e->toReal();
            break;
        }
        default:
            assert(0);
    }
}

// Write the bytes encoded in 'buffer' into a longdouble and returns
// the value as a new RealExp.
static Expression *decodeReal(Loc loc, Type *type, unsigned char *buffer)
{
    longdouble value;

    switch (type->ty)
    {
        case Tfloat32:
        {
            float *p = (float *)buffer;
            value = ldouble(*p);
            break;
        }
        case Tfloat64:
        {
            double *p = (double *)buffer;
            value = ldouble(*p);
            break;
        }
        default:
            assert(0);
    }

    return new RealExp(loc, value, type);
}

/******************************
 * Encode the given expression, which is assumed to be an rvalue literal
 * as another type for use in CTFE.
 * This corresponds roughly to the idiom *(Type *)&e.
 */

Expression *Target::paintAsType(Expression *e, Type *type)
{
    // We support up to 512-bit values.
    unsigned char buffer[64];

    memset(buffer, 0, sizeof(buffer));
    assert(e->type->size() == type->size());

    // Write the expression into the buffer.
    switch (e->type->ty)
    {
        case Tint32:
        case Tuns32:
        case Tint64:
        case Tuns64:
            encodeInteger(e, buffer);
            break;

        case Tfloat32:
        case Tfloat64:
            encodeReal(e, buffer);
            break;

        default:
            assert(0);
    }

    // Interpret the buffer as a new type.
    switch (type->ty)
    {
        case Tint32:
        case Tuns32:
        case Tint64:
        case Tuns64:
            return decodeInteger(e->loc, type, buffer);

        case Tfloat32:
        case Tfloat64:
            return decodeReal(e->loc, type, buffer);

        default:
            assert(0);
    }

    return NULL;    // avoid warning
}

/*
 * Return true if the given type is supported for this target
 */

int Target::checkVectorType(int sz, Type *type)
{
    if (!global.params.is64bit && !global.params.isOSX)
        return 1; // not supported

    if (sz != 16 && sz != 32)
        return 2; // wrong size

    switch (type->ty)
    {
    case Tvoid:
    case Tint8:
    case Tuns8:
    case Tint16:
    case Tuns16:
    case Tint32:
    case Tuns32:
    case Tfloat32:
    case Tint64:
    case Tuns64:
    case Tfloat64:
        break;
    default:
        return 3; // wrong base type
    }

    return 0;
}

/******************************
 * For the given module, perform any post parsing analysis.
 * Certain compiler backends (ie: GDC) have special placeholder
 * modules whose source are empty, but code gets injected
 * immediately after loading.
 */
void Target::loadModule(Module *m)
{
}

/***************************
 * Determine return style of function - whether in registers or
 * through a hidden pointer to the caller's stack.
 */
RET Target::retStyle(TypeFunction *tf)
{
    //printf("TypeFunction::retStyle() %s\n", toChars());
    if (tf->isref)
    {
        //printf("  ref RETregs\n");
        return RETregs;                 // returns a pointer
    }

    Type *tn = tf->next->toBasetype();
    //printf("tn = %s\n", tn->toChars());
    d_uns64 sz = tn->size();
    Type *tns = tn;

    if (global.params.isWindows && global.params.is64bit)
    {
        // http://msdn.microsoft.com/en-us/library/7572ztz4(v=vs.80)
        if (tns->ty == Tcomplex32)
            return RETstack;
        if (tns->isscalar())
            return RETregs;

        tns = tns->baseElemOf();
        if (tns->ty == Tstruct)
        {
            StructDeclaration *sd = ((TypeStruct *)tns)->sym;
            if (sd->ident == Id::__c_long_double)
                return RETregs;
            if (!sd->isPOD() || sz >= 8)
                return RETstack;
            if (sd->fields.dim == 0)
                return RETstack;
        }
        if (sz <= 16 && !(sz & (sz - 1)))
            return RETregs;
        return RETstack;
    }

Lagain:
    if (tns->ty == Tsarray)
    {
        tns = tns->baseElemOf();
        if (tns->ty != Tstruct)
        {
L2:
            if (tf->linkage != LINKd &&
                global.params.isLinux && !global.params.is64bit)
            {
                ;                               // 32 bit C/C++ structs always on stack
            }
            else
            {
                switch (sz)
                {
                    case 1:
                    case 2:
                    case 4:
                    case 8:
                        //printf("  sarray RETregs\n");
                        return RETregs; // return small structs in regs
                                            // (not 3 byte structs!)
                    default:
                        break;
                }
            }
            //printf("  sarray RETstack\n");
            return RETstack;
        }
    }

    if (tns->ty == Tstruct)
    {
        StructDeclaration *sd = ((TypeStruct *)tns)->sym;
        if (tf->linkage != LINKd &&
            global.params.isLinux && !global.params.is64bit)
        {
            if (sd->ident == Id::__c_long || sd->ident == Id::__c_ulong)
                return RETregs;

            //printf("  2 RETstack\n");
            return RETstack;            // 32 bit C/C++ structs always on stack
        }
        if (tf->linkage == LINKcpp && sd->isPOD() && sd->ctor &&
            global.params.isWindows && !global.params.is64bit)
        {
            // win32 returns otherwise POD structs with ctors via memory
            // unless it's not really a struct
            if (sd->ident == Id::__c_long || sd->ident == Id::__c_ulong)
                return RETregs;
            return RETstack;
        }
        if (sd->arg1type && !sd->arg2type)
        {
            tns = sd->arg1type;
            if (tns->ty != Tstruct)
                goto L2;
            goto Lagain;
        }
        if (!sd->arg1type && !sd->arg2type &&
            global.params.is64bit)
        {
            return RETstack;
        }
        if (sd->isPOD())
        {
            switch (sz)
            {
                case 1:
                case 2:
                case 4:
                case 8:
                    //printf("  3 RETregs\n");
                    return RETregs;     // return small structs in regs
                                        // (not 3 byte structs!)
                case 16:
                    if (!global.params.isWindows && global.params.is64bit)
                       return RETregs;

                default:
                    break;
            }
        }
        //printf("  3 RETstack\n");
        return RETstack;
    }
    if (tf->linkage == LINKc && tns->iscomplex() &&
        (global.params.isLinux || global.params.isOSX || global.params.isFreeBSD || global.params.isSolaris))
    {
        if (tns->ty == Tcomplex32)
            return RETregs;     // in EDX:EAX, not ST1:ST0
        else
            return RETstack;
    }
    //assert(sz <= 16);
    //printf("  4 RETregs\n");
    return RETregs;
}
