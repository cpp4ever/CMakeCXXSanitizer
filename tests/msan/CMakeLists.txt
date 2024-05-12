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

check_msan(${LANGUAGE} ${LANGUAGE}_MSAN_AVAILABLE)
if(${LANGUAGE}_MSAN_AVAILABLE)
   prepare_source_files()
   internal_file_extension(${LANGUAGE} LANGUAGE_FILE_EXTENSION)
   add_library(msan_ignored_test SHARED "${CMAKE_CURRENT_BINARY_DIR}/src/ignored.test${LANGUAGE_FILE_EXTENSION}")
   target_msan(
      ${LANGUAGE}

      msan_ignored_test

      IGNORELIST # Adds -fsanitize-ignorelist=<filename> compiler option
      # https://clang.llvm.org/docs/SanitizerSpecialCaseList.html
         fun:*ignored_use_of_uninitialized_value*
         src:ignored.test${LANGUAGE_FILE_EXTENSION}
   )
   add_library(msan_instrumented_test SHARED "${CMAKE_CURRENT_BINARY_DIR}/src/instrumented.test${LANGUAGE_FILE_EXTENSION}")
   target_link_libraries(msan_instrumented_test PUBLIC msan_ignored_test)
   add_executable(msan_test "${CMAKE_CURRENT_BINARY_DIR}/src/test.main${LANGUAGE_FILE_EXTENSION}")
   target_link_libraries(msan_test PRIVATE msan_instrumented_test)
   target_msan(
      ${LANGUAGE}

      msan_test

      FLAGS # Adds __msan_default_options function instead of MSAN_OPTIONS env variable
      # Common flags: https://github.com/llvm/llvm-project/blob/main/compiler-rt/lib/sanitizer_common/sanitizer_flags.inc
         exitcode=0
         abort_on_error=false
      # MemorySanitizer flags: https://github.com/llvm/llvm-project/blob/main/compiler-rt/lib/msan/msan_flags.inc
         origin_history_size=0
         halt_on_error=true
   )
   add_library(msan_uninstrumented_test SHARED "${CMAKE_CURRENT_BINARY_DIR}/src/uninstrumented.test${LANGUAGE_FILE_EXTENSION}")
   target_link_libraries(msan_test PRIVATE msan_uninstrumented_test)
   add_test(NAME MemorySanitizer COMMAND $<TARGET_FILE:msan_test>)
   set(
      MSAN_TEST_FAIL_REGEX
      "ignored\\.test"
      "uninstrumented\\.test"
      "ignored_use_of_uninitialized_value"
      "uninstrumented_use_of_uninitialized_value"
   )
   set(
      MSAN_TEST_PASS_REGEX
      "SUMMARY\\: MemorySanitizer\\: use-of-uninitialized-value .*instrumented\\.test\\${LANGUAGE_FILE_EXTENSION}.* in instrumented_use_of_uninitialized_value"
   )
   set_tests_properties(
      MemorySanitizer
      PROPERTIES
         FAIL_REGULAR_EXPRESSION "${MSAN_TEST_FAIL_REGEX}"
         PASS_REGULAR_EXPRESSION "${MSAN_TEST_PASS_REGEX}"
   )
endif()
