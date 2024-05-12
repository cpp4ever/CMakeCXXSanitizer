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

check_asan(${LANGUAGE} ${LANGUAGE}_ASAN_AVAILABLE)
if(${LANGUAGE}_ASAN_AVAILABLE)
   prepare_source_files()
   internal_file_extension(${LANGUAGE} LANGUAGE_FILE_EXTENSION)
   add_library(asan_instrumented_test SHARED "${CMAKE_CURRENT_BINARY_DIR}/src/instrumented.test${LANGUAGE_FILE_EXTENSION}")
   if(CMAKE_${LANGUAGE}_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
      # __asan_default_suppressions is not called if compiled with MSVC
      set(ASAN_SUPPRESSIONS_SUPPORTED OFF)
   elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin" AND CMAKE_${LANGUAGE}_COMPILER_ID STREQUAL "GNU" AND LANGUAGE STREQUAL "C")
      # __asan_default_suppressions is not called if compiled with GCC C compiler for macOS
      set(ASAN_SUPPRESSIONS_SUPPORTED OFF)
   else()
      set(ASAN_SUPPRESSIONS_SUPPORTED ON)
   endif()
   if(ASAN_SUPPRESSIONS_SUPPORTED)
      add_library(asan_suppressed_test SHARED "${CMAKE_CURRENT_BINARY_DIR}/src/suppressed.test${LANGUAGE_FILE_EXTENSION}")
      target_link_libraries(asan_instrumented_test PUBLIC asan_suppressed_test)
      set(
         ASAN_SUPPRESSIONS
         SUPPRESSIONS # Runtime suppressions (adds __asan_default_suppressions function)
            interceptor_via_fun:suppressed_heap_buffer_overflow
            interceptor_via_lib:asan_suppressed_test
      )
   endif()
   if(CMAKE_${LANGUAGE}_COMPILER_ID MATCHES "^(AppleClang|Clang)$")
      add_library(asan_ignored_test SHARED "${CMAKE_CURRENT_BINARY_DIR}/src/ignored.test${LANGUAGE_FILE_EXTENSION}")
      target_asan(
         ${LANGUAGE}

         asan_ignored_test

         IGNORELIST # Adds -fsanitize-ignorelist=<filename> compiler option (AppleClang and Clang only)
         # https://clang.llvm.org/docs/SanitizerSpecialCaseList.html
            fun:*ignored_use_after_free*
            src:ignored.test${LANGUAGE_FILE_EXTENSION}
      )
      target_link_libraries(asan_suppressed_test PUBLIC asan_ignored_test)
   endif()
   add_executable(asan_test "${CMAKE_CURRENT_BINARY_DIR}/src/test.main${LANGUAGE_FILE_EXTENSION}")
   target_link_libraries(asan_test PRIVATE asan_instrumented_test)
   target_asan(
      ${LANGUAGE}

      asan_test

      FLAGS # Adds __asan_default_options function instead of ASAN_OPTIONS env variable
      # Common flags: https://github.com/llvm/llvm-project/blob/main/compiler-rt/lib/sanitizer_common/sanitizer_flags.inc
         detect_leaks=false
         print_suppressions=true
         exitcode=0
         abort_on_error=false
      # AddressSanitizer flags: https://github.com/llvm/llvm-project/blob/main/compiler-rt/lib/asan/asan_flags.inc
         check_initialization_order=true
         detect_stack_use_after_return=true
         halt_on_error=true

      ${ASAN_SUPPRESSIONS}
   )
   add_library(asan_uninstrumented_test SHARED "${CMAKE_CURRENT_BINARY_DIR}/src/uninstrumented.test${LANGUAGE_FILE_EXTENSION}")
   target_link_libraries(asan_test PRIVATE asan_uninstrumented_test)
   add_test(NAME AddressSanitizer COMMAND $<TARGET_FILE:asan_test>)
   set(
      ASAN_TEST_FAIL_REGEXP
      "ignored\\.test"
      "suppressed\\.test"
      "uninstrumented\\.test"
      "ignored_use_after_free"
      "suppressed_heap_buffer_overflow"
      "uninstrumented_use_after_free"
   )
   set(
      ASAN_TEST_PASS_REGEXP
      "SUMMARY\\: AddressSanitizer\\: heap-use-after-free .*instrumented\\.test\\${LANGUAGE_FILE_EXTENSION}.* in instrumented_use_after_free"
      "SUMMARY\\: AddressSanitizer\\: heap-use-after-free \\(.*asan_instrumented_test.*\\)"
   )
   set_tests_properties(
      AddressSanitizer
      PROPERTIES
         FAIL_REGULAR_EXPRESSION "${ASAN_TEST_FAIL_REGEXP}"
         PASS_REGULAR_EXPRESSION "${ASAN_TEST_PASS_REGEXP}"
   )
   get_filename_component(LINKER_DIRECTORY ${CMAKE_LINKER} DIRECTORY)
   if(CMAKE_${LANGUAGE}_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
      string(LENGTH "${LINKER_DIRECTORY}" LINKER_DIRECTORY_LENGTH)
      if(LINKER_DIRECTORY_LENGTH GREATER 0)
         set_tests_properties(AddressSanitizer PROPERTIES ENVIRONMENT "PATH=${LINKER_DIRECTORY};$ENV{PATH}")
      endif()
   endif()
endif()
