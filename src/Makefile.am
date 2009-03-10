# Sample Makefile for a anjuta plugin.

# Plugin UI file
alacast_uidir = $(anjuta_ui_dir)
alacast_ui_DATA =  alacast.ui


# Plugin Glade file
alacast_gladedir = $(anjuta_glade_dir)
alacast_glade_DATA =  alacast.glade

# Plugin Icon file
alacast_pixmapsdir = $(anjuta_image_dir)
alacast_pixmaps_DATA = alacast.png

# Plugin description file
plugin_in_files = alacast.plugin.in
%.plugin: %.plugin.in $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*po) ; $(INTLTOOL_MERGE) $(top_srcdir)/po $< $@ -d -u -c $(top_builddir)/po/.intltool-merge-cache

alacast_plugindir = $(anjuta_plugin_dir)
alacast_plugin_DATA = $(plugin_in_files:.plugin.in=.plugin)

# NOTE :
# The naming convention is very intentional
# We are forced to use the prefix 'lib' by automake and libtool
#    There is probably a way to avoid it but it is not worth to effort
#    to find out.
# The 'anjuta_' prfix is a safety measure to avoid conflicts where the
#    plugin 'libpython.so' needs to link with the real 'libpython.so'

# Include paths
AM_CPPFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DANJUTA_DATA_DIR=\"$(anjuta_data_dir)\" \
	-DANJUTA_PLUGIN_DIR=\"$(anjuta_plugin_dir)\" \
	-DANJUTA_IMAGE_DIR=\"$(anjuta_image_dir)\" \
	-DANJUTA_GLADE_DIR=\"$(anjuta_glade_dir)\" \
	-DANJUTA_UI_DIR=\"$(anjuta_ui_dir)\" \
	-DPACKAGE_DATA_DIR=\"$(datadir)\" \
	-DPACKAGE_SRC_DIR=\"$(srcdir)\" \
	$(LIBANJUTA_CFLAGS) $(ALACAST_CFLAGS)\
	-include config.h # so it gets included before glib-i18n.h

# Where to install the plugin
plugindir = $(anjuta_plugin_dir)

# The plugin
plugin_LTLIBRARIES = libalacast.la

# Plugin sources
libalacast_la_VALASOURCES = plugin.vala config.vapi
alacast_PACKAGES = --pkg libanjuta-1.0 --pkg libxml2 --pkg sqlite3 --pkg pigment  

BUILT_SOURCES = alacast.vala.stamp

libalacast_la_SOURCES = alacast.vala.stamp \
                               $(libalacast_la_VALASOURCES:.vala=.c) \
                               $(libalacast_la_VALASOURCES:.vala=.h)

alacast.vala.stamp : $(libalacast_la_VALASOURCES)
	$(VALAC) -C $(alacast_PACKAGES) $^
	touch $@

# Plugin dependencies
libalacast_la_LIBADD = \
	$(LIBANJUTA_LIBS) $(ALACAST_LIBS)

EXTRA_DIST = \
	$(plugin_in_files) \
	$(alacast_plugin_DATA) \
	$(alacast_ui_DATA) \
	$(alacast_glade_DATA) \
	$(alacast_pixmaps_DATA)
