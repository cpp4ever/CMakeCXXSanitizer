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

check_tsan(${LANGUAGE} ${LANGUAGE}_TSAN_AVAILABLE)
if(${LANGUAGE}_TSAN_AVAILABLE)
   prepare_source_files()
   internal_file_extension(${LANGUAGE} LANGUAGE_FILE_EXTENSION)
   add_library(tsan_suppressed_test SHARED "${CMAKE_CURRENT_BINARY_DIR}/src/suppressed.test${LANGUAGE_FILE_EXTENSION}")
   if(CMAKE_${LANGUAGE}_COMPILER_ID MATCHES "^(AppleClang|Clang)$")
      add_library(tsan_ignored_test SHARED "${CMAKE_CURRENT_BINARY_DIR}/src/ignored.test${LANGUAGE_FILE_EXTENSION}")
      target_tsan(
         ${LANGUAGE}

         tsan_ignored_test

         IGNORELIST # Adds -fsanitize-ignorelist=<filename> compiler option (AppleClang and Clang only)
         # https://clang.llvm.org/docs/SanitizerSpecialCaseList.html
            fun:*ignored_race*
            src:ignored.test${LANGUAGE_FILE_EXTENSION}
      )
      target_link_libraries(tsan_suppressed_test PUBLIC tsan_ignored_test)
   endif()
   add_library(tsan_instrumented_test SHARED "${CMAKE_CURRENT_BINARY_DIR}/src/instrumented.test${LANGUAGE_FILE_EXTENSION}")
   target_link_libraries(tsan_instrumented_test PUBLIC tsan_suppressed_test)
   add_executable(tsan_test "${CMAKE_CURRENT_BINARY_DIR}/src/test.main${LANGUAGE_FILE_EXTENSION}")
   target_link_libraries(tsan_test PRIVATE tsan_instrumented_test)
   target_tsan(
      ${LANGUAGE}

      tsan_test

      FLAGS # Adds __tsan_default_options function instead of TSAN_OPTIONS env variable
      # Common flags: https://github.com/llvm/llvm-project/blob/main/compiler-rt/lib/sanitizer_common/sanitizer_flags.inc
         print_suppressions=true
         exitcode=1
         abort_on_error=false
      # ThreadSanitizer flags: https://github.com/llvm/llvm-project/blob/main/compiler-rt/lib/tsan/rtl/tsan_flags.inc
         suppress_equal_stacks=false

      SUPPRESSIONS # Runtime suppressions (adds __tsan_default_suppressions function)
      # https://github.com/google/sanitizers/wiki/ThreadSanitizerSuppressions
         called_from_lib:suppressed_tsan_test # library
         race:global_suppressed_race_value # global variable
         race:suppressed_race # function
         race:suppressed_tsan.test${LANGUAGE_FILE_EXTENSION} # file
   )
   add_library(tsan_uninstrumented_test SHARED "${CMAKE_CURRENT_BINARY_DIR}/src/uninstrumented.test${LANGUAGE_FILE_EXTENSION}")
   target_link_libraries(tsan_test PRIVATE tsan_uninstrumented_test)
   add_test(NAME ThreadSanitizer COMMAND $<TARGET_FILE:tsan_test>)
   set_tests_properties(ThreadSanitizer PROPERTIES WILL_FAIL TRUE)
endif()
