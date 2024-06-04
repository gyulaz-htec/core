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
function(hipify srcs in_excluded_file_patterns out_generated_files)
  set(hipify_tool ${REPO_ROOT}/amd_hipify.py)
  # do exclusion
  set(excluded_file_patterns ${${in_excluded_file_patterns}})
  message(STATUS "Project Root ${REPO_ROOT} ")

  foreach(f ${srcs})
    message("Processing ${f}")
    set(f_out "${CMAKE_CURRENT_BINARY_DIR}/amdgpu/${f}")
    add_custom_command(
      OUTPUT ${f_out}
      COMMAND Python3::Interpreter ${hipify_tool}
      --hipify_perl ${TRITON_HIPIFY_PERL}
      ${f} -o ${f_out}
      DEPENDS ${hipify_tool} ${f}
      COMMENT WARNING "Hipify: ${cuda_f_rel} -> amdgpu/${rocm_f_rel}"
      )

      list(APPEND generated_files ${f_out})

  endforeach()

  file(GLOB_RECURSE generated_srcs CONFIGURE_DEPENDS
  "${CMAKE_CURRENT_BINARY_DIR}/amdgpu/*.h"
  "${CMAKE_CURRENT_BINARY_DIR}/amdgpu/*.cc"
  )

  message("## generated_srcs: ${generated_srcs}")

  set_source_files_properties(${generated_files} PROPERTIES GENERATED TRUE)
  set(${out_generated_files} ${generated_files} PARENT_SCOPE)
endfunction()
