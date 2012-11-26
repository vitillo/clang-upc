/*===-- upc.h - UPC Runtime Support Library ------------------------------===
|*
|*                     The LLVM Compiler Infrastructure
|*
|* Copyright 2012, Intrepid Technology, Inc.  All rights reserved.
|* This file is distributed under a BSD-style Open Source License.
|* See LICENSE-INTREPID.TXT for details.
|*
|*===---------------------------------------------------------------------===*/

#ifndef _UPC_H_
#define _UPC_H_

/* required, to define size_t */
#include <sys/types.h>

extern size_t upc_threadof (shared void *);
extern size_t upc_phaseof (shared void *);
extern shared void *upc_resetphase (shared void *);
extern size_t upc_addrfield (shared void *);
extern size_t upc_affinitysize (size_t, size_t, size_t);
#define upc_poll() ((void)0)

#if IN_TARGET_LIBS || __UPC_PUPC_INST__
/* Profiled memory allocation routines */
extern shared void *upc_global_allocg (size_t, size_t, const char *, int);
extern shared void *upc_all_allocg (size_t, size_t, const char *, int);
extern shared void *upc_allocg (size_t, const char *, int);
extern void upc_freeg (shared void *, const char *, int);
extern void upc_all_freeg (shared void *, const char *, int);
/* upc_local_alloc is deprecated and removed in the 1.3 specification.  */
extern shared void *upc_local_allocg (size_t, size_t, const char *, int)
                   __attribute__((deprecated));
#endif /* IN_TARGET_LIBS || __UPC_PUPC_INST__ */

#ifdef __UPC_PUPC_INST__

/* Profiled UPC library functions */

extern void upc_global_exitg (int, const char *, int);
extern upc_lock_t *upc_global_lock_allocg (const char *, int);
extern upc_lock_t *upc_all_lock_allocg (const char *, int);
extern void upc_lockg (upc_lock_t *, const char *, int);
extern int upc_lock_attemptg (upc_lock_t *, const char *, int);
extern void upc_unlockg (upc_lock_t *, const char *, int);
extern void upc_lock_freeg (upc_lock_t *, const char *, int);
extern void upc_all_lock_freeg (upc_lock_t *, const char *, int);
extern void upc_memcpyg (shared void *, shared const void *, size_t, const char *, int);
extern void upc_memgetg (void *, shared const void *, size_t, const char *, int);
extern void upc_memputg (shared void *, const void *, size_t, const char *, int);
extern void upc_memsetg (shared void *, int, size_t, const char *, int);

/* The following functions are not profiled, but when -fupc-debug
   is asserted will be called with the addtional file and line
   arguments.  */
extern size_t upc_threadofg (shared void *, const char *, int);
extern size_t upc_phaseofg (shared void *, const char *, int);
extern shared void *upc_resetphaseg (shared void *, const char *, int);
extern size_t upc_addrfieldg (shared void *, const char *, int);
extern size_t upc_affinitysizeg (size_t, size_t, size_t, const char *, int);

#define upc_all_alloc(n, b)      upc_all_allocg(n, b, __FILE__, __LINE__)
#define upc_all_lock_alloc()     upc_all_lock_allocg(__FILE__, __LINE__)
#define upc_alloc(n)             upc_allocg(n, __FILE__, __LINE__)
#define upc_free(ptr)            upc_freeg(ptr, __FILE__, __LINE__)
#define upc_all_free(ptr)        upc_all_freeg(ptr, __FILE__, __LINE__)
#define upc_global_exit(n)       upc_global_exitg(n, __FILE__, __LINE__)
#define upc_global_alloc(n, b)   upc_global_allocg(n, b, __FILE__, __LINE__)
#define upc_global_lock_alloc()  upc_global_lock_allocg(__FILE__, __LINE__)
#define upc_lock_attempt(lck)    upc_lock_attemptg(lck, __FILE__, __LINE__)
#define upc_lock_free(lck)       upc_lock_freeg(lck, __FILE__, __LINE__)
#define upc_all_lock_free(lck)   upc_all_lock_freeg(lck, __FILE__, __LINE__)
#define upc_lock(lck)            upc_lockg(lck, __FILE__, __LINE__)
#define upc_memcpy(p1, p2, n)    upc_memcpyg(p1, p2, n, __FILE__, __LINE__)
#define upc_memget(p1, p2, n)    upc_memgetg(p1, p2, n, __FILE__, __LINE__)
#define upc_memput(p1, p2, n)    upc_memputg(p1, p2, n, __FILE__, __LINE__)
#define upc_memset(p1, c, n)     upc_memsetg(p1, c, n, __FILE__, __LINE__)
#define upc_unlock(lck)          upc_unlockg(lck, __FILE__, __LINE__)
/* upc_local_alloc is deprecated and removed in the 1.3 specification.  */
#define upc_local_alloc(n,s)     upc_local_allocg(n, s, __FILE__, __LINE__)

#define upc_threadof(p) upc_threadofg(p, __FILE__, __LINE__)
#define upc_phaseof(p) upc_phaseofg(p, __FILE__, __LINE__)
#define upc_resetphase(p) upc_resetphaseg(p, __FILE__, __LINE__)
#define upc_addrfield(p) upc_addrfieldg(p, __FILE__, __LINE__)
#define upc_affinity(totalsize, nbytes, threadid) \
           upc_affinitysizeg(totalsize, nbytes, threadid, __FILE__, __LINE__)

#else

/* Standard UPC library functions */

extern void upc_global_exit (int);
extern shared void *upc_global_alloc (size_t, size_t);
extern shared void *upc_all_alloc (size_t, size_t);
extern shared void *upc_alloc (size_t);
extern void upc_free (shared void *);
extern void upc_all_free (shared void *);
extern upc_lock_t *upc_global_lock_alloc (void);
extern upc_lock_t *upc_all_lock_alloc (void);
extern void upc_lock (upc_lock_t *);
extern int upc_lock_attempt (upc_lock_t *);
extern void upc_unlock (upc_lock_t *);
extern void upc_lock_free(upc_lock_t *);
extern void upc_all_lock_free(upc_lock_t *);
extern void upc_memcpy(shared void *, shared const void *, size_t);
extern void upc_memget(void *, shared const void *, size_t);
extern void upc_memput(shared void *, const void *, size_t);
extern void upc_memset(shared void *, int, size_t);

/* upc_local_alloc is deprecated and removed in the 1.3 specification.  */
extern shared void *upc_local_alloc (size_t, size_t)
                   __attribute__((deprecated));

#endif /* __UPC_PUPC_INST__ */

#ifndef __BERKELEY_UPC_RUNTIME__
/* upc_flag_t, required by version 1.2 of the UPC specification
   (section 7.2.6).  */
typedef int upc_flag_t;
#endif

#endif /* !_UPC_H_ */
