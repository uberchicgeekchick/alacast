#!/bin/tcsh -f
set my_editor = "`printf "${0}" | sed 's/.*\/\([^\.]\+\).*/\1/g'`"
switch ( "${my_editor}" )
case "gedit":
	breaksw
case "vim":
default:
	set my_editor = "${my_editor} -p '+tabdo $-2'"
	breaksw
endsw

${my_editor} "./Logging.class.php" "./src/configure" "./src/Makefile.in" "./Apps/Alacast/Podcasts/OSS/TheLinuxLink.Net.opml" "./Apps/Alacast/Podcasts/Science/Science.opml" "./Apps/Alacast/Podcasts/Geeky/Wedonverse.opml" "./Apps/Alacast/Podcasts/Audio Dramas/Audio Drama Talk.opml" "./Apps/Alacast/Podcasts/Audio Dramas/Audio Dramas.opml" "./Apps/Alacast/Podcasts/Podnovels/Podcast Novels.opml" "./Apps/Alacast/Podcasts/Podnovels/Podiobooks.com.opml" "./gedit.session.tcsh" "./frequencylite.html"

