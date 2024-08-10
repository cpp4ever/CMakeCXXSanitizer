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

macro(check_cxx_asan OUT_AVAILABLE)
   check_asan("CXX" ${OUT_AVAILABLE})
endmacro()

macro(check_cxx_lsan OUT_AVAILABLE)
   check_lsan("CXX" ${OUT_AVAILABLE})
endmacro()

macro(check_cxx_msan OUT_AVAILABLE)
   check_msan("CXX" ${OUT_AVAILABLE})
endmacro()

macro(check_cxx_tsan OUT_AVAILABLE)
   check_tsan("CXX" ${OUT_AVAILABLE})
endmacro()

macro(check_cxx_ubsan OUT_AVAILABLE)
   check_ubsan("CXX" ${OUT_AVAILABLE})
endmacro()

macro(available_cxx_sanitizers OUT_SANITIZERS)
   available_sanitizers("CXX" ${OUT_SANITIZERS})
endmacro()

macro(target_cxx_asan IN_TARGET)
   target_asan("CXX" ${IN_TARGET} ${ARGN})
endmacro()

macro(target_cxx_lsan IN_TARGET)
   target_lsan("CXX" ${IN_TARGET} ${ARGN})
endmacro()

macro(target_cxx_msan IN_TARGET)
   target_msan("CXX" ${IN_TARGET} ${ARGN})
endmacro()

macro(target_cxx_tsan IN_TARGET)
   target_tsan("CXX" ${IN_TARGET} ${ARGN})
endmacro()

macro(target_cxx_ubsan IN_TARGET)
   target_ubsan("CXX" ${IN_TARGET} ${ARGN})
endmacro()

macro(target_cxx_sanitizer IN_TARGET IN_SANITIZER)
   target_sanitizer("CXX" ${IN_TARGET} ${IN_SANITIZER} ${ARGN})
endmacro()
