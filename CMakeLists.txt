cmake_minimum_required(VERSION 3.18 FATAL_ERROR)

include(CMakePackageConfigHelpers)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED TRUE)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

set(CMAKE_BUILD_TYPE_INIT "Release")

if(DEFINED PROJECT_NAME)
  set(SUBPROJECT TRUE)
else()
  set(SUBPROJECT FALSE)
endif()

project(tree-sitter-cmake)

function(CHECKOUT proj tag)
  if (NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/${proj}")
    message(STATUS "Cloning ${proj} ${tag}")
    execute_process(
      COMMAND git clone -b ${tag} https://github.com/tree-sitter/${proj}
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      RESULT_VARIABLE ret
      OUTPUT_QUIET
      ERROR_QUIET
    )
    if (NOT ret EQUAL 0)
      message(ERROR "Error cloning ${proj}")
    endif()
  endif()
endfunction()

function(add_language lang)
  string(TOLOWER "${lang}" lang_str)
  if (NOT ARGN)
    set(src_dir "tree-sitter-${lang_str}")
  else()
    set(src_dir "${ARGN}")
  endif()
  add_library(Tree-Sitter-${lang} STATIC "${CMAKE_CURRENT_BINARY_DIR}/${src_dir}/src/parser.c")
  # Make aliases the same as exported lib names. Useful when embedding.
  add_library(Tree-Sitter::Tree-Sitter-${lang} ALIAS Tree-Sitter-${lang})
  target_include_directories(Tree-Sitter-${lang}
    PRIVATE
      $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/${src_dir}/src>
    PUBLIC
      $<INSTALL_INTERFACE:include>
  )
endfunction()

checkout(tree-sitter v0.20.1)
checkout(tree-sitter-c v0.20.1)
checkout(tree-sitter-c-sharp v0.19.1)
checkout(tree-sitter-cpp v0.20.0)
checkout(tree-sitter-go rust-0.19.1)
checkout(tree-sitter-java v0.19.1)
checkout(tree-sitter-javascript rust-0.20.0)
checkout(tree-sitter-python rust-0.19.1)
checkout(tree-sitter-rust v0.20.0)
checkout(tree-sitter-typescript rust-0.20.0)

add_language(C)
add_language(C-Sharp)
add_language(CPP)
add_language(Go)
add_language(Java)
add_language(JavaScript)
add_language(Python)
add_language(Rust)
add_language(TypeScript tree-sitter-typescript/typescript)
add_language(TSX tree-sitter-typescript/tsx)

add_library(Tree-Sitter "${CMAKE_CURRENT_BINARY_DIR}/tree-sitter/lib/src/lib.c")

target_include_directories(Tree-Sitter
  PRIVATE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/tree-sitter/lib/src>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/tree-sitter/lib/include>
  PUBLIC
    $<INSTALL_INTERFACE:include>
)

add_library(Tree-Sitter::Tree-Sitter ALIAS Tree-Sitter)

message("SUBPROJECT=${SUBPROJECT}")

if(NOT SUBPROJECT)
  # Only install when built as top-level project.
  if(WIN32)
    set(CMAKE_INSTALL_DIR "CMake")
  else()
    set(CMAKE_INSTALL_DIR "lib/cmake/Tree-Sitter")
  endif()

  install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/tree-sitter/lib/include/tree_sitter/api.h
    ${CMAKE_CURRENT_BINARY_DIR}/tree-sitter/lib/include/tree_sitter/parser.h
    include/tree_sitter/langs.h
    DESTINATION include/tree_sitter
  )

  install(TARGETS Tree-Sitter EXPORT Tree-Sitter DESTINATION lib)
  
  install(EXPORT Tree-Sitter
    DESTINATION ${CMAKE_INSTALL_DIR}
    NAMESPACE Tree-Sitter::
    FILE Tree-Sitter-targets.cmake
  )

  foreach(lang C C-Sharp CPP Go Java JavaScript Python Rust TypeScript TSX)
    install(TARGETS Tree-Sitter-${lang} EXPORT ${lang} DESTINATION lib)
    install(EXPORT ${lang}
      DESTINATION ${CMAKE_INSTALL_DIR}
      NAMESPACE Tree-Sitter::
      FILE Tree-Sitter-${lang}-targets.cmake
    )
  endforeach()

  install(FILES tree-sitter-config.cmake DESTINATION ${CMAKE_INSTALL_DIR})
endif()
