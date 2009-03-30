CFLAGS=-Wall -Wextra -Wno-missing-field-initializers -Wmissing-prototypes -Wfatal-errors --combine -Wformat=2 -Wswitch-default -Wswitch-enum -O3

subdir=src

Alacast_BIN=Alacast
PREFIX=/programs/Alacast

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
	gtk+-2.0 >= 2.14.4 \
	gstreamer-0.10 >= 0.10.22 \
	pigment-0.3 >= 0.3.15 \
	clutter-0.8 >= 0.8.0 \
	clutter-gst-0.8 >= 0.8.0 \
	sqlite3 >= 3.6.11 \


Alacast_CFLAGS=`../cflags:convert:-I_to_-isystem.tcsh "$(PACKAGES)"`
Alacast_LIBS=`pkg-config --libs "$(PACKAGES)"`

C_STANDARD=gnu99

SOURCES=			\
	alacast.c		\
	program.c		\
	gui.c			\
	gtk.c			\
	clutter.c		\
	pigment.c		\
	main.c


Alacast_BIN:
	gcc $(CFLAGS) $(Alacast_CFLAGS) $(Alacast_LIBS) --std=$(C_STANDARD) -o $(Alacast_BIN) $(SOURCES)

all:	$(Alacast_BIN)

install:
	mv ./$(Alacast_BIN) $(PREFIX)/bin/$(Alacast_BIN)

distclean:
	-rm -f ./$(Alacast_BIN)

clean: distclean


