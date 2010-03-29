#!/bin/tcsh -f
if( -e "/projects/gtk/alacast/data/profiles/${USER}/opml/gPodder:channels.opml:symlink" )	\
	/bin/cp -vfp "/projects/gtk/alacast/data/profiles/${USER}/opml/gPodder:channels.opml:symlink" "/projects/gtk/alacast/data/profiles/${USER}/opml/back-ups/`date '+%Y-%m-%d'`.opml"
