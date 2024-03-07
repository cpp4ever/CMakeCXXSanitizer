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

function(internal_check_compiler_flags IN_LANGUAGE IN_FLAGS OUT_RESULT)
   if(IN_LANGUAGE STREQUAL "C")
      include(CheckCCompilerFlag)
      set(CMAKE_REQUIRED_FLAGS ${IN_FLAGS})
      check_c_compiler_flag(${CMAKE_REQUIRED_FLAGS} ${OUT_RESULT})
   elseif(IN_LANGUAGE STREQUAL "CXX")
      include(CheckCXXCompilerFlag)
      set(CMAKE_REQUIRED_FLAGS ${IN_FLAGS})
      check_cxx_compiler_flag(${CMAKE_REQUIRED_FLAGS} ${OUT_RESULT})
   else()
      message(FATAL_ERROR "Unknown language: ${IN_LANGUAGE}")
   endif()
endfunction()

function(internal_file_extension IN_LANGUAGE OUT_RESULT)
   if(IN_LANGUAGE STREQUAL "C")
      set(${OUT_RESULT} ".c" PARENT_SCOPE)
   elseif(IN_LANGUAGE STREQUAL "CXX")
      set(${OUT_RESULT} ".cpp" PARENT_SCOPE)
   else()
      message(FATAL_ERROR "Unknown language: ${IN_LANGUAGE}")
   endif()
endfunction()

function(internal_sanitizer_settings OUT_COMPILETIME_IGNORELIST OUT_RUNTIME_FLAGS OUT_RUNTIME_SUPPRESSIONS)
   set(RUNTIME_FLAGS )
   set(COMPILETIME_IGNORELIST )
   set(RUNTIME_SUPPRESSIONS )
   list(LENGTH ARGN EXTRA_ARGS_COUNT)
   set(SANITIZER_SETTINGS_SECTION "F")
   while(EXTRA_ARGS_COUNT GREATER 0)
      list(POP_FRONT ARGN SANITIZER_FLAG)
      if(SANITIZER_FLAG MATCHES "^([Ff][Ll][Aa][Gg][Ss])$")
         set(SANITIZER_SETTINGS_SECTION "F")
      elseif(SANITIZER_FLAG MATCHES "^([Ii][Gg][Nn][Oo][Rr][Ee][Ll][Ii][Ss][Tt])$")
         set(SANITIZER_SETTINGS_SECTION "I")
      elseif(SANITIZER_FLAG MATCHES "^[Ss][Uu][Pp][Pp][Rr][Ee][Ss][Ss][Ii][Oo][Nn][Ss]$")
         set(SANITIZER_SETTINGS_SECTION "S")
      elseif(SANITIZER_SETTINGS_SECTION STREQUAL "F")
         list(APPEND RUNTIME_FLAGS ${SANITIZER_FLAG})
      elseif(SANITIZER_SETTINGS_SECTION STREQUAL "I")
         list(APPEND COMPILETIME_IGNORELIST ${SANITIZER_FLAG})
      elseif(SANITIZER_SETTINGS_SECTION STREQUAL "S")
         list(APPEND RUNTIME_SUPPRESSIONS ${SANITIZER_FLAG})
      endif()
      list(LENGTH ARGN EXTRA_ARGS_COUNT)
   endwhile()
   list(JOIN RUNTIME_FLAGS " " RUNTIME_FLAGS)
   list(JOIN COMPILETIME_IGNORELIST "\n" COMPILETIME_IGNORELIST)
   list(JOIN RUNTIME_SUPPRESSIONS "\\n" RUNTIME_SUPPRESSIONS)
   set(${OUT_COMPILETIME_IGNORELIST} ${COMPILETIME_IGNORELIST} PARENT_SCOPE)
   set(${OUT_RUNTIME_FLAGS} ${RUNTIME_FLAGS} PARENT_SCOPE)
   set(${OUT_RUNTIME_SUPPRESSIONS} ${RUNTIME_SUPPRESSIONS} PARENT_SCOPE)
endfunction()

function(internal_target_link_libraries_recursive IN_TARGET OUT_LINK_LIBRARIES)
   set(LINK_LIBRARIES )
   get_target_property(TARGET_LINK_LIBRARIES ${IN_TARGET} LINK_LIBRARIES)
   if(NOT TARGET_LINK_LIBRARIES STREQUAL TARGET_LINK_LIBRARIES-NOTFOUND)
      foreach(SUBTARGET IN LISTS TARGET_LINK_LIBRARIES)
         if(TARGET ${SUBTARGET})
            get_target_property(ALIASED_SUBTARGET ${SUBTARGET} ALIASED_TARGET)
            if(NOT ALIASED_SUBTARGET STREQUAL ALIASED_SUBTARGET-NOTFOUND)
               set(SUBTARGET ${ALIASED_SUBTARGET})
            endif()
            get_target_property(SUBTARGET_TYPE ${SUBTARGET} TYPE)
            if(NOT SUBTARGET_TYPE STREQUAL "INTERFACE_LIBRARY")
               list(APPEND LINK_LIBRARIES ${SUBTARGET})
            endif()
            internal_target_link_libraries_recursive(${SUBTARGET} SUBTARGET_LINK_LIBRARIES)
            list(APPEND LINK_LIBRARIES ${SUBTARGET_LINK_LIBRARIES})
         endif()
      endforeach()
   endif()
   set(${OUT_LINK_LIBRARIES} ${LINK_LIBRARIES} PARENT_SCOPE)
