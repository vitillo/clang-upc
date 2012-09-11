# See www/CMake.html for instructions on how to build libcxx with CMake.

#===============================================================================
# Setup Project
#===============================================================================

project(libupc C)
cmake_minimum_required(VERSION 2.8)

set(PACKAGE_NAME libupc)
set(PACKAGE_VERSION trunk-svn)
set(PACKAGE_STRING "${PACKAGE_NAME} ${PACKAGE_VERSION}")
set(PACKAGE_BUGREPORT "llvmbugs@cs.uiuc.edu")

# Add path for custom modules
#set(CMAKE_MODULE_PATH
#  ${CMAKE_MODULE_PATH}
#  "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
#  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules"
#  )

# Require out of source build.
#include(MacroEnsureOutOfSourceBuild)
#MACRO_ENSURE_OUT_OF_SOURCE_BUILD(
# "${PROJECT_NAME} requires an out of source build. Please create a separate
# build directory and run 'cmake /path/to/${PROJECT_NAME} [options]' there."
# )

#===============================================================================
# Setup CMake Options
#===============================================================================

# Define options.
option(LIBUPC_ENABLE_SHARED "Build libupc as a shared library." ON)

#===============================================================================
# Configure System
#===============================================================================

# Get triples.
#include(GetTriple)
#get_host_triple(LIBUPC_HOST_TRIPLE
#  LIBUPC_HOST_ARCH
#  LIBUPC_HOST_VENDOR
#  LIBUPC_HOST_OS
#  )
#set(LIBUPC_HOST_TRIPLE ${LIBUPC_HOST_TRIPLE} CACHE STRING "Host triple.")
#get_target_triple(LIBUPC_TARGET_TRIPLE
#  LIBUPC_TARGET_ARCH
#  LIBUPC_TARGET_VENDOR
#  LIBUPC_TARGET_OS
#  )
#set(LIBUPC_TARGET_TRIPLE ${LIBCXX_TARGET_TRIPLE} CACHE STRING "Target triple.")

# Configure compiler.
#include(config-ix)

#try_run(LIBUPC_AFFINITY_COMPILE LIBUPC_AFFINITY_RUN conf_affinity.c)

set(CMAKE_C_COMPILER ${LLVM_TOOLS_BINARY_DIR}/clang)

#===============================================================================
# Setup Compiler Flags
#===============================================================================

# Get required flags.

macro(append_if list condition var)
  if (${condition})
    list(APPEND ${list} ${var})
  endif()
endmacro()

# Get feature flags.

# This is the _ONLY_ place where add_definitions is called.
add_definitions(
 ${LIBUPC_REQUIRED_FLAGS}
 ${LIBUPC_WARNING_FLAGS}
 ${LIBUPC_FEATURE_FLAGS}
 )

#HAVE_EXECINFO_H
#HAVE_LIMITS_H

set(UPC_PTS "PACKED" CACHE STRING "UPC Pointer Representation.")
OPTION(UPC_PTS_VADDR_FIRST "Put the virtual address field first" ON)

if(UPC_PTS_VADDR_FIRST)
  set(GUPCR_PTS_VADDR_FIRST ON)
endif()

if(${UPC_PTS} STREQUAL "PACKED")
 set(UPC_PTS_PACKED_THREAD_BITS 10 CACHE STRING "Bits in the thread field.")
 set(UPC_PTS_PACKED_PHASE_BITS 20 CACHE STRING "Bits in the phase field.")
 set(UPC_PTS_PACKED_ADDR_BITS 34 CACHE STRING "Bits in the addr field.")
 set(GUPCR_PTS_PACKED_REP 1)
 set(GUPCR_PTS_THREAD_SIZE ${UPC_PTS_PACKED_THREAD_BITS})
 set(GUPCR_PTS_PHASE_SIZE ${UPC_PTS_PACKED_PHASE_BITS})
 set(GUPCR_PTS_VADDR_SIZE ${UPC_PTS_PACKED_ADDR_BITS})
elseif(${UPC_PTS} STREQUAL "STRUCT")
 set(GUPCR_PTS_STRUCT_REP 1)
 set(GUPCR_PTS_THREAD_SIZE 32)
 set(GUPCR_PTS_PHASE_SIZE 32)
 set(GUPCR_PTS_VADDR_SIZE 64)
else()
 echo("Huh?")
endif()

set(UPC_TREE_FANOUT 4 CACHE STRING "The maximum number of children in each sub-tree used to implement UPC collectives operations (e. g. upc_barrier)")

configure_file(config.h.cmake config.h)

#===============================================================================
# Setup Source Code
#===============================================================================

include_directories(include collectives)

