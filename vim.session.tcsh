#!/bin/tcsh -f
set my_editor = "`printf "${0}" | sed 's/.*\/\([^\.]\+\).*/\1/g'`"
switch ( "${my_editor}" )
case "gedit":
	breaksw
case "vim":
default:
	set my_editor = 'vim -p "+tabdo $-2"'
	breaksw
endsw

${my_editor} "./src/configure" "./src/Makefile.in" "./OPMLs/Podcasts/OSS/TheLinuxLink.Net.opml" "./OPMLs/Podcasts/Science/Science.opml" "./OPMLs/Podcasts/Geeky/Wedonverse.opml" "./OPMLs/Podcasts/Audio Dramas/Audio Drama Talk.opml" "./OPMLs/Podcasts/Audio Dramas/Audio Dramas.opml" "./OPMLs/Podcasts/Podnovels/Podcast Novels.opml" "./OPMLs/Podcasts/Podnovels/Podiobooks.com.opml" "./gedit.session.tcsh" "./frequencylite.html"

