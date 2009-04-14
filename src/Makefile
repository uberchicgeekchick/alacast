
subdir=src
SUBDIRS=

top_builddir=/projects/gtk/alacast
top_srcddir=$(top_builddir)/src

prefix=/programs/Alacast
exec_prefix=/programs/Alacast
localedir=/usr/share/locale

bindir=${exec_prefix}/bin
sbindir=${exec_prefix}/sbin
libexecdir=${exec_prefix}/libexec
datadir=${prefix}/share
sysconfdir=${prefix}/etc
sharedstatedir=${prefix}/com
localstatedir=${prefix}/var
libdir=${exec_prefix}/lib
includedir=${prefix}/include
oldincludedir=/usr/include
infodir=${prefix}/info
mandir=${prefix}/man

DEFINE_DIRS=					\
	-DBUILDDIR="\""${top_builddir}"\""		\
	-DSRCDDIR="\""${top_srcddir}"\""		\
	-DPREFIX="\""${prefix}"\""			\
	-DEXEC_PREFIX="\""${exec_prefix}"\""		\
	-DLOCALEDIR="\""${localedir}"\""		\
	-DBINDIR="\""${bindir}"\""			\
	-DSBINDIR="\""${sbindir}"\""			\
	-DLIBEXECDIR="\""${libexecdir}"\""		\
	-DDATADIR="\""${datadir}"\""			\
	-DETCDIR="\""${sysconfdir}"\""		\
	-DSHAREDSTATEDIR="\""${sharedstatedir}"\""	\
	-DLOCALSTATEDIR="\""${localstatedir}"\""	\
	-DLIBDIR="\""${libdir}"\""			\
	-DINCLUDEDIR="\""${includedir}"\""		\
	-DOLDINCLUDEDIR="\""${oldincludedir}"\""	\
	-DINFODIR="\""${infodir}"\""			\
	-DMANDIR="\""${mandir}"\""

Alacast_BIN=alacast

PACKAGES=	\
	libnotify \
	libgtkhtml-2.0 \
	libsoup-2.4 >= 2.16.0.9 \
	gobject-2.0 \
	libgnome-2.0 \
	gthread-2.0 \
	glib-2.0 >= 2.15.0 \
	libpcre >= 7.8 \
	libxml-2.0 >= 2.7.1 \
	gtk+-2.0 >= 2.16.0 \
	gstreamer-0.10 >= 0.10.22 \
	pigment-0.3 >= 0.3.15 \
	clutter-0.8 >= 0.8.0 \
	clutter-gst-0.8 >= 0.8.0 \
	sqlite3 >= 3.6.11

PACKAGES_CFLAGS=`../cflags:convert:-I_to_-isystem.tcsh "$(PACKAGES)"`
PACKAGES_LIBS=`pkg-config --libs "$(PACKAGES)"`

RELELATIVE_INCLUDE_DIRS=-I.. -I.

C_STANDARD=gnu99
CXX_STANDARD=gnu++0x

Alacast_CFLAGS=-std=${C_STANDARD} -Wall -Wextra -Wno-missing-field-initializers -Wmissing-prototypes -Wfatal-errors --save-temps --combine -Wformat=2 -Wswitch-enum -O3 ${RELELATIVE_INCLUDE_DIRS} $(DEFINE_DIRS)

AM_CFLAGS=				\
		-I${top_srcdir}		\
		-I${top_builddir}

SOURCES=				\
	debug.c				\
	program.c			\
	library.c			\
	gui.c				\
	gui/pigment.c			\
	gui/clutter.c			\
	gui/gtk.c			\
	alacast.c			\
	main.c



alacast-all:
	gcc $(CFLAGS) $(Alacast_CFLAGS) $(AM_CFLAGS) $(PACKAGES_CFLAGS) $(PACKAGES_LIBS) --std=$(C_STANDARD) -o $(Alacast_BIN) $(SOURCES)

alacast-install:
	mv ./$(Alacast_BIN) $(PREFIX)/bin/$(Alacast_BIN)

alacast-uninstall:
	rm $(PREFIX)/bin/$(Alacast_BIN)

alacast-distclean:
	-rm -f ./$(Alacast_BIN)

alacast-clean: alacast-distclean

subdir=src
SUBDIRS=

all-recursive install-recursive uninstall-recursive distclean-recursive clean-recursive:
	@failcom='exit 1'; \
	for f in x $$MAKEFLAGS; do \
	case $$f in \
	*=* | --[!k]*);; \
	*k*) failcom='fail=yes';; \
	esac; \
	done; \
	target=`echo $@ | sed s/-recursive//`; \
	list='$(SUBDIRS)'; for subdir in $$list; do \
	echo "Making $$target in $$subdir"; \
	(cd $$subdir && $(MAKE) $(AM_MAKEFLAGS) $$target) \
	|| eval $$failcom; \
	done; \
	test -z "$$fail"

all: all-recursive alacast-all
install: install-recursive alacast-install
uninstall: uninstall-recursive alacast-uninstall
clean: clean-recursive alacast-clean
distclean: distclean-recursive alacast-distclean

