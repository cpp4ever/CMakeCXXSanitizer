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

include("${CMAKE_CURRENT_LIST_DIR}/SanitizerCommon.cmake")

set(
   CMAKE_LEAK_SANITIZER_KNOWN_FLAGS

   # Common flags: https://github.com/llvm/llvm-project/blob/main/compiler-rt/lib/sanitizer_common/sanitizer_flags.inc
      symbolize
      external_symbolizer_path
      allow_addr2line
      strip_path_prefix
      fast_unwind_on_check
      fast_unwind_on_fatal
      fast_unwind_on_malloc
      handle_ioctl
      malloc_context_size
      log_path
      log_exe_name
      log_suffix
      log_to_syslog
      verbosity
      strip_env
      verify_interceptors
      detect_leaks
      leak_check_at_exit
      allocator_may_return_null
      print_summary
      print_module_map
      check_printf
      handle_segv
      handle_sigbus
      handle_abort
      handle_sigill
      handle_sigtrap
      handle_sigfpe
      allow_user_segv_handler
      use_sigaltstack
      detect_deadlocks
      clear_shadow_mmap_threshold
      color
      legacy_pthread_cond
      intercept_tls_get_addr
      help
      mmap_limit_mb
      hard_rss_limit_mb
      soft_rss_limit_mb
      max_allocation_size_mb
      heap_profile
      allocator_release_to_os_interval_ms
      can_use_proc_maps_statm
      coverage
      coverage_dir
      cov_8bit_counters_out
      cov_pcs_out
      full_address_space
      print_suppressions
      disable_coredump
      use_madv_dontdump
      symbolize_inline_frames
      demangle
      symbolize_vs_style
      dedup_token_length
      stack_trace_format
      compress_stack_depot
      no_huge_pages_for_shadow
      strict_string_checks
      intercept_strstr
      intercept_strspn
      intercept_strtok
      intercept_strpbrk
      intercept_strcmp
      intercept_strlen
      intercept_strndup
      intercept_strchr
      intercept_memcmp
      strict_memcmp
      intercept_memmem
      intercept_intrin
      intercept_stat
      intercept_send
      decorate_proc_maps
      exitcode
      abort_on_error
      suppress_equal_pcs
      print_cmdline
      html_cov_report
      sancov_path
      dump_instruction_bytes
      dump_registers
      detect_write_exec
      test_only_emulate_no_memorymap
      test_only_replace_dlopen_main_program
      enable_symbolizer_markup
      detect_invalid_join

   # LeakSanitizer flags: https://github.com/llvm/llvm-project/blob/main/compiler-rt/lib/lsan/lsan_flags.inc
      report_objects
      resolution
      max_leaks
      use_globals
      use_stacks
      use_registers
      use_tls
      use_root_regions
      use_ld_allocations
      use_unaligned
      use_poisoned
      log_pointers
      log_threads
)

function(internal_check_lsan IN_LANGUAGE OUT_AVAILABLE)
   # https://clang.llvm.org/docs/LeakSanitizer.html#supported-platforms
   if(NOT APPLE AND NOT CMAKE_${IN_LANGUAGE}_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
      internal_check_compiler_flags(${IN_LANGUAGE} -fsanitize=leak ${OUT_AVAILABLE})
   endif()
endfunction()

function(internal_target_lsan_options IN_LANGUAGE IN_TARGET)
   set(
      LSAN_COMPILE_OPTIONS
      -fno-omit-frame-pointer
      -fsanitize=leak
      -g
   )
   target_compile_options(${IN_TARGET} BEFORE PRIVATE $<$<COMPILE_LANGUAGE:C,CXX>:${LSAN_COMPILE_OPTIONS}>)
   target_link_options(${IN_TARGET} BEFORE PRIVATE $<$<COMPILE_LANGUAGE:C,CXX>:${LSAN_COMPILE_OPTIONS}>)
endfunction()

function(internal_target_lsan IN_LANGUAGE IN_TARGET)
   internal_sanitizer_settings(COMPILETIME_IGNORELIST RUNTIME_FLAGS RUNTIME_SUPPRESSIONS ${ARGN})
   string(LENGTH "${COMPILETIME_IGNORELIST}" COMPILETIME_IGNORELIST_LENGTH)
   if(COMPILETIME_IGNORELIST_LENGTH GREATER 0)
      message(WARNING "LeakSanitizer does not support ignorelist")
   endif()
   internal_target_link_libraries_recursive(${IN_TARGET} TARGET_LINK_LIBRARIES)
   foreach(SUBTARGET IN LISTS TARGET_LINK_LIBRARIES)
      internal_target_lsan_options(${IN_LANGUAGE} ${SUBTARGET})
   endforeach()
   internal_target_lsan_options(${IN_LANGUAGE} ${IN_TARGET})
   internal_target_sanitizer_default_options(${IN_LANGUAGE} ${IN_TARGET} "lsan" "${RUNTIME_FLAGS}")
   internal_target_sanitizer_default_suppressions(${IN_LANGUAGE} ${IN_TARGET} "lsan" "${RUNTIME_SUPPRESSIONS}")
endfunction()
