CFLAGS=-std=gnu99 -Wall -Wextra -Wformat=2 -Wswitch-default -Wswitch-enum -O3 -L/lib64 -L/usr/lib64 -L/usr/lib -L/lib -I/usr/include

requirements=glib libpcre gtk+-2.0 libxml-2.0 gstreamer-0.10 clutter-0.8 clutter-gst-0.8 pigment-0.3 libglade-2.0 sqlite3
#$(pkg-cflags)=pkg-config --cflags $(requirements)
pkg-cflags=-pthread -I/usr/include/glib-1.2 -I/usr/lib64/glib/include -I/usr/include/gtk-2.0 -I/usr/lib64/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/pango-1.0 -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/libpng12 -I/usr/include/libxml2 -I/usr/include/gstreamer-0.10 -I/usr/include/clutter-0.8 -I/usr/include/clutter-0.8/clutter-gst -I/usr/include/pigment-0.3 -I/usr/include/libglade-2.0

src=main.c \
	Alacast.c	Alacast.h	\


build-objects:
	gcc -o Alacast.o $(CFLAGS) $(pkg-cflags) Alacast.c

all:	build-objects

