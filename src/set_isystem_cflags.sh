#!/bin/sh -f
PACKAGES="
	glib-2.0		>=	2.15.0
	libpcre			>=	7.8
	gtk+-2.0		>=	2.14.4
	libxml-2.0		>=	2.7.1
	gstreamer-0.10		>=	0.10.22
	clutter-0.8		>=	0.8.0
	clutter-gst-0.8		>=	0.8.0
	pigment-0.3		>=	0.3.15
	libglade-2.0		>=	0.23
	sqlite3			>=	3.6.11
";

packages_dirs=`pkg-config --cflags "${PACKAGES}" | sed 's/^\(.\)/\ \1/g' | sed 's/\ \-[^I][^\ ]\+//g' | sed 's/\ \-I\(\/[^\ ]\+\)/\ \1/g'`
isystem="";
for package in ${packages_dirs} 
do
	isystem="${isystem} -isystem ${package}";
	for include_dir in `find ${package} -type d`
	do
		isystem="${isystem} -isystem ${include_dir}";
	done
done

if eval `test "$isystem" == ""`; then
	export ISYSTEM="${isystem}";
	unset isystem
	echo "${ISYSTEM}"
fi

if [ `test "${include_dir}" != ""` ]; then unset $include_dir; fi
unset packages
unset packages_dirs
unset package