endfunction()

function(internal_target_sanitizer_default_options IN_LANGUAGE IN_TARGET IN_SANITIZER IN_RUNTIME_FLAGS)
   string(LENGTH "${IN_RUNTIME_FLAGS}" RUNTIME_FLAGS_LENGTH)
   if(RUNTIME_FLAGS_LENGTH GREATER 0)
      get_target_property(TARGET_BINARY_DIR ${IN_TARGET} BINARY_DIR)
      internal_file_extension(${IN_LANGUAGE} LANGUAGE_FILE_EXTENSION)
      set(IN_FILE_PATH "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/__sanitizer_default_options.in")
      set(OUT_FILE_PATH "${TARGET_BINARY_DIR}/CMakeSanitizer/${IN_TARGET}/__${IN_SANITIZER}_default_options${LANGUAGE_FILE_EXTENSION}")
      set(SANITIZER "${IN_SANITIZER}")
      set(RUNTIME_FLAGS "${IN_RUNTIME_FLAGS}")
      configure_file("${IN_FILE_PATH}" "${OUT_FILE_PATH}" @ONLY)
      target_sources(${IN_TARGET} PRIVATE "${OUT_FILE_PATH}")
   endif()
endfunction()

function(internal_target_sanitizer_default_suppressions IN_LANGUAGE IN_TARGET IN_SANITIZER IN_RUNTIME_SUPPRESSIONS)
   string(LENGTH "${IN_RUNTIME_SUPPRESSIONS}" RUNTIME_SUPPRESSIONS_LENGTH)
   if(RUNTIME_SUPPRESSIONS_LENGTH GREATER 0)
      get_target_property(TARGET_BINARY_DIR ${IN_TARGET} BINARY_DIR)
      internal_file_extension(${IN_LANGUAGE} LANGUAGE_FILE_EXTENSION)
      set(IN_FILE_PATH "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/__sanitizer_default_suppressions.in")
      set(OUT_FILE_PATH "${TARGET_BINARY_DIR}/CMakeSanitizer/${IN_TARGET}/__${IN_SANITIZER}_default_suppressions${LANGUAGE_FILE_EXTENSION}")
      set(SANITIZER "${IN_SANITIZER}")
      set(RUNTIME_SUPPRESSIONS "${IN_RUNTIME_SUPPRESSIONS}")
      configure_file("${IN_FILE_PATH}" "${OUT_FILE_PATH}" @ONLY)
      target_sources(${IN_TARGET} PRIVATE "${OUT_FILE_PATH}")
   endif()
endfunction()

function(internal_target_sanitizer_ignorelist IN_LANGUAGE IN_TARGET IN_COMPILETIME_IGNORELIST)
   string(LENGTH "${IN_COMPILETIME_IGNORELIST}" COMPILETIME_IGNORELIST_LENGTH)
   if(COMPILETIME_IGNORELIST_LENGTH GREATER 0)
      if(CMAKE_${IN_LANGUAGE}_COMPILER_ID MATCHES "^(AppleClang|Clang)$" AND NOT CMAKE_${IN_LANGUAGE}_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
         get_target_property(TARGET_BINARY_DIR ${IN_TARGET} BINARY_DIR)
         file(
            CONFIGURE
            OUTPUT "${TARGET_BINARY_DIR}/CMakeSanitizer/${IN_TARGET}/ignorelist"
            CONTENT "${IN_COMPILETIME_IGNORELIST}"
            NEWLINE_STYLE LF
         )
         set(SANITIZER_OPTIONS "-fsanitize-ignorelist=${TARGET_BINARY_DIR}/CMakeSanitizer/${IN_TARGET}/ignorelist")
         target_compile_options(${IN_TARGET} BEFORE PRIVATE $<$<COMPILE_LANGUAGE:C,CXX>:${SANITIZER_OPTIONS}>)
         target_link_options(${IN_TARGET} BEFORE PRIVATE $<$<COMPILE_LANGUAGE:C,CXX>:${SANITIZER_OPTIONS}>)
      else()
         message(WARNING "-fsanitize-ignorelist compile option is supported by Clang only")
      endif()
   endif()
endfunction()
