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

include("${CMAKE_CURRENT_LIST_DIR}/CMakeSanitizer.cmake")

macro(check_c_asan OUT_AVAILABLE)
   check_asan("C" ${OUT_AVAILABLE})
endmacro()

macro(check_c_lsan OUT_AVAILABLE)
   check_lsan("C" ${OUT_AVAILABLE})
endmacro()

macro(check_c_msan OUT_AVAILABLE)
   check_msan("C" ${OUT_AVAILABLE})
endmacro()

macro(check_c_tsan OUT_AVAILABLE)
   check_tsan("C" ${OUT_AVAILABLE})
endmacro()

macro(check_c_ubsan OUT_AVAILABLE)
   check_ubsan("C" ${OUT_AVAILABLE})
endmacro()

macro(available_c_sanitizers OUT_SANITIZERS)
   available_sanitizers("C" ${OUT_SANITIZERS})
endmacro()

macro(target_c_asan IN_TARGET)
   target_asan("C" ${IN_TARGET} ${ARGN})
endmacro()

macro(target_c_lsan IN_TARGET)
   target_lsan("C" ${IN_TARGET} ${ARGN})
endmacro()

macro(target_c_msan IN_TARGET)
   target_msan("C" ${IN_TARGET} ${ARGN})
endmacro()

macro(target_c_tsan IN_TARGET)
   target_tsan("C" ${IN_TARGET} ${ARGN})
endmacro()

macro(target_c_ubsan IN_TARGET)
   target_ubsan("C" ${IN_TARGET} ${ARGN})
endmacro()

macro(target_c_sanitizer IN_TARGET IN_SANITIZER)
   target_sanitizer("C" ${IN_TARGET} ${IN_SANITIZER} ${ARGN})
endmacro()
