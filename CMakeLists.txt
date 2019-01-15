cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

include(CMakePackageConfigHelpers)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED TRUE)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

set(CMAKE_BUILD_TYPE_INIT "Release")

if(NOT DEFINED PROJECT_NAME)
  set(SUBPROJECT TRUE)
endif()

project(tree-sitter-cmake)

if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/externals/tree-sitter")
  find_package(Git QUIET REQUIRED)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} submodule init
    COMMAND ${GIT_EXECUTABLE} submodule update
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    RESULT_VARIABLE ret
    OUTPUT_QUIET
    ERROR_QUIET
  )
  if(NOT ${ret} MATCHES 0)
    message(FATAL_ERROR "Error checking out git submodules")
  endif()
endif()

add_library(Tree-Sitter
  externals/tree-sitter/src/compiler/build_tables/lex_item.cc
  externals/tree-sitter/src/compiler/build_tables/lex_item_transitions.cc
  externals/tree-sitter/src/compiler/build_tables/lex_table_builder.cc
  externals/tree-sitter/src/compiler/build_tables/lookahead_set.cc
  externals/tree-sitter/src/compiler/build_tables/parse_item.cc
  externals/tree-sitter/src/compiler/build_tables/parse_item_set_builder.cc
  externals/tree-sitter/src/compiler/build_tables/parse_table_builder.cc
  externals/tree-sitter/src/compiler/build_tables/property_table_builder.cc
  externals/tree-sitter/src/compiler/build_tables/rule_can_be_blank.cc
  externals/tree-sitter/src/compiler/compile.cc
  externals/tree-sitter/src/compiler/generate_code/c_code.cc
  externals/tree-sitter/src/compiler/generate_code/property_table_json.cc
  externals/tree-sitter/src/compiler/lex_table.cc
  externals/tree-sitter/src/compiler/log.cc
  externals/tree-sitter/src/compiler/parse_json.cc
  externals/tree-sitter/src/compiler/parse_table.cc
  externals/tree-sitter/src/compiler/precedence_range.cc
  externals/tree-sitter/src/compiler/prepare_grammar/expand_repeats.cc
  externals/tree-sitter/src/compiler/prepare_grammar/expand_tokens.cc
  externals/tree-sitter/src/compiler/prepare_grammar/extract_choices.cc
  externals/tree-sitter/src/compiler/prepare_grammar/extract_simple_aliases.cc
  externals/tree-sitter/src/compiler/prepare_grammar/extract_tokens.cc
  externals/tree-sitter/src/compiler/prepare_grammar/flatten_grammar.cc
  externals/tree-sitter/src/compiler/prepare_grammar/intern_symbols.cc
  externals/tree-sitter/src/compiler/prepare_grammar/normalize_rules.cc
  externals/tree-sitter/src/compiler/prepare_grammar/parse_regex.cc
  externals/tree-sitter/src/compiler/prepare_grammar/prepare_grammar.cc
  externals/tree-sitter/src/compiler/prepare_grammar/token_description.cc
  externals/tree-sitter/src/compiler/rule.cc
  externals/tree-sitter/src/compiler/syntax_grammar.cc
  externals/tree-sitter/src/compiler/rules/character_set.cc
  externals/tree-sitter/src/compiler/rules/choice.cc
  externals/tree-sitter/src/compiler/rules/metadata.cc
  externals/tree-sitter/src/compiler/rules/repeat.cc
  externals/tree-sitter/src/compiler/rules/seq.cc
  externals/tree-sitter/src/compiler/util/string_helpers.cc
  externals/tree-sitter/src/runtime/get_changed_ranges.c
  externals/tree-sitter/src/runtime/language.c
  externals/tree-sitter/src/runtime/lexer.c
  externals/tree-sitter/src/runtime/node.c
  externals/tree-sitter/src/runtime/stack.c
  externals/tree-sitter/src/runtime/parser.c
  externals/tree-sitter/src/runtime/subtree.c
  externals/tree-sitter/src/runtime/tree.c
  externals/tree-sitter/src/runtime/tree_cursor.c
  externals/tree-sitter/src/runtime/utf16.c
  externals/utf8proc/utf8proc.c
  externals/json-parser/json.c
)

target_include_directories(Tree-Sitter
  PRIVATE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/externals/tree-sitter/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/externals/tree-sitter/src>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/externals/utf8proc>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/externals/json-parser>
  PUBLIC
    $<INSTALL_INTERFACE:include>
)

foreach(lang C CPP HTML JavaScript JSON Rust)
  string(TOLOWER "${lang}" lang_str)
  add_library(Tree-Sitter-${lang} externals/tree-sitter-${lang_str}/src/parser.c)
  target_link_libraries(Tree-Sitter-${lang} INTERFACE Tree-Sitter)
  target_include_directories(Tree-Sitter-${lang} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/externals/tree-sitter/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
  )
  add_dependencies(Tree-Sitter-${lang} Tree-Sitter)
endforeach()

# Make aliases the same as exported lib names. Useful when embedding.
add_library(Tree-Sitter::Tree-Sitter ALIAS Tree-Sitter)
foreach(lang C CPP HTML JavaScript JSON Rust)
  add_library(Tree-Sitter::Tree-Sitter-${lang} ALIAS Tree-Sitter-${lang})
endforeach()

if(NOT SUBPROJECT)
  # Only install when built as top-level project.
  if(WIN32)
    set(CMAKE_INSTALL_DIR "CMake")
  else()
    set(CMAKE_INSTALL_DIR "lib/cmake/Tree-Sitter")
  endif()

  install(FILES
    externals/tree-sitter/include/tree_sitter/compiler.h
    externals/tree-sitter/include/tree_sitter/parser.h
    externals/tree-sitter/include/tree_sitter/runtime.h
    include/tree_sitter/langs.h
    DESTINATION include/tree_sitter
  )
  
  install(TARGETS Tree-Sitter EXPORT Tree-Sitter DESTINATION lib)
  
  install(EXPORT Tree-Sitter
    DESTINATION ${CMAKE_INSTALL_DIR}
    NAMESPACE Tree-Sitter::
    FILE Tree-Sitter-targets.cmake
  )
  
  foreach(lang C CPP HTML JavaScript JSON Rust)
    install(TARGETS Tree-Sitter-${lang} EXPORT ${lang} DESTINATION lib)
    install(EXPORT ${lang}
      DESTINATION ${CMAKE_INSTALL_DIR}
      NAMESPACE Tree-Sitter::
      FILE Tree-Sitter-${lang}-targets.cmake
    )
  endforeach()
  
  install(FILES tree-sitter-config.cmake DESTINATION ${CMAKE_INSTALL_DIR})
endif()
