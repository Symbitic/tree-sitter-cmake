# TODO: Create VersionConfig file
# TODO: Generate using CMakePackageConfigHelpers to help detect required.

include(${CMAKE_CURRENT_LIST_DIR}/Tree-Sitter-targets.cmake OPTIONAL RESULT_VARIABLE ret)
if(NOT ret)
  set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
  set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Tree-Sitter-targets.cmake not found.")
  return()
elseif(NOT TARGET Tree-Sitter::Tree-Sitter)
  set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
  set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "Tree-Sitter::Tree-Sitter target not found.")
  return()
endif()

set(_NOTFOUND_MESSAGE)

foreach(lang ${Tree-Sitter_FIND_COMPONENTS})
  include(${CMAKE_CURRENT_LIST_DIR}/Tree-Sitter-${lang}-targets.cmake OPTIONAL RESULT_VARIABLE ret)
  if(NOT ret)
    set(_NOTFOUND_MESSAGE "${_NOTFOUND_MESSAGE}Failed to find Tree-Sitter component \"${lang}\"\n")
  elseif(NOT TARGET Tree-Sitter::Tree-Sitter-${lang})
    set(_NOTFOUND_MESSAGE "${_NOTFOUND_MESSAGE}Failed to find Tree-Sitter::Tree-Sitter-${lang} target\n")
  endif()
endforeach()

if(_NOTFOUND_MESSAGE)
  set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
  set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "${_NOTFOUND_MESSAGE}")
  return()
endif()
