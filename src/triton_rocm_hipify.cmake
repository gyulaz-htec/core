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

# # cuda_dir must be relative to REPO_ROOT
# function(hipify src_files out_generated_files)
#   file(GLOB_RECURSE hipify_tool CONFIGURE_DEPENDS
#     "${REPO_ROOT}/*.py"
#   )
#   # set(hipify_tool "${REPO_ROOT}/amd_hipify.py")

#   message(STATUS "@@@ REPO_ROOT ${REPO_ROOT}")
#   file(GLOB_RECURSE srcs CONFIGURE_DEPENDS
#     "${REPO_ROOT}/*.h"
#     "${REPO_ROOT}/*.cc"
#   )
#   message(STATUS "@@@ srcs ${srcs}")
#   message(STATUS "@@@ hipify_tool ${hipify_tool}")
#   message(STATUS "@@@ File list ${src_files}")

#   foreach(f ${src_files})
#     set(cuda_f_rel "${REPO_ROOT}/${f}")
#     message("@@@ Processing ${cuda_f_rel} ")
#     set(f_out "${CMAKE_CURRENT_BINARY_DIR}/amdgpu/${cuda_f_rel}")
#     # set(f_out "${cuda_f_rel}")
#     add_custom_command(
#       OUTPUT ${f_out}
#       COMMAND Python3::Interpreter ${hipify_tool}
#       --hipify_perl ${TRITON_HIPIFY_PERL}
#       ${cuda_f_rel} -o ${f_out}
#       DEPENDS ${hipify_tool} ${cuda_f_rel}
#       COMMENT WARNING "Hipify: ${cuda_f_rel} -> ${cuda_f_rel}"
#     )
#     list(APPEND generated_files ${f_out})
#   endforeach()

#   file(GLOB_RECURSE generated_srcs CONFIGURE_DEPENDS
#     "${CMAKE_CURRENT_BINARY_DIR}/amdgpu/*.h"
#     "${CMAKE_CURRENT_BINARY_DIR}/amdgpu/*.cc"
#   )
#   message(STATUS "### Generated srcs: ${generated_srcs}")

#   set_source_files_properties(${generated_files} PROPERTIES GENERATED TRUE)
#   auto_set_source_files_hip_language(${generated_files})
#   set(${out_generated_files} ${generated_files} PARENT_SCOPE)
#   message(STATUS "@@@ out_generated_files ${out_generated_files}")
# endfunction()

# cuda_dir must be relative to REPO_ROOT
function(hipify srcs in_excluded_file_patterns out_generated_cc_files out_generated_h_files)
  set(hipify_tool ${REPO_ROOT}/amd_hipify.py)
  #message(FATAL_ERROR "Tool is ${hipify_tool}")

  #  file(GLOB_RECURSE srcs CONFIGURE_DEPENDS
  #   "${REPO_ROOT}/*.h"
  #   "${REPO_ROOT}/*.cc"
  #   "${REPO_ROOT}/*.cuh"
  #   "${REPO_ROOT}/*.cu"
  #  )

  # do exclusion
  set(excluded_file_patterns ${${in_excluded_file_patterns}})
  #list(TRANSFORM excluded_file_patterns PREPEND "${REPO_ROOT}/${cuda_dir}/")
  #file(GLOB_RECURSE excluded_srcs CONFIGURE_DEPENDS ${excluded_file_patterns})
  #foreach(f ${excluded_srcs})
 #   message(STATUS "Excluded from hipify: ${f}")
 # endforeach()
 # list(REMOVE_ITEM srcs ${excluded_srcs})

# message(STATUS "File list ${srcs} from ${cuda_dir} ")
message(STATUS "Project Root ${REPO_ROOT} ")

  foreach(f ${srcs})
    message("Processing ${f}")
    file(RELATIVE_PATH cuda_f_rel "${REPO_ROOT}" "${REPO_ROOT}/${f}")
    # string(REPLACE "cuda" "rocm" rocm_f_rel ${cuda_f_rel})
    set(f_out "${CMAKE_CURRENT_BINARY_DIR}/amdgpu/${cuda_f_rel}")
    add_custom_command(
      OUTPUT ${f_out}
      COMMAND Python3::Interpreter ${hipify_tool}
      --hipify_perl ${TRITON_HIPIFY_PERL}
      ${f} -o ${f_out}
      DEPENDS ${hipify_tool} ${f}
      COMMENT WARNING "Hipify: ${cuda_f_rel} -> amdgpu/${rocm_f_rel}"
      )

    if(f MATCHES ".*\\.h")
      list(APPEND generated_h_files ${f_out})
    else()
      list(APPEND generated_cc_files ${f_out})
    endif()

  endforeach()

  set_source_files_properties(${generated_cc_files} PROPERTIES GENERATED TRUE)
  set_source_files_properties(${generated_h_files} PROPERTIES GENERATED TRUE)
  set(${out_generated_cc_files} ${generated_cc_files} PARENT_SCOPE)
  set(${out_generated_h_files} ${generated_h_files} PARENT_SCOPE)
  #message(FATAL_ERROR "List of out_files: ${generated_cc_files}")
endfunction()
