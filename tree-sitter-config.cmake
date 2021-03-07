set(_NOTFOUND_MESSAGE)
set(suffix "targets")

if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/CMakeCache.txt")
    set(suffix "depends")
else()

include("${CMAKE_CURRENT_LIST_DIR}/Tree-Sitter-${suffix}.cmake" OPTIONAL RESULT_VARIABLE ret)

if(NOT ret)
    set(_NOTFOUND_MESSAGE "Tree-Sitter-${suffix}.cmake not found.")
elseif(NOT TARGET Tree-Sitter::Tree-Sitter)
    set(_NOTFOUND_MESSAGE "Tree-Sitter::Tree-Sitter target not found.")
else()
  foreach(lang ${Tree-Sitter_FIND_COMPONENTS})
    include(${CMAKE_CURRENT_LIST_DIR}/Tree-Sitter-${lang}-${suffix}.cmake OPTIONAL RESULT_VARIABLE ret)
    if(NOT ret)
      set(_NOTFOUND_MESSAGE "${_NOTFOUND_MESSAGE}Failed to find Tree-Sitter component \"${lang}\"\n")
    elseif(NOT TARGET Tree-Sitter::Tree-Sitter-${lang})
      set(_NOTFOUND_MESSAGE "${_NOTFOUND_MESSAGE}Failed to find Tree-Sitter::Tree-Sitter-${lang} target\n")
    endif()
  endforeach()
endif()

if(_NOTFOUND_MESSAGE)
  set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
  set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "${_NOTFOUND_MESSAGE}")
  return()
endif()

# Mark the CMake package as FOUND.
set(${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)
