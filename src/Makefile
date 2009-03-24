CFLAGS=-Wall -Wextra -Wno-missing-field-initializers -Wmissing-prototypes -Wfatal-errors --combine -Wformat=2 -Wswitch-default -Wswitch-enum -O3

subdir=src

Alacast_BIN=Alacast
PREFIX=/programs/Alacast

PACKAGES=glib-2.0 >= 2.15.0 \
	libpcre >= 7.8 \
	gtk+-2.0 >= 2.14.4 \
	libxml-2.0 >= 2.7.1 \
	gstreamer-0.10 >= 0.10.22 \
	clutter-0.8 >= 0.8.0 \
	clutter-gst-0.8 >= 0.8.0 \
	pigment-0.3 >= 0.3.15 \
	libglade-2.0 >= 0.23 \
	sqlite3 >= 3.6.11 \


INCLUDES=`./cflags:convert:-I_to_-isystem.tcsh "$(PACKAGES)"`
LIBS=`pkg-config --libs "$(PACKAGES)"`

SOURCES=		\
	GUI.c		\
	Alacast.c	\
	main.c



Alacast_BIN:
	gcc $(CFLAGS) $(INCLUDES) $(LIBS) -o $(Alacast_BIN) $(SOURCES)

all:	$(Alacast_BIN)

install:
	mv ./$(Alacast_BIN) $(PREFIX)/bin/$(Alacast_BIN)

distclean:
	-rm -f ./$(Alacast_BIN)

clean: distclean


