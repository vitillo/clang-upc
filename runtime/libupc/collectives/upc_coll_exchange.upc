/*===-- upc_coll_exchange.upc - UPC Runtime Support Library ---------------===*|*
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
upc_all_exchange (shared void *dst,
		  shared const void *src, size_t nbytes, upc_flag_t sync_mode)
{
#ifndef PULL
#ifndef PUSH
#define PULL TRUE
#endif
#endif

  int i;

  if (!upc_coll_init_flag)
    upc_coll_init ();

#ifdef _UPC_COLL_CHECK_ARGS
  upc_coll_err (dst, src, NULL, nbytes, sync_mode, 0, 0, 0, UPC_EXCH);
#endif
  // Synchronize using barriers in the cases of MYSYNC and ALLSYNC.

  if (UPC_IN_MYSYNC & sync_mode || !(UPC_IN_NOSYNC & sync_mode))

    upc_barrier;
#ifdef PULL

  // Thread MYTHREAD copies the MYTHREADth block of thread i to
  // its own ith block.

  for (i = 0; i < THREADS; i++)
    {
      upc_memcpy ((shared char *) dst + i * nbytes * THREADS + MYTHREAD,
		  (shared char *) src + MYTHREAD * nbytes * THREADS + i,
		  nbytes);
    }

#endif

#ifdef PUSH

  // Thread MYTHREAD copies its ith block to the MYTHREADth block
  // of thread i

  for (i = 0; i < THREADS; i++)
    {
      upc_memcpy ((shared char *) dst + MYTHREAD * nbytes * THREADS + i,
		  (shared char *) src + i * nbytes * THREADS + MYTHREAD,
		  nbytes);
    }

#endif
  // Synchronize using barriers in the cases of MYSYNC and ALLSYNC.

  if (UPC_OUT_MYSYNC & sync_mode || !(UPC_OUT_NOSYNC & sync_mode))

    upc_barrier;
}
