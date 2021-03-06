/*===-- gupcr_barrier.h - UPC Runtime Support Library --------------------===
|*
|*                     The LLVM Compiler Infrastructure
|*
|* Copyright 2012, Intel Corporation.  All rights reserved.
|* This file is distributed under a BSD-style Open Source License.
|* See LICENSE-INTEL.TXT for details.
|*
|*===---------------------------------------------------------------------===*/

#ifndef _GUPCR_BARRIER_H_
#define _GUPCR_BARRIER_H_

/**
 * @file gupcr_barrier.h
 * GUPC Portals4 barrier implementation.
 *
 * @addtogroup BARRIER GUPCR Barrier Functions
 * @{
 */

extern void gupcr_barrier_init (void);
extern void gupcr_barrier_fini (void);

/* Broadcast support functions.  */
extern void gupcr_bcast_send (void *, size_t);
extern void gupcr_bcast_recv (void *, size_t);

/** @} */
#endif /* gupcr_barrier.h */
