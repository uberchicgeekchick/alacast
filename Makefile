SHELL=/bin/tcsh -f
prefix=/programs/alacast
data_dir=$(prefix)/share
cache="/var/alacast/cache"
log="/var/log/alacast"
wget_cmd="/usr/bin/wget --silent -O"

PHP_INCLUDE_PATH="-I./src/deps/php/src -I./src/deps/php/src/include -I./src/deps/php/src/main -I./src/deps/php/src/Zend -I./src/deps/php/src/TSRM"
INCLUDE_PATH="$(PHP_INCLUDE_PATH) -I/usr/include/clutter-0.8"

check-clutter:
	if ( ! -d .deps/clutter ) mkdir -p .deps/clutter

get-clutter:
	$(wget_cmd) .deps/clutter/clutter.tar.bz2 \
 		http://clutter-project.org/sources/clutter/0.8/clutter-0.8.4.tar.bz2

get-clutter-gtk:
	$(wget_cmd) .deps/clutter/clutter-gtk.tar.bz2 \
		http://clutter-project.org/sources/clutter-gtk/0.8/clutter-gtk-0.8.2.tar.bz2

get-clutter-gst:
	$(wget_cmd) .deps/clutter/clutter-gst.tar.bz2 \
		http://clutter-project.org/sources/clutter-gst/0.8/clutter-gst-0.8.0.tar.bz2

get-clutter-all:
	get-clutter
	get-clutter-gtk
	get-clutter-gst

extract-clutter:
	tar -xjf .deps/clutter/*.tar.bz2


install-clutter:


install-clutter-gtk:
	

install-clutter-gst:
	

install-clutter-all:
	check-clutter
	get-clutter-all
	extract-clutter
	install-clutter


install:
	

uninstall:
	
clean:
	if ( -d .deps ) rm -r .deps
	rm src/*.o
	rm src/alacast

