dnl  --------------------------
dnl | configure.ac for Alacast |
dnl  --------------------------

AC_INIT(alacast-php, "#060D0a99", http://uberChicGeekChick.Com/?projects=Alacast-php, alacast-php)
AC_COPYRIGHT([Copyright (C) 2009 Kaity G. B.])
AC_DEFAULT_PREFIX(/usr)

AM_INIT_AUTOMAKE(AC_PACKAGE_NAME, AC_PACKAGE_VERSION)
AC_CONFIG_HEADERS([config.h])
AM_MAINTAINER_MODE

AC_ISC_POSIX
AC_PROG_CC
AM_PROG_CC_STDC
AC_HEADER_STDC

dnl  ---------------------
dnl | Internatinalization |
dnl  ---------------------
GETTEXT_PACKAGE=alacast-php
AC_SUBST(GETTEXT_PACKAGE)
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE,"$GETTEXT_PACKAGE", [GETTEXT package name])
AM_GLIB_GNU_GETTEXT
IT_PROG_INTLTOOL([0.35.0])

AM_PROG_LIBTOOL


dnl  --------------
dnl | Dependencies |
dnl  --------------

PKG_CHECK_MODULES(Alacast,[
	libnotify
	libgtkhtml-2.0
	libsoup-2.4
	gobject-2.0
	libgnome-2.0
	gthread-2.0
	glib-2.0 >= 2.20.0
	libpcre >= 7.8
	libxml-2.0 >= 2.7.1
	gtk+-2.0 >= 2.16.0
	libglade-2.0 >= 2.6
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

