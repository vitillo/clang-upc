/*===-- upc_coll_sort.upc - UPC Runtime Support Library ------------------===
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

static
shared void *
Asub (shared void *A, int i, size_t elem_size, size_t blk_size)
// Compute &A[i] given &A[0] and the element and block sizes of A.
{
  shared char *base;
  int j, k, r, p, q;

  base = (shared char *) A - upc_threadof (A);	// corres. addr on thr 0
  p = upc_phaseof (A);		// phase of A
  j = i + p + upc_threadof (A) * blk_size;	// j is i relative to base
  k = (j / blk_size) % THREADS;	// element j is on thread k
  r = j - k * blk_size;		// r is corres. index on thr 0
  q = r / (blk_size * THREADS);	// number of blocks preceding r

  return base + (q * blk_size + j % blk_size - p) * elem_size * THREADS + k;
}

void
upc_all_sort (shared void *A,
	      size_t elem_size,
	      size_t nelems,
	      size_t blk_size,
	      int (*func) (shared void *, shared void *),
	      upc_flag_t sync_mode)
{
  const int nelems_m1 = (int)nelems - 1;
  int i, j;
  shared char *Aj, *Ajp1, *tmp;

  if (!upc_coll_init_flag)
    upc_coll_init ();

#ifdef _UPC_COLL_CHECK_ARGS
  upc_coll_err (A, NULL, NULL, elem_size, sync_mode, blk_size,
		nelems, 0, UPC_SORT);
#endif

  // Synchronize using barriers in the cases of MYSYNC and ALLSYNC.

  if (UPC_IN_MYSYNC & sync_mode || !(UPC_IN_NOSYNC & sync_mode))

    upc_barrier;

  if (MYTHREAD == 0)
    tmp = upc_alloc (elem_size);

  // Thread 0 does a bubble sort.
  if (MYTHREAD == 0)
    for (i = 0; i < nelems_m1; ++i)
      for (j = 0; j < nelems_m1 - i; ++j)
	{
	  // compute addresses of A[j] and A[j+1]

	  Aj = (shared char *) Asub (A, j, elem_size, blk_size);
	  Ajp1 = (shared char *) Asub (A, j + 1, elem_size, blk_size);

	  if (func ((shared void *) Aj, (shared void *) Ajp1) > 0)

	    {			// swap array elements
	      upc_memcpy (tmp, (shared const void *) Aj, elem_size);
	      upc_memcpy (Aj, (shared const void *) Ajp1, elem_size);
	      upc_memcpy (Ajp1, (shared const void *) tmp, elem_size);
	    }
	}

  if (MYTHREAD == 0)
    upc_free (tmp);

  // Synchronize using barriers in the cases of MYSYNC and ALLSYNC.

  if (UPC_OUT_MYSYNC & sync_mode || !(UPC_OUT_NOSYNC & sync_mode))
    upc_barrier;
}
