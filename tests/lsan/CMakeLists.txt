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

check_lsan(${LANGUAGE} ${LANGUAGE}_LSAN_AVAILABLE)
if(${LANGUAGE}_LSAN_AVAILABLE)
   prepare_source_files()
   internal_file_extension(${LANGUAGE} LANGUAGE_FILE_EXTENSION)
   add_library(lsan_suppressed_test SHARED "${CMAKE_CURRENT_BINARY_DIR}/src/suppressed.test${LANGUAGE_FILE_EXTENSION}")
   add_library(lsan_instrumented_test SHARED "${CMAKE_CURRENT_BINARY_DIR}/src/instrumented.test${LANGUAGE_FILE_EXTENSION}")
   target_link_libraries(lsan_instrumented_test PUBLIC lsan_suppressed_test)
   add_executable(lsan_test "${CMAKE_CURRENT_BINARY_DIR}/src/test.main${LANGUAGE_FILE_EXTENSION}")
   target_link_libraries(lsan_test PRIVATE lsan_instrumented_test)
   target_lsan(
      ${LANGUAGE}

      lsan_test

      FLAGS # Adds __lsan_default_options function instead of LSAN_OPTIONS env variable
      # Common flags: https://github.com/llvm/llvm-project/blob/main/compiler-rt/lib/sanitizer_common/sanitizer_flags.inc
         detect_leaks=true
         print_suppressions=true
         exitcode=1
         abort_on_error=false
      # LeakSanitizer flags: https://github.com/llvm/llvm-project/blob/main/compiler-rt/lib/lsan/lsan_flags.inc
         use_unaligned=false

      SUPPRESSIONS # Runtime suppressions (adds __lsan_default_suppressions function)
         leak:suppressed.test${LANGUAGE_FILE_EXTENSION} # file
         leak:suppressed_leak # function
         leak:lsan_uninstrumented_test # library
   )
   add_library(lsan_uninstrumented_test SHARED "${CMAKE_CURRENT_BINARY_DIR}/src/uninstrumented.test${LANGUAGE_FILE_EXTENSION}")
   target_link_libraries(lsan_test PRIVATE lsan_uninstrumented_test)
   add_test(NAME LeakSanitizer COMMAND $<TARGET_FILE:lsan_test>)
   set_tests_properties(LeakSanitizer PROPERTIES WILL_FAIL TRUE)
endif()
