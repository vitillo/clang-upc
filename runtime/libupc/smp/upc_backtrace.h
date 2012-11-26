/*===-- upc_backtrace.h - UPC Runtime Support Library --------------------===
|*
|*                     The LLVM Compiler Infrastructure
|*
|* Copyright 2012, Intrepid Technology, Inc.  All rights reserved.
|* This file is distributed under a BSD-style Open Source License.
|* See LICENSE-INTREPID.TXT for details.
|*
|*===---------------------------------------------------------------------===*/

#ifndef _UPC_BACKTRACE_H_
#define _UPC_BACKTRACE_H_

/* Environment variables. */
/** Enable/Disable backtrace env variable. */
#define GUPCR_BACKTRACE_ENV "UPC_BACKTRACE"
/** GDB command for backtrace env variable. */
#define GUPCR_BACKTRACE_GDB_ENV "UPC_BACKTRACE_GDB"

/* Interfaces. */
extern void __upc_backtrace (void);
extern void __upc_fatal_backtrace (void);
extern void __upc_backtrace_init (const char *execname);

#if HAVE_LIBBFD
extern char **backtrace_src_symbols(void *const *buffer, int size,
				    const char *filename);
#endif

#endif /* !_UPC_BACKTRACE_H_ */
