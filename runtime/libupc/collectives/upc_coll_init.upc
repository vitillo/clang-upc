/*===-- upc_coll_init.upc - UPC Runtime Support Library ------------------===
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

#include <stdio.h>
#include <stdlib.h>

int upc_coll_init_flag = 0;

void
upc_coll_init ()
{
  if (upc_coll_init_flag)
    {
      printf ("Internal error: Multiple attempts to initialize ");
      printf ("\tthecollective library in the same thread.\n");
      exit (1);
    }

  // Set the flag so that this thread never initializes again.

  upc_coll_init_flag = 1;

// Nothing to initialize yet.

}
