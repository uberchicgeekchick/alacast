#!/bin/sh

#    Raydium - CQFD Corp.
#    http://raydium.org/
#    Released under both BSD license and Lesser GPL library license.
#    See "license.txt" file.

# This script will configure Raydium and download, configure and build
# dependencies if needed. See --help argument.

# build file
# $1 is the test name, will be put in the log
# $2 is file content
# $3 is gcc's options
# $4 is compiler (default: gcc)
test_build()
{
    if [ -z "$4" ]; then
	comp="gcc"
    else
	comp="$4"
    fi

    echo -ne "* Testing $1..."

    echo "" >> configure.log
    echo "   Testing $1 ($comp)"   >> configure.log
    echo "   ====================" >> configure.log
    echo "$2" > configure.c
    $comp -g configure.c -Wall -o configure.bin $3 >> configure.log 2>> configure.log
    
    if [ "$?" != "0" ]; then
	echo " build: failed"
	rm configure.c
	return 1
    fi
    
    ./configure.bin >> configure.log
    ret=$?
    
    if [ "$ret" = "0" ]; then
	echo "OK"
    fi
    
    if [ "$ret" != "0" ]; then
	echo " run: failed"
    fi
    rm configure.c configure.bin
    return $ret

}

exit_if_error()
{
    if [ $1 != 0 ]; then
	echo "   $2"
	exit 1
    else
	return 0
    fi
}

usage_print()
{
    echo "Quick configure script for Raydium 3D Game Engine"
    echo "  --help               this text"
    echo "  --force-ode-install  Force ODE local reinstall"
    echo "  --force-php-install  Force PHP 5 local reinstall"
#    echo "  --ode-cvs            Use ODE CVS version"
    echo "  --disable-x          Disable X/GL/GLU test (server)"
    exit 0
}

ode_install()
{
    echo "* Installing ODE..."
    if [ -d "ode" ]; then
	echo "   Old ode/ directory detected. removing it..."
	rm -rf ode
    fi

    if [ $force_ode == "false" ]; then
	if [ -e "raydium/ode/ode/src/libode.a" ]; then
	    echo "   ODE install detected. If you want to reinstall, add --force-ode-install."
	    return 0
	fi
    else
	rm -rf raydium/ode
    fi

# download
    if [ $ode_cvs = "true" ]; then
	# DEPRECATED !!! (removed from help)
	echo "   Downloading from CVS ..."
	cvs -d:pserver:anonymous:@cvs.sourceforge.net:/cvsroot/opende login
	exit_if_error "$?" "No CVS client installed, or network problem"
	cvs -z3 -d:pserver:anonymous@cvs.sourceforge.net:/cvsroot/opende co -r UNSTABLE -P raydium/ode
	exit_if_error "$?" "CVS server error ? Try manual install (http://ode.org)"
    else
	if [ ! -f "raydium/ode.tar.gz" ]; then
	    echo "   Downloading 'certified' version from Raydium website ..."
	    wget -O raydium/ode.tar.gz http://freeway.raydium.org/data/stable_mirrors/ode-0.7.tar.gz
	    exit_if_error "$?" "Error downloading."
	else
	    echo "   Using previously downloaded file. Remove raydium/ode.tar.gz before launching configure, if needed"
	fi
	
    # uncompress
	echo "   Uncompressing ..."
	cd raydium
	if [ -d "ode" ]; then
	    rm -rf ode
        fi
	tar xzf ode.tar.gz
	ret=$?
	cd - > /dev/null
	exit_if_error "$ret" "tar not found, or corrupted archive"
    fi

# configure
    echo "   Configuring ..."
    echo "Configuring ODE" >> configure.log
    echo "===============" >> configure.log
    cd raydium/ode
    ./configure 2>>../../configure.log >>../../configure.log
    ret=$?
    cd - > /dev/null
    exit_if_error "$?" "ODE configuration failed (see configure.log)"

# small patch
    sed -i 's/\(.*define.*HAVE_STDLIB_H.*\)/#ifndef HAVE_STDLIB_H\n\1\n#endif/' raydium/ode/include/ode/config.h

# build
    echo "   Building ..."
    echo "Building ODE" >> configure.log
    echo "============" >> configure.log
    cd raydium/ode
    make 2>>../../configure.log >>../../configure.log
    ret=$?
    cd - > /dev/null
    exit_if_error "$ret" "ODE Build failed (see configure.log)"

# deleting
    echo "   Deleting tarball"
    if [ -f "raydium/ode.tar.gz" ]; then
	rm -f raydium/ode.tar.gz
    fi
}

