# Detect OS and set appropriate RID and library extension
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

ifeq ($(UNAME_S),Darwin)
    ifeq ($(UNAME_M),arm64)
        RID ?= osx-arm64
    else
        RID ?= osx-x64
    endif
    LIB_EXT = dylib
else
    ifeq ($(UNAME_M),aarch64)
        RID ?= linux-arm64
    else
        RID ?= linux-x64
    endif
    LIB_EXT = so
endif

BUILD_DIR = ../build/runtimes/$(RID)/native
# All supported languages (21 total - excluding ocaml due to build issues)
LANGUAGES = agda bash c cpp c-sharp css embedded-template go haskell html java javascript jsdoc json julia php python ql ruby rust scala swift typescript verilog
PROJECTS = tree-sitter $(patsubst %,tree-sitter-%,$(LANGUAGES))
LIBRARIES = $(patsubst %,$(BUILD_DIR)/lib%.$(LIB_EXT),$(PROJECTS))

all: $(BUILD_DIR) $(LIBRARIES)

$(BUILD_DIR):
	mkdir -p $@

# Tree-sitter core library
$(BUILD_DIR)/libtree-sitter.$(LIB_EXT):
	make -C tree-sitter
	cp tree-sitter/libtree-sitter.$(LIB_EXT) $@

$(BUILD_DIR)/libtree-sitter-ocaml.$(LIB_EXT):
	make -C tree-sitter-ocaml
	cp tree-sitter-ocaml/grammars/ocaml/libtree-sitter-ocaml.$(LIB_EXT) $@

$(BUILD_DIR)/libtree-sitter-php.$(LIB_EXT):
	make -C tree-sitter-php
	cp tree-sitter-php/php/libtree-sitter-php.$(LIB_EXT) $@

$(BUILD_DIR)/libtree-sitter-typescript.$(LIB_EXT):
	make -C tree-sitter-typescript
	cp tree-sitter-typescript/typescript/libtree-sitter-typescript.$(LIB_EXT) $@

$(BUILD_DIR)/libtree-sitter-tsx.$(LIB_EXT):
	make -C tree-sitter-typescript
	cp tree-sitter-typescript/tsx/libtree-sitter-tsx.$(LIB_EXT) $@

# New language rules for our added grammars
$(BUILD_DIR)/libtree-sitter-dart.$(LIB_EXT):
	make -C tree-sitter-dart
	cp tree-sitter-dart/libtree-sitter-dart.$(LIB_EXT) $@

$(BUILD_DIR)/libtree-sitter-kotlin.$(LIB_EXT):
	make -C tree-sitter-kotlin
	cp tree-sitter-kotlin/libtree-sitter-kotlin.$(LIB_EXT) $@

$(BUILD_DIR)/libtree-sitter-lua.$(LIB_EXT):
	make -C tree-sitter-lua
	cp tree-sitter-lua/libtree-sitter-lua.$(LIB_EXT) $@

$(BUILD_DIR)/libtree-sitter-sql.$(LIB_EXT):
	make -C tree-sitter-sql
	cp tree-sitter-sql/libtree-sitter-sql.$(LIB_EXT) $@

$(BUILD_DIR)/libtree-sitter-swift.$(LIB_EXT):
	make -C tree-sitter-swift
	cp tree-sitter-swift/libtree-sitter-swift.$(LIB_EXT) $@

$(BUILD_DIR)/libtree-sitter-yaml.$(LIB_EXT):
	make -C tree-sitter-yaml
	cp tree-sitter-yaml/libtree-sitter-yaml.$(LIB_EXT) $@

# Generic rule for simple grammars
$(BUILD_DIR)/lib%.$(LIB_EXT):
	make -C $*
	cp $*/lib$*.$(LIB_EXT) $@

.PHONY: all
