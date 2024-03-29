##
# Variables included by all Makefiles.
##

## Directory definitions

libdir       = $(slateroot)/lib
srcdir       = $(slateroot)/src
mobiusdir    = $(srcdir)/mobius
pluginsdir   = $(srcdir)/plugins
testdir      = $(slateroot)/tests

prefix      = /usr/local
datadir     = $(prefix)/share/slate
slatesrcdir = $(datadir)/src
slate_dirs  := core lib syntax mobius
exec_prefix = $(prefix)/bin
execname    = slate
includedir  = $(prefix)/include
mandir      = $(prefix)/share/man
man1dir     = $(mandir)/man1
infodir     = $(prefix)/info
lispdir     = $(prefix)/share/emacs/site-lisp
vimdir      = $(prefix)/share/vim
DEVNULL     := /dev/null

## Build modes. Set on command line using QUIET=1, DEBUG=1 or PROFILE=1

ifndef QUIETNESS
  QUIETNESS := -q
endif

ifdef QUIET
  VERBOSE := 0
  SILENT := @
  SILENT_ERRORS := 2> $(DEVNULL)
  LIBTOOL_FLAGS += --silent
endif

ifdef DEBUG
  MODE := debug
  COPTFLAGS += -g
  CFLAGS += -DSLATE_BUILD_TYPE="\"Debug\""
else
  ifdef PROFILE
    MODE += profiled
    COPTFLAGS += -pg -g -O2 -fprofile-arcs -ftest-coverage
    CFLAGS += -DSLATE_BUILD_TYPE="\"Profile\""
  else
    MODE := optimized
    CFLAGS += -DSLATE_BUILD_TYPE="\"Optimized\""
    COPTFLAGS += -O2
  endif
endif

## All required executables

CC          := gcc
CPP         := g++
CP          := cp -f
LIBTOOL     ?= libtool
ECHO        := echo
WGET        := wget -q -c --cache=off
SECHO       := @$(ECHO)
INSTALL     := install
TAR         := tar
GZIP        := gzip
ETAGS       := etags
EMACS       := emacs

## Platform independent definitions

INCLUDES    += 
#CFLAGS      += -DSLATE_DATADIR=$(datadir) -D_POSIX_SOURCE=200112L -D_POSIX_C_SOURCE=200112L
CFLAGS      += -DSLATE_DATADIR=$(datadir) -D_XOPEN_SOURCE=600
CFLAGS      += $(COPTFLAGS) -Wall -Wno-unknown-pragmas -pthread $(PRINT_DEBUG) $(EXTRACFLAGS)  $(INCLUDES)
# include -pedantic later fixme

## Determine the host system's byte order.
## This creates a temporary test executable in the $(slateroot) directory
## since we can guarantee write permissions there on all platforms. 

BYTE_ORDER_FN := $(slateroot)/byteorder
BYTE_ORDER_SRC  := "int main(){union{long l;char c[sizeof(long)];}u;u.l=1;return(u.c[sizeof(long)-1]==1);}"
BYTE_ORDER  := $(shell echo $(BYTE_ORDER_SRC) > $(BYTE_ORDER_FN).c)
BYTE_ORDER  := $(shell $(CC) -o $(BYTE_ORDER_FN) $(BYTE_ORDER_FN).c)
BYTE_ORDER  := $(shell $(BYTE_ORDER_FN); echo $$?)
BYTE_ORDER_ := $(shell $(RM) $(BYTE_ORDER_FN).* $(BYTE_ORDER_FN) 1>&2)
ifeq ($(BYTE_ORDER),0)
  BYTE_ORDER := LITTLE_ENDIAN
  BYTE_ORDER_PREFIX := little
  LITTLE_ENDIAN_SLATE := True
else
  BYTE_ORDER := BIG_ENDIAN
  BYTE_ORDER_PREFIX := big
  LITTLE_ENDIAN_SLATE := False
endif

