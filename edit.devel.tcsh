#!/bin/tcsh -f
set my_editor = "`printf "${0}" | sed 's/.*\/\([^\.]\+\).*/\1/g'`"

switch ( "${1}" )
case "opml":
	${my_editor} '+tabdo $-2' -p "./data/opml/Podcasts/OSS/TheLinuxLink.Net.opml" "./data/opml/Podcasts/Science/Science.opml" "./data/opml/Podcasts/Geeky/Wedonverse.opml" "./data/opml/Library/Audio Dramas/Audio Drama Talk.opml" "./data/opml/Library/Audio Dramas/Audio Dramas.opml" "./data/opml/Library/Podnovels/Podcast Novels.opml" "./data/opml/Library/Podnovels/Podiobooks.com.opml"
	breaksw
case "devel":
default:
	${my_editor} '+tabdo $-2' -p "./configure" "./Makefile" "./Makefile.in" "./src/Makefile" "./src/Makefile.in"
	breaksw
endsw

