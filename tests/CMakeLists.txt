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

function(prepare_source_files)
   file(GLOB_RECURSE IN_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*.in")
   internal_file_extension(${LANGUAGE} LANGUAGE_FILE_EXTENSION)
   foreach(IN_SOURCE IN LISTS IN_SOURCES)
      string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/src/" OUT_SOURCE "${IN_SOURCE}")
      string(REGEX REPLACE "\.in$" "${LANGUAGE_FILE_EXTENSION}" OUT_SOURCE "${OUT_SOURCE}")
      configure_file("${IN_SOURCE}" "${OUT_SOURCE}" COPYONLY)
   endforeach()
endfunction()

add_subdirectory(asan)
add_subdirectory(lsan)
add_subdirectory(msan)
add_subdirectory(tsan)
add_subdirectory(ubsan)
