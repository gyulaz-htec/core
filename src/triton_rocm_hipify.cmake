# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

find_package(Python3 COMPONENTS Interpreter REQUIRED)

function(auto_set_source_files_hip_language)
  foreach(f ${ARGN})
    if(f MATCHES ".*\\.cu$")
      set_source_files_properties(${f} PROPERTIES LANGUAGE HIP)
    endif()
  endforeach()
endfunction()

# cuda_dir must be relative to REPO_ROOT
function(hipify src_files out_generated_files)
  set(hipify_tool ${REPO_ROOT}/amd_hipify.py)

  message(STATUS "@@@ REPO_ROOT ${REPO_ROOT}")
  file(GLOB_RECURSE srcs CONFIGURE_DEPENDS
    "${REPO_ROOT}/*.h"
    "${REPO_ROOT}/*.cc"
  )
  message(STATUS "@@@ srcs ${srcs}")
  message(STATUS "@@@ hipify_tool ${hipify_tool}")
  message(STATUS "@@@ File list ${src_files}")
  message(STATUS "@@@ out_generated_files ${out_generated_files}")

  foreach(f ${src_files})
    set(cuda_f_rel "${REPO_ROOT}/${f}")
    message("@@@ Processing ${cuda_f_rel}")
    # string(REPLACE "cuda" "rocm" rocm_f_rel ${cuda_f_rel})
    # set(f_out "${CMAKE_CURRENT_BINARY_DIR}/amdgpu/${rocm_f_rel}")
    set(f_out "${cuda_f_rel}")
    add_custom_command(
      OUTPUT ${f_out}
      COMMAND Python3::Interpreter ${hipify_tool}
      --hipify_perl ${TRITON_HIPIFY_PERL}
      ${cuda_f_rel} -o ${f_out}
      DEPENDS ${hipify_tool} ${cuda_f_rel}
      )
    message(STATUS "@@@ Hipify: ${cuda_f_rel} -> ${f_out}")
    list(APPEND generated_files ${f_out})
  endforeach()

  set_source_files_properties(${generated_files} PROPERTIES GENERATED TRUE)
  auto_set_source_files_hip_language(${generated_files})
  set(${out_generated_files} ${generated_files} PARENT_SCOPE)
endfunction()
