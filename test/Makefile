# Detailed destination directories
BINLIBDEST=	$(LIBDIR)/python$(VERSION)
LIBDEST=	$(SCRIPTDIR)/python$(VERSION)
MACOSX_DEPLOYMENT_TARGET=14.0
export MACOSX_DEPLOYMENT_TARGET

# Provide quick help for common Makefile targets.
.PHONY: help
help:
	@echo "Run 'make' to build the Python executable and extension modules"
	@echo ""

# Compile with profile generation enabled.
profile-gen-stamp: profile-clean-stamp
	@if [ $(LLVM_PROF_ERR) = yes ]; then \
		echo "Error: Cannot perform PGO build because llvm-profdata was not found in PATH" ;\
		echo "Please add it to PATH and run ./configure again" ;\
		exit 1;\
	fi

Modules/_hacl/Hacl_Hash_SHA2.o: $(srcdir)/Modules/_hacl/Hacl_Hash_SHA2.c $(LIBHACL_SHA2_HEADERS)
	$(CC) -c $(LIBHACL_CFLAGS) -o $@ $(srcdir)/Modules/_hacl/Hacl_Hash_SHA2.c

$(LIBHACL_SHA2_A): $(LIBHACL_SHA2_OBJS)
	-rm -f $@
	$(AR) $(ARFLAGS) $@ $(LIBHACL_SHA2_OBJS)

Makefile Modules/config.c: Makefile.pre \
				$(srcdir)/Modules/config.c.in \
				$(MAKESETUP) \
				$(srcdir)/Modules/Setup \
				Modules/Setup.local \
				Modules/Setup.bootstrap \
				Modules/Setup.stdlib
	$(MAKESETUP) -c $(srcdir)/Modules/config.c.in \
				-s Modules \
				Modules/Setup.local \
				Modules/Setup.stdlib \
				Modules/Setup.bootstrap \
				$(srcdir)/Modules/Setup
	@mv config.c Modules
	@echo "The $$(Makefile) was updated, you may need to re-run make."

# ---------------------------------------------------------------------------
# Additional syntax coverage below this point.
# ---------------------------------------------------------------------------

.DEFAULT_GOAL := help
.SUFFIXES:
.SUFFIXES: .c .o
.ONESHELL:
.SILENT: clean
VPATH = $(srcdir)/Modules:$(srcdir)/Objects

CC ?= cc
AR := ar
CFLAGS = -O2 -Wall
CFLAGS += -fPIC
GIT_REV != git rev-parse --short HEAD 2>/dev/null || echo unknown
override LDFLAGS += -L$(LIBDIR)
export CC CFLAGS
unexport VERBOSE

SRCS := $(wildcard Modules/*.c) $(wildcard Objects/*.c)
OBJS := $(patsubst %.c,%.o,$(SRCS))
DEPS := $(OBJS:.o=.d)
PYMODS := $(addprefix Lib/,$(addsuffix .py,os sys re))
TESTS := $(filter %_test.c,$(SRCS))
NONTESTS := $(filter-out %_test.c,$(SRCS))
UNAME := $(shell uname -s)
BUILD_DIR = build/$(strip $(UNAME))
MODNAME = $(subst /,_,$(basename $(notdir $(1))))
TARGET_NAME = $(if $(findstring Darwin,$(UNAME)),python.app,python)

include Makefile.pre
-include $(DEPS)
sinclude config.local.mk

ifeq ($(UNAME),Darwin)
  SHLIB_EXT := .dylib
else ifeq ($(UNAME),Linux)
  SHLIB_EXT := .so
else
  SHLIB_EXT := .dll
endif

ifneq (,$(filter 1 yes,$(VERBOSE)))
  Q :=
else
  Q := @
endif

ifdef LLVM_PROF_ERR
  $(warning llvm-profdata not found; PGO disabled)
endif

ifndef PREFIX
  PREFIX := /usr/local
endif

define compile-template
$(1): $(2) | $(BUILD_DIR)
	$(Q)$(CC) $(CFLAGS) -MMD -c $$< -o $$@
endef

define banner =
	@echo "=== $(1) ($(GIT_REV)) ==="
endef

$(foreach src,$(NONTESTS),$(eval $(call compile-template,$(src:.c=.o),$(src))))

%.o: %.c | $(BUILD_DIR)
	$(call banner,compiling $<)
	$(Q)$(CC) $(CFLAGS) -c $< -o $@

$(OBJS): CFLAGS += -DMODNAME=\"$(call MODNAME,$@)\"
debug: CFLAGS := -O0 -g3
debug: export PYTHONDEBUG = 1

$(TESTS:.c=): %: %.o $(LIBHACL_SHA2_A)
	$(Q)$(CC) $(LDFLAGS) $^ -o $@

Modules/_io/%.o Modules/_sqlite/%.o: $(srcdir)/Modules/%.c
	$(CC) -c $(CFLAGS) $< -o $@

$(BUILD_DIR):
	mkdir -p $@

.PHONY: all clean debug check list-mods
all: $(BUILD_DIR) $(OBJS) ; @echo "built $(words $(OBJS)) objects for $(TARGET_NAME)$(SHLIB_EXT)"

check: $(TESTS:.c=)
	for t in $^; do \
		./$$t || exit 1; \
	done
	@test -n "$?" && echo "newer prerequisites: $?"

list-mods:
	@for m in $(PYMODS); do printf '%s -> %s\n' "$$m" "$$(basename $$m .py)"; done
	@echo 'stem of pattern target is $*, first prerequisite is $<'

clean:
	-rm -rf $(BUILD_DIR) $(OBJS) $(DEPS)
	-$(RM) *~ \
		core.*
