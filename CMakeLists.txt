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

cmake_minimum_required(VERSION 3.20)

include(CMakeCSanitizer.cmake)
include(CMakeCXXSanitizer.cmake)

get_filename_component(CMAKE_SANITIZER_PROJECT_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR} REALPATH)
get_filename_component(MAIN_PROJECT_SOURCE_DIR ${CMAKE_SOURCE_DIR} REALPATH)
if("${CMAKE_SANITIZER_PROJECT_SOURCE_DIR}" STREQUAL "${MAIN_PROJECT_SOURCE_DIR}")
   set(LANGUAGE "C" CACHE STRING "Choose language")
   set_property(CACHE LANGUAGE PROPERTY STRINGS "C;CXX")
   set_property(GLOBAL PROPERTY USE_FOLDERS ON)
   project(CMakeSanitizer LANGUAGES ${LANGUAGE})
   set(CMAKE_${LANGUAGE}_EXTENSIONS OFF)
   set(CMAKE_${LANGUAGE}_STANDARD_REQUIRED ON)
   set(CMAKE_${LANGUAGE}_STANDARD 11)
   enable_testing()
   set(SANITIZERS_PATH_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/")
   if(WIN32)
      string(REPLACE "/" "\\\\" SANITIZERS_PATH_PREFIX ${SANITIZERS_PATH_PREFIX})
   endif()
   add_subdirectory(tests)
   if(TARGET asan_test)
      set_property(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" PROPERTY VS_STARTUP_PROJECT asan_test)
   endif()
endif()
