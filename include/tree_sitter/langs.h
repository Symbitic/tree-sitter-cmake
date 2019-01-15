#ifndef TREE_SITTER_LANGS_H_
#define TREE_SITTER_LANGS_H_

#include "tree_sitter/runtime.h"

#ifdef __cplusplus
extern "C" {
#endif

const TSLanguage *tree_sitter_c();
const TSLanguage *tree_sitter_cpp();
const TSLanguage *tree_sitter_html();
const TSLanguage *tree_sitter_javascript();
const TSLanguage *tree_sitter_json();
const TSLanguage *tree_sitter_rust();

#ifdef __cplusplus
}
#endif

#endif
