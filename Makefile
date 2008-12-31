shell=tcsh
cache="/var/alacast/cache"
log="/var/log/alacast"

PHP_INCLUDE_PATH="-I./src/deps/php/src -I./src/deps/php/src/include -I./src/deps/php/src/main -I./src/deps/php/src/Zend -I./src/deps/php/src/TSRM"
INCLUDE_PATH="$(PHP_INCLUDE_PATH) -I/usr/include/clutter-0.8"

install:

uninstall:

