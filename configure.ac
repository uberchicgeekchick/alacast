dnl configure.ac for Alacast
AC_INIT([alacast], [0.0.0a9], [http://uberChicGeekChick.Com/?projects=Alacast], [alacast])
AC_COPYRIGHT([Copyright (C) 2009 Kaity G. B.])

AC_CONFIG_HEADERS(config.h)
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([1.9 no-dist-gzip dist-bzip2])

AC_DEFAULT_PREFIX(/usr)

AM_MAINTAINER_MODE

dnl  --------------
dnl | dependencies |
dnl  --------------

PKG_CHECK_MODULES(Alacast,[
	libnotify
	libgtkhtml-2.0
	libsoup-2.4
	gobject-2.0
	libgnome-2.0
	gthread-2.0
	glib-2.0 >= 2.15.0
	libpcre >= 7.8
	libxml-2.0 >= 2.7.1
	gtk+-2.0 >= 2.14.4
	gstreamer-0.10 >= 0.10.22
	pigment-0.3 >= 0.3.15
	clutter-0.8 >= 0.8.0
	clutter-gst-0.8 >= 0.8.0
	sqlite3 >= 3.6.11
])

AC_SUBST(Alacast_CFLAGS)
AC_SUBST(Alacast_LIBS)

dnl ---------------------------------------------------------------------------
AC_OUTPUT([
Makefile
data/Makefile
src/Makefile
])

