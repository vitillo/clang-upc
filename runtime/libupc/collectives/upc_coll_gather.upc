/*===-- upc_coll_gather.upc - UPC Runtime Support Library -----------------===*|*
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
upc_all_gather (shared void *dst,
		shared const void *src, size_t nbytes, upc_flag_t sync_mode)
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
  upc_coll_err (dst, src, NULL, nbytes, sync_mode, 0, 0, 0, UPC_GATH);
#endif
  // Synchronize using barriers in the cases of MYSYNC and ALLSYNC.

  if (UPC_IN_MYSYNC & sync_mode || !(UPC_IN_NOSYNC & sync_mode))

    upc_barrier;

#ifdef PULL

  // The dst thread "pulls" a block of data from each src thread.

  if ((int)upc_threadof ((shared void *) dst) == MYTHREAD)
    {
      for (i = 0; i < THREADS; ++i)
	{
	  upc_memcpy ((shared char *) dst + nbytes * i * THREADS,
		      (shared char *) src + i, nbytes);
	}
    }
#endif

#ifdef PUSH

  // Each src thread "pushes" the data to the dst thread.

  upc_memcpy ((shared char *) dst + MYTHREAD * THREADS * nbytes,
	      (shared char *) src + MYTHREAD, nbytes);

#endif

  // Synchronize using barriers in the cases of MYSYNC and ALLSYNC.

  if (UPC_OUT_MYSYNC & sync_mode || !(UPC_OUT_NOSYNC & sync_mode))

    upc_barrier;
}
