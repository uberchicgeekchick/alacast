#!/bin/tcsh -f
set my_editor = "`printf "${0}" | sed 's/.*\/\([^\.]\+\).*/\1/g'`"
switch ( "${my_editor}" )
case "gedit":
	breaksw
case "vim":
default:
	set args = '-p '\''+tabdo $-2'\'
	breaksw
endsw

`${my_editor} ${args} "./src/configure" "./src/Makefile.in" "./OPMLs/Podcasts/OSS/TheLinuxLink.Net.opml" "./OPMLs/Podcasts/Science/Science.opml" "./OPMLs/Podcasts/Geeky/Wedonverse.opml" "./OPMLs/Library/Audio Dramas/Audio Drama Talk.opml" "./OPMLs/Library/Audio Dramas/Audio Dramas.opml" "./OPMLs/Library/Podnovels/Podcast Novels.opml" "./OPMLs/Library/Podnovels/Podiobooks.com.opml"`
#${my_editor} -p '+tabdo $-2' "./src/configure" "./src/Makefile.in" "./OPMLs/Podcasts/OSS/TheLinuxLink.Net.opml" "./OPMLs/Podcasts/Science/Science.opml" "./OPMLs/Podcasts/Geeky/Wedonverse.opml" "./OPMLs/Library/Audio Dramas/Audio Drama Talk.opml" "./OPMLs/Library/Audio Dramas/Audio Dramas.opml" "./OPMLs/Library/Podnovels/Podcast Novels.opml" "./OPMLs/Library/Podnovels/Podiobooks.com.opml"

