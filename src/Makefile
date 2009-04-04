
subdir=src

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
	-DBUILDDIR="${top_builddir}"		\
	-DSRCDDIR="${top_srcddir}"		\
	-DPREFIX="${prefix}"			\
	-DEXEC_PREFIX="${exec_prefix}"		\
	-DLOCALEDIR="${localedir}"		\
	-DBINDIR="${bindir}"			\
	-DSBINDIR="${sbindir}"			\
	-DLIBEXECDIR="${libexecdir}"		\
	-DDATADIR="${datadir}"			\
	-DETCDIR="${sysconfdir}"		\
	-DSHAREDSTATEDIR="${sharedstatedir}"	\
	-DLOCALSTATEDIR="${localstatedir}"	\
	-DLIBDIR="${libdir}"			\
	-DINCLUDEDIR="${includedir}"		\
	-DOLDINCLUDEDIR="${oldincludedir}"	\
	-DINFODIR="${infodir}"			\
	-DMANDIR="${mandir}"

Alacast_BIN=Alacast

PACKAGES=	\
	libnotify \
	libgtkhtml-2.0 \
	libsoup-2.4 \
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

Alacast_CFLAGS=`../cflags:convert:-I_to_-isystem.tcsh "$(PACKAGES)"`
Alacast_LIBS=`pkg-config --libs "$(PACKAGES)"`

RELELATIVE_INCLUDE_DIRS=-I.. -I.

C_STANDARD=gnu99
CXX_STANDARD=gnu++0x

CFLAGS=-Wall -Wextra -Wno-missing-field-initializers -Wmissing-prototypes -Wfatal-errors --combine -Wformat=2 -Wswitch-default -Wswitch-enum -O3 -std=$(C_STANDARD) $(RELELATIVE_INCLUDE_DIRS) $(DEFINE_DIRS)

AM_CFLAGS =				\
		-I$(top_srcdir)		\
		-I${top_builddir}

SOURCES=				\
	debug.h				\
	alacast.c			\
	program.c			\
	gui.c				\
	gui/gtk.c			\
	gui/clutter.c			\
	gui/pigment.c			\
	main.c



Alacast_BIN:
	gcc $(CFLAGS) $(AM_CFLAGS) $(Alacast_CFLAGS) $(Alacast_LIBS) --std=$(C_STANDARD) -o $(Alacast_BIN) $(SOURCES)

all:	$(Alacast_BIN)

install:
	mv ./$(Alacast_BIN) $(PREFIX)/bin/$(Alacast_BIN)

distclean:
	-rm -f ./$(Alacast_BIN)

clean: distclean


