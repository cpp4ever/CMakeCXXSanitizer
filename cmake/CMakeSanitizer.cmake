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

include("${CMAKE_CURRENT_LIST_DIR}/Internal/AddressSanitizer.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/Internal/LeakSanitizer.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/Internal/MemorySanitizer.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/Internal/ThreadSanitizer.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/Internal/UndefinedBehaviorSanitizer.cmake")

macro(check_asan IN_LANGUAGE OUT_AVAILABLE)
   internal_check_asan(${IN_LANGUAGE} ${OUT_AVAILABLE})
endmacro()

macro(check_lsan IN_LANGUAGE OUT_AVAILABLE)
   internal_check_lsan(${IN_LANGUAGE} ${OUT_AVAILABLE})
endmacro()

macro(check_msan IN_LANGUAGE OUT_AVAILABLE)
   internal_check_msan(${IN_LANGUAGE} ${OUT_AVAILABLE})
endmacro()

macro(check_tsan IN_LANGUAGE OUT_AVAILABLE)
   internal_check_tsan(${IN_LANGUAGE} ${OUT_AVAILABLE})
endmacro()

macro(check_ubsan IN_LANGUAGE OUT_AVAILABLE)
   internal_check_ubsan(${IN_LANGUAGE} ${OUT_AVAILABLE})
endmacro()

function(available_sanitizers IN_LANGUAGE OUT_SANITIZERS)
   set(AVAILABLE_SANITIZERS )
   check_asan(${IN_LANGUAGE} ${IN_LANGUAGE}_ASAN_AVAILABLE)
   if(${IN_LANGUAGE}_ASAN_AVAILABLE)
      list(APPEND AVAILABLE_SANITIZERS ASan)
   endif()
   check_lsan(${IN_LANGUAGE} ${IN_LANGUAGE}_LSAN_AVAILABLE)
   if(${IN_LANGUAGE}_LSAN_AVAILABLE) 
      list(APPEND AVAILABLE_SANITIZERS LSan)
   endif()
   check_msan(${IN_LANGUAGE} ${IN_LANGUAGE}_MSAN_AVAILABLE)
   if(${IN_LANGUAGE}_MSAN_AVAILABLE) 
      list(APPEND AVAILABLE_SANITIZERS MSan)
   endif()
   check_tsan(${IN_LANGUAGE} ${IN_LANGUAGE}_TSAN_AVAILABLE)
   if(${IN_LANGUAGE}_TSAN_AVAILABLE) 
      list(APPEND AVAILABLE_SANITIZERS TSan)
   endif()
   check_ubsan(${IN_LANGUAGE} ${IN_LANGUAGE}_UBSAN_AVAILABLE)
   if(${IN_LANGUAGE}_UBSAN_AVAILABLE) 
      list(APPEND AVAILABLE_SANITIZERS UBSan)
   endif()
   set(${OUT_SANITIZERS} ${AVAILABLE_SANITIZERS} PARENT_SCOPE)
endfunction()

macro(target_asan IN_LANGUAGE IN_TARGET)
   internal_target_asan(${IN_LANGUAGE} ${IN_TARGET} ${ARGN})
endmacro()

macro(target_lsan IN_LANGUAGE IN_TARGET)
   internal_target_lsan(${IN_LANGUAGE} ${IN_TARGET} ${ARGN})
endmacro()

macro(target_msan IN_LANGUAGE IN_TARGET)
   internal_target_msan(${IN_LANGUAGE} ${IN_TARGET} ${ARGN})
endmacro()

macro(target_tsan IN_LANGUAGE IN_TARGET)
   internal_target_tsan(${IN_LANGUAGE} ${IN_TARGET} ${ARGN})
endmacro()

macro(target_ubsan IN_LANGUAGE IN_TARGET)
   internal_target_ubsan(${IN_LANGUAGE} ${IN_TARGET} ${ARGN})
endmacro()

function(target_sanitizer IN_LANGUAGE IN_TARGET IN_SANITIZER)
   if(IN_SANITIZER MATCHES "^([Aa][Ss][Aa][Nn])$")
      target_asan(${IN_LANGUAGE} ${IN_TARGET} ${ARGN})
   elseif(IN_SANITIZER MATCHES "^([Ll][Ss][Aa][Nn])$")
      target_lsan(${IN_LANGUAGE} ${IN_TARGET} ${ARGN})
   elseif(IN_SANITIZER MATCHES "^([Mm][Ss][Aa][Nn])$")
      target_msan(${IN_LANGUAGE} ${IN_TARGET} ${ARGN})
   elseif(IN_SANITIZER MATCHES "^([Tt][Ss][Aa][Nn])$")
      target_tsan(${IN_LANGUAGE} ${IN_TARGET} ${ARGN})
   elseif(IN_SANITIZER MATCHES "^([Uu][Bb][Ss][Aa][Nn])$")
      target_ubsan(${IN_LANGUAGE} ${IN_TARGET} ${ARGN})
   else()
      message(FATAL_ERROR "Unknown ${IN_LANGUAGE} sanitizer: ${IN_SANITIZER}")
   endif()
endfunction()
