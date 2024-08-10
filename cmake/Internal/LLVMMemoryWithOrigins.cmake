#[[
   Part of the CMakeSanitizer Project (https://github.com/cpp4ever/CMakeSanitizer), under the MIT License
   SPDX-License-Identifier: MIT

   Copyright (c) 2024 Mikhail Smirnov

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.
]]

include(ExternalProject)

get_property(MULTICONFIG_GENERATOR GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(MULTICONFIG_GENERATOR)
   set(LLVM_EXTRA_ARGUMENTS )
else()
   set(LLVM_EXTRA_ARGUMENTS -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE})
endif()
if(NOT "${CMAKE_C_COMPILER}" STREQUAL "")
   list(APPEND LLVM_EXTRA_ARGUMENTS -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER})
endif()
if(NOT "${CMAKE_C_EXTENSIONS}" STREQUAL "")
   list(APPEND LLVM_EXTRA_ARGUMENTS -DCMAKE_C_EXTENSIONS:STRING=${CMAKE_C_EXTENSIONS})
endif()
if(NOT "${CMAKE_C_STANDARD_REQUIRED}" STREQUAL "")
   list(APPEND LLVM_EXTRA_ARGUMENTS -DCMAKE_C_STANDARD_REQUIRED:STRING=${CMAKE_C_STANDARD_REQUIRED})
endif()
if(NOT "${CMAKE_C_STANDARD}" STREQUAL "")
   list(APPEND LLVM_EXTRA_ARGUMENTS -DCMAKE_C_STANDARD:STRING=${CMAKE_C_STANDARD})
endif()
if(NOT "${CMAKE_CXX_COMPILER}" STREQUAL "")
   list(APPEND LLVM_EXTRA_ARGUMENTS -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER})
endif()
if(NOT "${CMAKE_CXX_EXTENSIONS}" STREQUAL "")
   list(APPEND LLVM_EXTRA_ARGUMENTS -DCMAKE_CXX_EXTENSIONS:STRING=${CMAKE_CXX_EXTENSIONS})
endif()
if(NOT "${CMAKE_CXX_STANDARD_REQUIRED}" STREQUAL "")
   list(APPEND LLVM_EXTRA_ARGUMENTS -DCMAKE_CXX_STANDARD_REQUIRED:STRING=${CMAKE_CXX_STANDARD_REQUIRED})
endif()
if(NOT "${CMAKE_CXX_STANDARD}" STREQUAL "")
   list(APPEND LLVM_EXTRA_ARGUMENTS -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD})
endif()
cmake_host_system_information(RESULT LLVM_NUMBER_OF_PHYSICAL_CORES QUERY NUMBER_OF_PHYSICAL_CORES)
ExternalProject_Add(
   LLVMMemoryWithOrigins
   # Directory Options
   PREFIX "${CMAKE_CURRENT_BINARY_DIR}/LLVMMemoryWithOrigins"
   # Download Step Options
   GIT_PROGRESS ON
   GIT_REMOTE_UPDATE_STRATEGY CHECKOUT
   GIT_REPOSITORY https://github.com/llvm/llvm-project.git
   GIT_SHALLOW ON
   GIT_SUBMODULES_RECURSE ON
   GIT_TAG llvmorg-${CMAKE_CXX_COMPILER_VERSION}
   # Configure Step Options
   CMAKE_ARGS
      -DLLVM_ENABLE_RUNTIMES='libcxx|libcxxabi|libunwind'
      -DLLVM_USE_SANITIZER:STRING=MemoryWithOrigins # Enable MSan
      -Wno-dev
      ${LLVM_EXTRA_ARGUMENTS}
   CONFIGURE_HANDLED_BY_BUILD ON
   SOURCE_SUBDIR runtimes
   # Build Step Options
   BUILD_COMMAND ${CMAKE_COMMAND} --build . --config $<CONFIG> --parallel ${LLVM_NUMBER_OF_PHYSICAL_CORES} --target=cxx --target=cxxabi
   # Install Step Options
   INSTALL_COMMAND ""
   # Test Step Options
   TEST_COMMAND ""
   # Output Logging Options
   LOG_BUILD ON
   LOG_CONFIGURE ON
   LOG_DOWNLOAD ON
   LOG_MERGED_STDOUTERR ON
   LOG_OUTPUT_ON_FAILURE ON
   LOG_UPDATE ON
   # Target Options
   EXCLUDE_FROM_ALL ON
   # Miscellaneous Options
   LIST_SEPARATOR |
)
ExternalProject_Get_Property(LLVMMemoryWithOrigins BINARY_DIR)
add_library(libcxx_memory_with_origins INTERFACE EXCLUDE_FROM_ALL)
add_dependencies(libcxx_memory_with_origins LLVMMemoryWithOrigins)
target_compile_options(libcxx_memory_with_origins INTERFACE $<$<COMPILE_LANGUAGE:CXX>:-stdlib=libc++>)
target_link_directories(libcxx_memory_with_origins INTERFACE $<$<COMPILE_LANGUAGE:CXX>:${BINARY_DIR}/lib/>)
target_link_options(libcxx_memory_with_origins INTERFACE $<$<COMPILE_LANGUAGE:CXX>:-stdlib=libc++>)