set(LIBUPC_SOURCES
  smp/upc_access.c
  smp/upc_accessg.c
  smp/upc_addr.c
  # smp/upc_affinity.c
  smp/upc_affinity_stub.c
  smp/upc_alloc.upc
  smp/upc_allocg.upc
  #smp/upc_backtrace.c
  #smp/upc_backtrace_sup.c
  smp/upc_barrier.upc
  smp/upc_gasp.c
  smp/upc_gum.c
  smp/upc_libg.c
  smp/upc_lock.c
  smp/upc_main.c
  smp/upc_mem.c
  # smp/upc_numa.c
  smp/upc_numa_stub.c
  smp/upc_pgm_info.c
  smp/upc_pupc.c
  smp/upc_sysdep.c
  smp/upc_vm.c

  collectives/upc_coll_broadcast.upc
  collectives/upc_coll_err.upc
  collectives/upc_coll_exchange.upc
  collectives/upc_coll_gather_all.upc
  collectives/upc_coll_init.upc
  collectives/upc_coll_permute.upc
  collectives/upc_coll_prefix_reduce.upc
  collectives/upc_coll_reduce.upc
  collectives/upc_coll_scatter.upc
  collectives/upc_coll_sort.upc
)

if(LIBUPC_ENABLE_SHARED)
  add_library(upc SHARED
    ${LIBUPC_SOURCES}
    )
else()
  add_library(upc STATIC
    ${LIBUPC_SOURCES}
    )
endif()

set_property(SOURCE ${LIBUPC_SOURCES} PROPERTY LANGUAGE C)

macro(add_crt_target name opts)
  set(obj ${LLVM_BINARY_DIR}/lib${LLVM_LIBDIR_SUFFIX}/${name}.o)
  list(APPEND objects ${obj})
  add_custom_target(${name} ALL DEPENDS ${obj})
  add_custom_command(OUTPUT ${obj}
  COMMAND ${CMAKE_C_COMPILER} -c -o ${obj} ${PROJECT_SOURCE_DIR}/upc-crtstuff.c -I${PROJECT_SOURCE_DIR}/config/default -I${PROJECT_BINARY_DIR} ${opts}
  MAIN_DEPENDENCY upc-crtstuff.c
  IMPLICIT_DEPENDENCY upc-crtstuff.c
  VERBATIM)
endmacro()

add_crt_target(upc-crtbegin -DCRT_BEGIN)
add_crt_target(upc-crtend -DCRT_END)
add_crt_target(upc-crtbeginS -DCRT_BEGIN)
add_crt_target(upc-crtendS -DCRT_END)
add_crt_target(upc-crtbeginT -DCRT_BEGIN)
add_crt_target(upc-crtendT -DCRT_END)

find_package(Perl REQUIRED)

set(upc_link_script ${LLVM_BINARY_DIR}/lib${LLVM_LIBDIR_SUFFIX}/upc.ld)
add_custom_target(upc-link-script ALL DEPENDS ${upc_link_script})
add_custom_command(OUTPUT ${upc_link_script}
   COMMAND ld --verbose | ${PERL_EXECUTABLE} ${PROJECT_SOURCE_DIR}/gen-upc-ld-script.pl > ${upc_link_script}
   VERBATIM)

set(header_location lib${LLVM_LIBDIR_SUFFIX}/clang/${CLANG_VERSION}/include)

set(lib_upc_header ${LLVM_BINARY_DIR}/${header_location}/upc-lib.h)
set(lib_upc_header_sources ${PROJECT_SOURCE_DIR}/gen-inline-libupc.pl ${PROJECT_SOURCE_DIR}/smp/upc-lib.in
  ${PROJECT_BINARY_DIR}/config.h
  ${PROJECT_SOURCE_DIR}/smp/upc_access.c
  ${PROJECT_SOURCE_DIR}/smp/upc_access.h
  ${PROJECT_SOURCE_DIR}/smp/upc_config.h
  ${PROJECT_SOURCE_DIR}/smp/upc_defs.h
  ${PROJECT_SOURCE_DIR}/smp/upc_mem.h
  ${PROJECT_SOURCE_DIR}/smp/upc_pts.h
  ${PROJECT_SOURCE_DIR}/smp/upc_sup.h
  ${PROJECT_SOURCE_DIR}/smp/upc_sync.h)
add_custom_target(upc-header ALL DEPENDS ${lib_upc_header})
add_custom_command(OUTPUT ${lib_upc_header}
  COMMAND ${PERL_EXECUTABLE} ${lib_upc_header_sources} > ${lib_upc_header}
  DEPENDS ${lib_upc_header_sources}
  VERBATIM)

set(upc_headers upc.h upc_strict.h upc_relaxed.h)
set(upc_header_targets)
foreach( f ${files} )
  set( src ${PROJECT_SOURCE_DIR}/include/${f} )
  set( dst ${header_location}/${f} )
  add_custom_command(OUTPUT ${dst}
    DEPENDS ${src}
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${src} ${dst}
    COMMENT "Copying clang's ${f}...")
  list(APPEND upc_header_targets ${dst})
endforeach( f )

add_custom_target(upc-headers ALL DEPENDS ${upc_header_targets})

install(FILES include/upc.h include/upc_strict.h include/upc_relaxed.h
  DESTINATION ${header_location})

install(FILES ${objects} ${upc_link_script}
  DESTINATION lib${LLVM_LIBDIR_SUFFIX})

install(TARGETS upc
  DESTINATION lib${LLVM_LIBDIR_SUFFIX})

install(FILES ${lib_upc_header}
  DESTINATION ${header_location})

#===============================================================================
# Setup Tests
#===============================================================================

# add_subdirectory(test)