php_install()
{
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


####### Main

for i in "$@"; do
    if [ $i = "--help" ]; then
	usage_print
    fi
done

ode_cvs="false"
for i in "$@"; do
    if [ $i = "--ode-cvs" ]; then
	ode_cvs="true"
    fi
done

disable_x="no"
for i in "$@"; do
    if [ $i = "--disable-x" ]; then
	disable_x="yes"
    fi
done

force_ode="false"
for i in "$@"; do
    if [ $i = "--force-ode-install" ]; then
	force_ode="true"
    fi
done

force_php="false"
for i in "$@"; do
    if [ $i = "--force-php-install" ]; then
	force_php="true"
    fi
done

# empty log
rm configure.log 2>> /dev/null
echo "- See configure.log if needed."

# Test C compiler
file='int main(void) { return 0; }'
test_build "gcc" "$file" ""
exit_if_error "$?" "GNU C Compiler (GCC) is missing"

# Test OpenGL
file='
#include <GL/gl.h>
int main(void) { if(0) glVertex3f(0,0,0); return 0; }'
test_build "OpenGL" "$file" "-L/usr/X11R6/lib/ -lGL"
exit_if_error "$?" "You must install opengl-devel package"

# Test GLU
file='#include <GL/gl.h>
#include <GL/glu.h>
int main(void) { return 0; }'
test_build "GLU" "$file" "-L/usr/X11R6/lib/ -lGL -lGLU"
exit_if_error "$?" "You must install glu-devel package"

# Test Xinerama
file='#include <X11/Xlib.h>
#include <X11/extensions/Xinerama.h>
int main(void) { return 0; }'
test_build "Xinerama" "$file" "-L/usr/X11R6/lib/ -lXinerama"
exit_if_error "$?" "You must install libxinerama-devel package"

# Full GL/GLU test, looking for hardware accel
if [ $disable_x = "no" ]; then
    file='
// define a dummy Raydium background for myglut :
#define RAYDIUM_RENDERING_WINDOW                0
#define RAYDIUM_RENDERING_FULLSCREEN            1
#define RAYDIUM_RENDERING_NONE                  2
#define RAYDIUM_RENDERING_WINDOW_FIXED          10

#define DONT_INCLUDE_HEADERS
#define raydium_log printf
#define __rayapi
#define __global
signed char    raydium_key[256];
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "raydium/myglut.c"
int main(int argc, char **argv) { 
char *r;
glutInit(&argc,argv);
myglutCreateWindow(320,240,RAYDIUM_RENDERING_WINDOW,"GL test");

#ifdef USE_GLEW
glewInit();
#else
r=(char *)glGetString(GL_RENDERER);
if(!strcmp(r,"Mesa GLX Indirect"))
    {
    fprintf(stderr,"WARNING ! Indirect rendering detected !");
    fprintf(stdout,"WARNING ! Indirect rendering detected !");
    }
#endif
return 0; }
'
    test_build "GL/GLU hardware support" "$file" "-L/usr/X11R6/lib/ -lGL -lGLU"
    exit_if_error "$?" "Full GL test failed, see configure.log"
else
    echo " DISABLED";
fi

# GLEW ("The OpenGL Extension Wrangler Library")
# Using previous "file" (GL/GLU test)
test_build "GLEW" "$file" "-DUSE_GLEW -L/usr/X11R6/lib/ -lGL -lGLU -lGLEW"
exit_if_error "$?" "You must install libglew devel package"

# Test C++ compiler
file='int main(void) { return 0; }'
test_build "g++" "$file" "" "g++"
exit_if_error "$?" "GNU C++ Compiler (G++) is missing"

# Check ODE installation
ode_install

# Check PHP installation
php_install

# OpenAL
file="
#include <AL/al.h>
#include <AL/alc.h>
#include <AL/alut.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
int main(int argc, char **argv) {
ALCdevice *dev;
const ALbyte *initstr=(const ALbyte *) \"'( ( devices '( native null ) ) )\";
dev=alcOpenDevice(initstr);
sleep(1);
alcCloseDevice(dev);
return 0; }"
test_build "OpenAL" "$file" "-lopenal"
exit_if_error "$?" "openal-devel is required. Official CVS may be a good idea"

# OpenAL 1.1
file="
#include <AL/al.h>
#include <AL/alc.h>
#include <AL/alut.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
int main(int argc, char **argv) {
ALCdevice *dev;
const ALbyte *initstr=(const ALbyte *) \"'( ( devices '( native null ) ) )\";
dev=alcOpenDevice(initstr);
sleep(1);
#ifndef ALUT_API_MAJOR_VERSION
#error ALUT for OpenAL 1.1 is required
#endif
alcCloseDevice(dev);
return 0; }"
test_build "OpenAL 1.1 and ALUT" "$file" "-lopenal -lalut"
if [ $? != 0 ]; then
    echo "WARNING: Cannot find OpenAL 1.1 and ALUT. You can try to remove -lalut from Makefile and/or *comp*sh scripts, but Raydium with OpenAL 1.0 is not supported."
fi

# OGG/Vorbis
file='
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <vorbis/codec.h>
#include <vorbis/vorbisfile.h>
int main(void){
FILE *fp;
OggVorbis_File vf;
fp=fopen(".","r");
if(ov_open(fp, &vf, NULL, 0) < 0) { exit(0); }
// should never hit this !
ov_clear(&vf);    
return(0);
}'
# -logg seems useless ...
test_build "Ogg/Vorbis" "$file" "-lvorbis -lvorbisfile -logg"
exit_if_error "$?" "ogg and vorbis devels are required (libogg,libvorbis and libvorbisfile)"

# libjpeg
file='
#include <stdio.h>
#include <jpeglib.h>

int main(void)
{
struct jpeg_decompress_struct cinfo;
struct jpeg_error_mgr jerr;
//JSAMPARRAY buffer;

cinfo.err=jpeg_std_error(&jerr);
jpeg_create_decompress(&cinfo);
jpeg_destroy_decompress(&cinfo);

return 0;
}
'
test_build "libjpeg" "$file" "-ljpeg"
exit_if_error "$?" "libjpeg-devel not available."

##### End of tests

echo
echo "- Build system seems ready -"
echo "- Use \"make\" to build Raydium, and try: \"./odyncomp.sh test6.c\""
echo "- You can also use \"./ocomp.sh test6.c\" for a quick direct test"
