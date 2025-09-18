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
# Working languages (verified set)
# Keep this list in sync with tests/AllGrammarsTests.cs
LANGUAGES = \
    agda \
    bash \
    c \
    cpp \
    c-sharp \
    css \
    dart \
    embedded-template \
    go \
    haskell \
    html \
    java \
    javascript \
    jsdoc \
    json \
    julia \
    kotlin \
    lua \
    markdown \
    ocaml \
    php \
    python \
    ql \
    razor \
    ruby \
    rust \
    scala \
    sql \
    swift \
    toml \
    tsq \
    tsx \
    typescript \
    verilog \
    yaml
PROJECTS = tree-sitter $(patsubst %,tree-sitter-%,$(LANGUAGES))
LIBRARIES = $(patsubst %,$(BUILD_DIR)/lib%.$(LIB_EXT),$(PROJECTS))

# On macOS, allow unresolved symbols to be resolved at runtime by the core
# tree-sitter library. Many grammars rely on this behavior.
ifeq ($(UNAME_S),Darwin)
    EXTRA_LDFLAGS := -undefined dynamic_lookup
else
    EXTRA_LDFLAGS :=
endif

# Ensure common include paths are available in grammar builds
EXTRA_CFLAGS := -I../include -I../tree-sitter/src -I. -Isrc

all: $(BUILD_DIR) $(LIBRARIES)

$(BUILD_DIR):
	mkdir -p $@

# Tree-sitter core library
$(BUILD_DIR)/libtree-sitter.$(LIB_EXT):
	$(MAKE) -C tree-sitter CFLAGS="$(CFLAGS) $(EXTRA_CFLAGS)" LDFLAGS="$(LDFLAGS) $(EXTRA_LDFLAGS)"
	cp tree-sitter/libtree-sitter.$(LIB_EXT) $@

$(BUILD_DIR)/libtree-sitter-ocaml.$(LIB_EXT):
	$(MAKE) -C tree-sitter-ocaml CFLAGS="$(CFLAGS) $(EXTRA_CFLAGS)" LDFLAGS="$(LDFLAGS) $(EXTRA_LDFLAGS)"
	@if [ -f tree-sitter-ocaml/grammars/ocaml/libtree-sitter-ocaml.$(LIB_EXT) ]; then \
		cp tree-sitter-ocaml/grammars/ocaml/libtree-sitter-ocaml.$(LIB_EXT) $@; \
	else \
		cp tree-sitter-ocaml/libtree-sitter-ocaml.$(LIB_EXT) $@; \
	fi

$(BUILD_DIR)/libtree-sitter-php.$(LIB_EXT):
	$(MAKE) -C tree-sitter-php CFLAGS="$(CFLAGS) $(EXTRA_CFLAGS)" LDFLAGS="$(LDFLAGS) $(EXTRA_LDFLAGS)"
	@if [ -f tree-sitter-php/php/libtree-sitter-php.$(LIB_EXT) ]; then \
		cp tree-sitter-php/php/libtree-sitter-php.$(LIB_EXT) $@; \
	else \
		cp tree-sitter-php/libtree-sitter-php.$(LIB_EXT) $@; \
	fi

$(BUILD_DIR)/libtree-sitter-typescript.$(LIB_EXT):
	# Try building via grammar makefile; pass flags for macOS dynamic lookup
	# Some checkouts flatten generated sources; if subdirs exist, copy from there
	$(MAKE) -C tree-sitter-typescript CFLAGS="$(CFLAGS) $(EXTRA_CFLAGS)" LDFLAGS="$(LDFLAGS) $(EXTRA_LDFLAGS)"
	@if [ -f tree-sitter-typescript/typescript/libtree-sitter-typescript.$(LIB_EXT) ]; then \
		cp tree-sitter-typescript/typescript/libtree-sitter-typescript.$(LIB_EXT) $@; \
	elif [ -f tree-sitter-typescript/libtree-sitter-typescript.$(LIB_EXT) ]; then \
		cp tree-sitter-typescript/libtree-sitter-typescript.$(LIB_EXT) $@; \
	else \
		echo "Failed to locate built libtree-sitter-typescript.$(LIB_EXT)"; exit 1; \
	fi

$(BUILD_DIR)/libtree-sitter-tsx.$(LIB_EXT):
	$(MAKE) -C tree-sitter-tsx CFLAGS="$(CFLAGS) $(EXTRA_CFLAGS)" LDFLAGS="$(LDFLAGS) $(EXTRA_LDFLAGS)"
	cp tree-sitter-tsx/libtree-sitter-tsx.$(LIB_EXT) $@

# New language rules for our added grammars
$(BUILD_DIR)/libtree-sitter-dart.$(LIB_EXT):
	$(MAKE) -C tree-sitter-dart CFLAGS="$(CFLAGS) $(EXTRA_CFLAGS)" LDFLAGS="$(LDFLAGS) $(EXTRA_LDFLAGS)"
	cp tree-sitter-dart/libtree-sitter-dart.$(LIB_EXT) $@

$(BUILD_DIR)/libtree-sitter-kotlin.$(LIB_EXT):
	$(MAKE) -C tree-sitter-kotlin CFLAGS="$(CFLAGS) $(EXTRA_CFLAGS)" LDFLAGS="$(LDFLAGS) $(EXTRA_LDFLAGS)"
	cp tree-sitter-kotlin/libtree-sitter-kotlin.$(LIB_EXT) $@

$(BUILD_DIR)/libtree-sitter-lua.$(LIB_EXT):
	$(MAKE) -C tree-sitter-lua CFLAGS="$(CFLAGS) $(EXTRA_CFLAGS)" LDFLAGS="$(LDFLAGS) $(EXTRA_LDFLAGS)"
	cp tree-sitter-lua/libtree-sitter-lua.$(LIB_EXT) $@

$(BUILD_DIR)/libtree-sitter-sql.$(LIB_EXT):
	$(MAKE) -C tree-sitter-sql CFLAGS="$(CFLAGS) $(EXTRA_CFLAGS)" LDFLAGS="$(LDFLAGS) $(EXTRA_LDFLAGS)"
	cp tree-sitter-sql/libtree-sitter-sql.$(LIB_EXT) $@

$(BUILD_DIR)/libtree-sitter-swift.$(LIB_EXT):
	$(MAKE) -C tree-sitter-swift CFLAGS="$(CFLAGS) $(EXTRA_CFLAGS)" LDFLAGS="$(LDFLAGS) $(EXTRA_LDFLAGS)"
	cp tree-sitter-swift/libtree-sitter-swift.$(LIB_EXT) $@

$(BUILD_DIR)/libtree-sitter-yaml.$(LIB_EXT):
	$(MAKE) -C tree-sitter-yaml CFLAGS="$(CFLAGS) $(EXTRA_CFLAGS)" LDFLAGS="$(LDFLAGS) $(EXTRA_LDFLAGS)"
	cp tree-sitter-yaml/libtree-sitter-yaml.$(LIB_EXT) $@

# Generic rule for simple grammars
$(BUILD_DIR)/lib%.$(LIB_EXT):
	$(MAKE) -C $* CFLAGS="$(CFLAGS) $(EXTRA_CFLAGS)" LDFLAGS="$(LDFLAGS) $(EXTRA_LDFLAGS)"
	cp $*/lib$*.$(LIB_EXT) $@

.PHONY: all
