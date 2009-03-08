prefix=@prefix@
data_dir=$(prefix)/share
cache="/var/alacast/cache"
log="/var/log/alacast"
wget_cmd="/usr/bin/wget --silent -O"
#php_src_dir="./src/.deps/php"
php_src_dir=@use_php_src@

SHELL=/bin/tcsh -f
PHP_INCLUDE_PATH=-I@php_src_dir@ -I@php_src_dir@/include -I@php_src_dir@/main -I@php_src_dir@/Zend -I@php_src_dir@/TSRM
INCLUDE_PATH=$(PHP_INCLUDE_PATH) -I/usr/include/clutter-0.8

check-clutter:
	if ( ! -d ./src/.deps/clutter ) mkdir -p ./src/.deps/clutter

get-clutter:
	$(wget_cmd) ./src/.deps/clutter/clutter.tar.bz2 \
 		http://clutter-project.org/sources/clutter/0.8/clutter-0.8.4.tar.bz2

get-clutter-gtk:
	$(wget_cmd) ./src/.deps/clutter/clutter-gtk.tar.bz2 \
		http://clutter-project.org/sources/clutter-gtk/0.8/clutter-gtk-0.8.2.tar.bz2

get-clutter-gst:
	$(wget_cmd) ./src/.deps/clutter/clutter-gst.tar.bz2 \
		http://clutter-project.org/sources/clutter-gst/0.8/clutter-gst-0.8.0.tar.bz2

get-clutter-all:
	get-clutter
	get-clutter-gtk
	get-clutter-gst

extract-clutter:
	tar -xjf ./src/.deps/clutter/*.tar.bz2


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
	if ( -d ./src/.deps/ ) rm -r ./src/.deps/
	rm src/*.o
	rm src/alacast

