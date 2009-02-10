#!/bin/sh
setup_clutter(){
}

php_install(){
	echo "* Installing PHP5 ..."
	if [ -d "php" ]; then
		echo "   Old PHP install detected, removing."
		rm -rf php
	fi
	
	if [ $force_php == "false" ]; then
		if [ -e "raydium/php/libs/libphp5.a" ]; then
			echo "   PHP install detected. If you want to reinstall, add --force-php-install."
			return 0
		fi
	else
		rm -rf raydium/php
	fi
	
	# test bison
	echo "   Testing 'bison' ..."
	bison --version > /dev/null 2>&1
	exit_if_error "$?" "bison not found in path. Please install bison to compile PHP"
	
	# test lex
	echo "   Testing 'lex' ..."
	lex --version > /dev/null 2>&1
	exit_if_error "$?" "lex not found in path. Please install lex/flex to compile PHP"
	
	# test libcurl
	echo "   Testing 'libcurl' ..."
	curl-config --version > /dev/null 2>&1
	exit_if_error "$?" "curl-config not found in path. Please install 'libcurl-devel' to compile PHP"
	
	# test libxml2
	echo "   Testing 'libxml2' ..."
	xml2-config --version > /dev/null 2>&1
	exit_if_error "$?" "xml2-config not found in path. Please install 'libxml2-devel' to compile PHP"
	
	# download
	if [ ! -f raydium/php-latest.tar.gz ]; then
		echo "   Downloading latest PHP5 ..."
		wget -O raydium/php-latest.tar.gz http://snaps.php.net/php5.2-latest.tar.gz
		exit_if_error "$?" "wget not found, or network error"
	else
		echo "   Using previously downloaded file. Remove raydium/php-latest.tar.gz before launching configure, if needed"
	fi
	
	# uncompress
	echo "   Uncompressing ..."
	cd raydium
	tar xzf php-latest.tar.gz
	ret=$?
	cd - > /dev/null
	exit_if_error "$ret" "tar not found, or corrupted archive"
	
	# delete previous extraction dir, if any
	if [ -d raydium/php ]; then
		rm -rf raydium/php
	fi
	
	# rename
	php=`ls -dt raydium/php5*`
	echo "   Renaming $php to raydium/php/ ..."
	mv "$php" "raydium/php"
	exit_if_error "$?" "Is this script up to date ?"
	
	# configure
	echo "   Configuring PHP ..."
	echo "Configuring PHP" >> configure.log
	echo "===============" >> configure.log
	cd raydium/php
	./configure --enable-embed=static --with-zlib --enable-ftp --enable-static=zlib --with-curl \
	--disable-simplexml --disable-xmlreader --disable-xmlwriter --enable-soap \
	>>../../configure.log 2>>../../configure.log
	ret=$?
	cd - > /dev/null
	exit_if_error "$ret" "PHP configure failed (missing libs ?). See configure.log"
	
	# compile
	echo "   Building PHP..."
	echo "Building PHP" >> configure.log
	echo "============" >> configure.log
	cd raydium/php
	make >>../../configure.log 2>>../../configure.log
	ret=$?
	cd - > /dev/null
	exit_if_error "$ret" "PHP build failed, see configure.log"
	
	# deleting
	echo "   Deleting tar.gz ..."
	rm -f raydium/php-latest.tar.gz
}

