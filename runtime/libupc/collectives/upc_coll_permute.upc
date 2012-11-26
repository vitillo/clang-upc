/*===-- upc_coll_permute.upc - UPC Runtime Support Library ---------------===
|*
|*                     The LLVM Compiler Infrastructure
|*
|* Copyright 2004, Michigan Technological University.  All rights reserved.
|* This file is distributed under a BSD-style Open Source License.
|* See LICENSE-MTU.TXT for details.
|*
|*===---------------------------------------------------------------------===*/

#include <upc.h>
#include <upc_collective.h>
#include <upc_coll.h>

/*****************************************************************************/
/*                                                                           */
/*        UPC collective function library, reference implementation          */
/*                                                                           */
/*   Steve Seidel, Dept. of Computer Science, Michigan Technological Univ.   */
/*   steve@mtu.edu                                        March 1, 2004      */
/*                                                                           */
/*****************************************************************************/

void
upc_all_permute (shared void *dst,
		 shared const void *src,
		 shared const int *perm, size_t nbytes, upc_flag_t sync_mode)
{
#ifndef PULL
#ifndef PUSH
#define PULL TRUE
#endif
#endif

#ifdef PULL
  int i;
#endif

  if (!upc_coll_init_flag)
    upc_coll_init ();

#ifdef _UPC_COLL_CHECK_ARGS
  upc_coll_err (dst, src, perm, nbytes, sync_mode, 0, 0, 0, UPC_PERM);
#endif
  // Synchronize using barriers in the cases of MYSYNC and ALLSYNC.

  if (UPC_IN_MYSYNC & sync_mode || !(UPC_IN_NOSYNC & sync_mode))

    upc_barrier;

#ifdef PULL

  // Each dst thread finds its src thread and "pulls" the data from it.

  for (i = 0; i < THREADS; ++i)
    if (perm[i] == MYTHREAD)
      break;

  upc_memcpy ((shared char *) dst + MYTHREAD,
	      (shared char *) src + i, nbytes);

#endif

#ifdef PUSH

  // The src thread "pushes" its data to its dst thread.

  upc_memcpy ((shared char *) dst + perm[MYTHREAD],
	      (shared char *) src + MYTHREAD, nbytes);

#endif

  // Synchronize using barriers in the cases of MYSYNC and ALLSYNC.

  if (UPC_OUT_MYSYNC & sync_mode || !(UPC_OUT_NOSYNC & sync_mode))

    upc_barrier;
}
