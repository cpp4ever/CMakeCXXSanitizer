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

check_ubsan(${LANGUAGE} ${LANGUAGE}_UBSAN_AVAILABLE)
if(${LANGUAGE}_UBSAN_AVAILABLE)
   prepare_source_files()
   internal_file_extension(${LANGUAGE} LANGUAGE_FILE_EXTENSION)
   add_library(ubsan_suppressed_test SHARED "${CMAKE_CURRENT_BINARY_DIR}/src/suppressed.test${LANGUAGE_FILE_EXTENSION}")
   if(CMAKE_${LANGUAGE}_COMPILER_ID MATCHES "^(AppleClang|Clang)$")
      add_library(ubsan_ignored_test SHARED "${CMAKE_CURRENT_BINARY_DIR}/src/ignored.test${LANGUAGE_FILE_EXTENSION}")
      target_ubsan(
         ${LANGUAGE}

         ubsan_ignored_test

         IGNORELIST # Adds -fsanitize-ignorelist=<filename> compiler option (AppleClang and Clang only)
         # https://clang.llvm.org/docs/SanitizerSpecialCaseList.html
            fun:*ignored_integer_overflow*
            src:ignored.test${LANGUAGE_FILE_EXTENSION}
      )
      target_link_libraries(ubsan_suppressed_test PUBLIC ubsan_ignored_test)
   endif()
   add_library(ubsan_instrumented_test SHARED "${CMAKE_CURRENT_BINARY_DIR}/src/instrumented.test${LANGUAGE_FILE_EXTENSION}")
   target_link_libraries(ubsan_instrumented_test PUBLIC ubsan_suppressed_test)
   add_executable(ubsan_test "${CMAKE_CURRENT_BINARY_DIR}/src/test.main${LANGUAGE_FILE_EXTENSION}")
   target_link_libraries(ubsan_test PRIVATE ubsan_instrumented_test)
   target_ubsan(
      ${LANGUAGE}

      ubsan_test

      FLAGS # Adds __ubsan_default_options function instead of UBSAN_OPTIONS env variable
      # Common flags: https://github.com/llvm/llvm-project/blob/main/compiler-rt/lib/sanitizer_common/sanitizer_flags.inc
         print_suppressions=true
         exitcode=0
         abort_on_error=false
      # UndefinedBehaviorSanitizer flags: https://github.com/llvm/llvm-project/blob/main/compiler-rt/lib/ubsan/ubsan_flags.inc
         halt_on_error=true
         print_stacktrace=true
         report_error_type=true
         silence_unsigned_overflow=false

      SUPPRESSIONS # Runtime suppressions (adds suppressions file dependency in runtime)
         signed-integer-overflow:suppressed_integer_overflow
   )
   add_library(ubsan_uninstrumented_test SHARED "${CMAKE_CURRENT_BINARY_DIR}/src/uninstrumented.test${LANGUAGE_FILE_EXTENSION}")
   target_link_libraries(ubsan_test PRIVATE ubsan_uninstrumented_test)
   add_test(NAME UndefinedBehaviorSanitizer COMMAND $<TARGET_FILE:ubsan_test>)
   set(
      UBSAN_TEST_FAIL_REGEX
      "ignored\\.test"
      "suppressed\\.test"
      "uninstrumented\\.test"
      "in ignored_integer_overflow"
      "in suppressed_integer_overflow"
      "in uninstrumented_integer_overflow"
   )
   set(
      UBSAN_TEST_PASS_REGEX
      "instrumented\\.test\\${LANGUAGE_FILE_EXTENSION}.*\\: runtime error\\: signed integer overflow\\: 1 \\+ 2147483647 cannot be represented in type 'int'"
      "in instrumented_integer_overflow.* .*instrumented\\.test\\${LANGUAGE_FILE_EXTENSION}"
   )
   set_tests_properties(
      UndefinedBehaviorSanitizer
      PROPERTIES
         FAIL_REGULAR_EXPRESSION "${UBSAN_TEST_FAIL_REGEX}"
         PASS_REGULAR_EXPRESSION "${UBSAN_TEST_PASS_REGEX}"
   )
endif()
