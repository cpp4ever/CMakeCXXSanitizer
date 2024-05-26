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
   CMAKE_ADDRESS_SANITIZER_KNOWN_FLAGS

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

   # AddressSanitizer flags: https://github.com/llvm/llvm-project/blob/main/compiler-rt/lib/asan/asan_flags.inc
      quarantine_size
      quarantine_size_mb
      thread_local_quarantine_size_kb
      redzone
      max_redzone
      debug
      report_globals
      check_initialization_order
      replace_str
      replace_intrin
      detect_stack_use_after_return
      min_uar_stack_size_log
      max_uar_stack_size_log
      uar_noreserve
      max_malloc_fill_size
      max_free_fill_size
      malloc_fill_byte
      free_fill_byte
      allow_user_poisoning
      sleep_before_dying
      sleep_after_init
      sleep_before_init
      check_malloc_usable_size
      unmap_shadow_on_exit
      protect_shadow_gap
      print_stats
      print_legend
      print_scariness
      atexit
      print_full_thread_history
      poison_heap
      poison_partial
      poison_array_cookie
      alloc_dealloc_mismatch
      new_delete_type_mismatch
      strict_init_order
      start_deactivated
      detect_invalid_pointer_pairs
      detect_container_overflow
      detect_odr_violation
      halt_on_error
      allocator_frees_and_returns_null_on_realloc_zero
      verify_asan_link_order
      windows_hook_rtl_allocators
)

function(internal_check_asan IN_LANGUAGE OUT_AVAILABLE)
   # https://clang.llvm.org/docs/AddressSanitizer.html#supported-platforms
   if(CMAKE_${IN_LANGUAGE}_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
      if(CMAKE_${IN_LANGUAGE}_COMPILER_ID STREQUAL "MSVC")
         internal_check_compiler_flags(${IN_LANGUAGE} /fsanitize=address ${OUT_AVAILABLE})
      endif()
   else()
      internal_check_compiler_flags(${IN_LANGUAGE} -fsanitize=address ${OUT_AVAILABLE})
   endif()
endfunction()

function(internal_target_asan_options IN_LANGUAGE IN_TARGET IN_COMPILETIME_IGNORELIST)
   if(CMAKE_${IN_LANGUAGE}_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
      target_compile_options(${IN_TARGET} BEFORE PRIVATE $<$<COMPILE_LANGUAGE:C,CXX>:/fsanitize=address /Oy- /Zi>)
      target_link_options(${IN_TARGET} BEFORE PRIVATE $<$<COMPILE_LANGUAGE:C,CXX>:/DEBUG /INCREMENTAL:NO>)
   else()
      set(
         ASAN_COMPILE_OPTIONS
         -fno-common
         -fno-omit-frame-pointer
         -fno-optimize-sibling-calls
         -fsanitize=address
         -fsanitize-address-use-after-scope
         -g
      )
      internal_check_compiler_flags(
         ${IN_LANGUAGE}
         "-fsanitize=address -fsanitize-address-use-after-return=always"
         ${IN_LANGUAGE}_ASAN_USE_AFTER_RETURN_SUPPORTED
      )
      if(${IN_LANGUAGE}_ASAN_USE_AFTER_RETURN_SUPPORTED)
         list(APPEND ASAN_COMPILE_OPTIONS -fsanitize-address-use-after-return=always)
      endif()
      target_compile_options(${IN_TARGET} BEFORE PRIVATE $<$<COMPILE_LANGUAGE:C,CXX>:${ASAN_COMPILE_OPTIONS}>)
      target_link_options(${IN_TARGET} BEFORE PRIVATE $<$<COMPILE_LANGUAGE:C,CXX>:${ASAN_COMPILE_OPTIONS}>)
   endif()
   internal_target_sanitizer_ignorelist(${IN_LANGUAGE} ${IN_TARGET} "${IN_COMPILETIME_IGNORELIST}")
endfunction()

function(internal_target_asan IN_LANGUAGE IN_TARGET)
   internal_sanitizer_settings(COMPILETIME_IGNORELIST RUNTIME_FLAGS RUNTIME_SUPPRESSIONS ${ARGN})
   internal_target_link_libraries_recursive(${IN_TARGET} TARGET_LINK_LIBRARIES)
   foreach(SUBTARGET IN LISTS TARGET_LINK_LIBRARIES)
      internal_target_asan_options(${IN_LANGUAGE} ${SUBTARGET} "")
   endforeach()
   internal_target_asan_options(${IN_LANGUAGE} ${IN_TARGET} "${COMPILETIME_IGNORELIST}")
   internal_target_sanitizer_default_options(${IN_LANGUAGE} ${IN_TARGET} "asan" "${RUNTIME_FLAGS}")
   string(LENGTH "${RUNTIME_SUPPRESSIONS}" RUNTIME_SUPPRESSIONS_LENGTH)
   if(RUNTIME_SUPPRESSIONS_LENGTH GREATER 0 AND CMAKE_${IN_LANGUAGE}_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
      message(WARNING "ASan runtime suppressions are not supported by MSVC")
   endif()
   internal_target_sanitizer_default_suppressions(${IN_LANGUAGE} ${IN_TARGET} "asan" "${RUNTIME_SUPPRESSIONS}")
endfunction()
