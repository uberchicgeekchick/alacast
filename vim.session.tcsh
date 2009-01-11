#!/bin/tcsh -f
set my_editor = "`printf "${0}" | sed 's/.*\/\([^\.]\+\).*/\1/g'`"
switch ( "${my_editor}" )
case "gedit":
	breaksw
case "vim":
default:
	set my_editor = `printf "%s -p %s" "vim" '+tabdo$-2'`
	breaksw
endsw

${my_editor} "./bin/scripts/OPML:Find-Unsubscribed.tcsh" "./data/opml/Podcasts/OSS/TheLinuxLink.Net.opml" "./data/opml/Podcasts/Science/Science.opml" "./data/opml/Library/Audio Dramas/Audio Drama Talk.opml" "./data/opml/Library/Audio Dramas/Audio Dramas.opml" "./data/opml/Library/Podnovels/Podcast Novels.opml" "./data/opml/Library/Podnovels/Podiobooks.com.opml"
