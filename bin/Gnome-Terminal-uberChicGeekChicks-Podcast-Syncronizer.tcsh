#!/bin/tcsh

set alacasts_path = `dirname "${0}"`
set alacasts_exec = "${alacasts_path}/uberChicGeekChicks-Podcast-Syncronizer.php"
set alacasts_options = "--update=detailed --logging --player=xine --interactive ${argv}"


set alacasts_resolution = "";
if ( -e "${alacasts_path}/resolution.rc" ) then
	set alacasts_resolution = `cat "${alacasts_path}/resolution.rc"`
else if ( -e "${HOME}/Settings/resolutions/alacast.rc" ) then
	set alacasts_resolution = `cat "${HOME}/Settings/resolutions/alacast.rc"`
else if ( -e "${HOME}/Settings/rc_files/resolutions/gnome-terminal/default.rc" ) then
	set alacasts_resolution = `cat "${HOME}/Settings/resolutions/gnome-terminal/default.rc"`
else
	set alacasts_resolution = "90x40"
endif

/usr/bin/gnome-terminal \
	--geometry="${alacasts_resolution}" \
	--hide-menubar \
	--title="uberChicGeekChick's Interactive Syncronizer" \
	--working-directory="${alacasts_path}" \
	--command="${alacasts_exec} ${alacasts_options} ${argv}" &
