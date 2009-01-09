#!/bin/tcsh -f
set my_editor = "`printf "${0}" | sed 's/.*\/\([^\.]\+\).*/\1/g'`"

${my_editor} '+tabdo $-2' -p "./src/configure" "./src/Makefile.in" "./data/OPMLs/Podcasts/OSS/TheLinuxLink.Net.opml" "./data/OPMLs/Podcasts/Science/Science.opml" "./data/OPMLs/Podcasts/Geeky/Wedonverse.opml" "./data/OPMLs/Library/Audio Dramas/Audio Drama Talk.opml" "./data/OPMLs/Library/Audio Dramas/Audio Dramas.opml" "./data/OPMLs/Library/Podnovels/Podcast Novels.opml" "./data/OPMLs/Library/Podnovels/Podiobooks.com.opml"

