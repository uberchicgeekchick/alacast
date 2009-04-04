## Process this file with automake to produce Makefile.in

## Created by Anjuta

gladedir = $(datadir)/alacast/glade
glade_DATA = alacast.glade

AM_CPPFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	$(ALACAST_CFLAGS)

AM_CFLAGS =\
	 -Wall\
	 -g

bin_PROGRAMS = alacast

alacast_SOURCES = \
	callbacks.c \
	callbacks.h \
	main.c

alacast_LDFLAGS = \
	-Wl,--export-dynamic

alacast_LDADD = $(ALACAST_LIBS)

EXTRA_DIST = $(glade_DATA)

# Remove glade directory on uninstall
uninstall-local:
	-rm -r $(gladedir)
	-rm -r $(datadir)/alacast