WORD_SIZE_FN := $(slateroot)/wordsize
WORD_SIZE_SRC  := "int main(){return sizeof(long)*8;}"
WORD_SIZE  := $(shell echo $(WORD_SIZE_SRC) > $(WORD_SIZE_FN).c)
WORD_SIZE  := $(shell $(CC) -o $(WORD_SIZE_FN) $(WORD_SIZE_FN).c)
WORD_SIZE  := $(shell $(WORD_SIZE_FN); echo $$?)
WORD_SIZE_ := $(shell $(RM) $(WORD_SIZE_FN).* $(WORD_SIZE_FN) 1>&2)

## Default variables

PLATFORM    := unix
CCVERSION   := $(shell $(CC) -dumpversion)
WORD_SIZE   := 32
LDFLAGS     := # -avoid-version
LIBS        := #-lm -ldl
#PLUGINS     := platform.so posix.so pipe.so
#PLUGINS     := x-windows.so
PLUGINS     := 
HOST_SYSTEM := $(shell uname -s)
LIB_SO_EXT  := .so
INSTALL_MODE := -m 644
CPU_TYPE    := `uname -m`
VM_LIBRARIES = -lm -ldl -lpthread

VMNAME      := vm
VMDIR       := $(srcdir)/vm
VM          := $(VMDIR)/$(VMNAME)
SOURCES     ?= $(VMDIR)/*.cpp
HEADERS     ?= $(VMDIR)/*.hpp
DEFAULT_IMAGE ?= slate.image
KERNEL_IMAGES := kernel.new.*.$(WORD_SIZE).*.image
DEFAULT_KERNEL_IMAGE ?= $(shell ls -t $(KERNEL_IMAGES) | head -1)
LATEST_SLATE_IMAGE_RELEASE_DATE = 2011-03-15
LATEST_SLATE_IMAGE_RELEASE_NAME ?= slate.$(BYTE_ORDER_PREFIX).$(WORD_SIZE).$(LATEST_SLATE_IMAGE_RELEASE_DATE).image
LATEST_SLATE_IMAGE_URL ?= http://slate-language.googlecode.com/files/$(LATEST_SLATE_IMAGE_RELEASE_NAME).bz2
BOOTSTRAP_DIR := $(slateroot)

CFLAGS_x-windows.c=`pkg-config --cflags x11` `pkg-config --cflags cairo` -Werror
LDFLAGS_x-windows.lo=`pkg-config --libs x11` `pkg-config --libs cairo`
CFLAGS_cocoa-windows.c=`pkg-config --cflags cocoa` `pkg-config --cflags cairo`
LDFLAGS_cocoa-windows.lo=`pkg-config --libs cocoa` `pkg-config --libs cairo`
CFLAGS_glib-wrapper.c=`pkg-config --cflags glib-2.0` 
LDFLAGS_glib-wrapper.lo=`pkg-config --libs glib-2.0` `pkg-config --libs gobject-2.0` 
CFLAGS_gdk-wrapper.c=`pkg-config --cflags gdk-2.0`
LDFLAGS_gdk-wrapper.lo=`pkg-config --libs gdk-2.0` `pkg-config --libs gthread-2.0`
CFLAGS_gtk-wrapper.c=`pkg-config --cflags gtk+-2.0`
LDFLAGS_gtk-wrapper.lo=`pkg-config --libs gtk+-2.0`
CFLAGS_llvm-wrapper.c=`llvm-config --cflags`
LDFLAGS_llvm-wrapper.lo=

#CFLAGS_socket.c=

PRINT_DEBUG_G=-DPRINT_DEBUG_DEFUN -DPRINT_DEBUG_GC_1 -DPRINT_DEBUG_OPCODES
PRINT_DEBUG_Y=-DPRINT_DEBUG_STACK_POINTER -DPRINT_DEBUG_STACK_PUSH -DPRINT_DEBUG_FOUND_ROLE -DPRINT_DEBUG_FUNCALL
PRINT_DEBUG_X=-DPRINT_DEBUG -DPRINT_DEBUG_OPCODES -DPRINT_DEBUG_INSTRUCTION_COUNT -DPRINT_DEBUG_CODE_POINTER -DPRINT_DEBUG_DISPATCH
PRINT_DEBUG_4=-DPRINT_DEBUG_DEFUN -DPRINT_DEBUG_GC -DPRINT_DEBUG_OPCODES -DPRINT_DEBUG_CODE_POINTER -DPRINT_DEBUG_ENSURE -DPRINT_DEBUG_STACK
PRINT_DEBUG_3=-DPRINT_DEBUG_DEFUN -DPRINT_DEBUG_GC -DPRINT_DEBUG_OPTIMIZER -DPRINT_DEBUG_PIC_HITS -DPRINT_DEBUG_UNOPTIMIZER
PRINT_DEBUG_2=-DPRINT_DEBUG_DEFUN -DPRINT_DEBUG -DPRINT_DEBUG_OPCODES -DPRINT_DEBUG_INSTRUCTION_COUNT -DPRINT_DEBUG_CODE_POINTER -DPRINT_DEBUG_DISPATCH -DPRINT_DEBUG_GC_MARKINGS
PRINT_DEBUG_1=-DPRINT_DEBUG_DEFUN -DPRINT_DEBUG_GC_1
PRINT_DEBUG_0=
PRINT_DEBUG=$(PRINT_DEBUG_0)

## Determine CPU type

## TODO: Sparc detection for SunOS?
## TODO: Base CPU type on real information, not just generic OS variant

## CPU-type specific overrides. Any of the variables above may be changed here.

ifdef ARCH
  CFLAGS += -m$(ARCH)
endif

ifdef VERSION
  CFLAGS += -DVERSION="\"$(VERSION)\""
endif

CFLAGS +=-DSLATE_DEFAULT_IMAGE=$(DEFAULT_IMAGE)

ifdef WORD_SIZE
  CFLAGS += -m$(WORD_SIZE)
  CFLAGS += -D_FILE_OFFSET_BITS=$(WORD_SIZE)
endif

#ifeq ($(CPU_TYPE), i686)
#  CFLAGS += -m$(WORD_SIZE)
#endif

#ifeq ($(CPU_TYPE), x86_64)
#  CFLAGS += -m$(WORD_SIZE)
#endif

## Platform specific overrides. Any of the variables above may be changed here.

ifeq ($(HOST_SYSTEM), AIX)
  LIB_SO_EXT  := .a
  PLUGINS     := platform.so posix.so pipe.so
endif

ifeq ($(HOST_SYSTEM), BeOS)
  PLATFORM  := beos
endif

ifeq ($(findstring CYGWIN,$(HOST_SYSTEM)), CYGWIN)
  PLATFORM   := windows
  LDFLAGS    += -no-undefined
  LIBS       := -lm
  LIB_SO_EXT := .dll
# DEVNULL    := NUL # Required if using cmd.exe and not bash.
endif

ifeq ($(HOST_SYSTEM), Darwin)
#  LIBTOOL := MACOSX_DEPLOYMENT_TARGET=10.3 glibtool
  LIBTOOL := glibtool
  PLUGINS := cocoa-windows.so
endif

ifeq ($(HOST_SYSTEM), DragonFly)
  LIBS      := -lm
endif

ifeq ($(HOST_SYSTEM), FreeBSD)
  LIBS      := -lm -lc_r
  LIBTOOL  := libtool13
endif

ifeq ($(HOST_SYSTEM), HP-UX)
  LIBS       := -lm -ldld
  LIB_SO_EXT := .sl
  PLUGINS    := platform.so posix.so pipe.so
endif

ifeq ($(HOST_SYSTEM), Linux)
  LIBS       := -lm -ldl
  PLUGINS    += gtk-wrapper.so gdk-wrapper.so glib-wrapper.so llvm-wrapper.so x-windows.so
endif

ifeq ($(findstring MINGW,$(HOST_SYSTEM)), MINGW)
  PLATFORM  := windows
  LIBS      := -lm
endif

ifeq ($(HOST_SYSTEM), NetBSD)
  LIBS      := -lm
endif

ifeq ($(HOST_SYSTEM), SunOS)
  PLUGINS   := platform.so posix.so pipe.so
  # Work around GCC Ultra SPARC alignment bug
  # TODO: Should be CPU specific.
  COPTFLAGS := $(subst -O2,-O0, $(COPTFLAGS))
endif

PLUGINS := $(subst .so,$(LIB_SO_EXT), $(PLUGINS))

