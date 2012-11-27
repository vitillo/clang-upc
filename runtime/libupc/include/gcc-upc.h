/*===-- gcc-upc.h - UPC Runtime Support Library --------------------------===
|*
|*                     The LLVM Compiler Infrastructure
|*
|* Copyright 2012, Intrepid Technology, Inc.  All rights reserved.
|* This file is distributed under a BSD-style Open Source License.
|* See LICENSE-INTREPID.TXT for details.
|*
|*===---------------------------------------------------------------------===*/

#ifndef _GCC_UPC_H_
#define _GCC_UPC_H_

#ifndef NO_GCC_UPC_LIB
/* Include the runtime API.  */
#include <gcc-upc-lib.h>
#endif

#pragma upc upc_code

/* upc_lock_t is an opaque shared type */
typedef shared struct upc_lock_struct upc_lock_t;

#ifndef upc_poll
/* for now upc_poll is a no-op */
#define upc_poll()
#endif

#ifdef __UPC_USES_PTHREADS__
/* Pthreads implementation uses per thread random seed */
#define rand __upc_rand
#define srand __upc_srand
extern int __upc_rand (void);
extern void __upc_srand (unsigned int seed);
#endif

#endif /* !_GCC_UPC_H_ */
