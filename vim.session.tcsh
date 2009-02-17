#!/bin/tcsh -f
set my_editor = "`printf "${0}" | sed 's/.*\/\([^\.]\+\).*/\1/g'`"
switch ( "${my_editor}" )
case "gedit":
	breaksw
case "vim":
default:
	set my_editor = `printf "%s -p" "vim-enhance"`
	breaksw
endsw

${my_editor} "./data/xml/opml/Radiocasts/NPR/index.opml" "./data/xml/opml/Radiocasts/NPR/create_opmls.tcsh"
