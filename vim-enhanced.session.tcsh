#!/bin/tcsh -f
set my_editor = "`printf "\""${0}"\"" | sed 's/.*\/\([^\.]\+\).*/\1/g'`"
switch ( "${my_editor}" )
case "gedit":
	breaksw
case "vi":
case "vim":
case "vim-enhanced":
default:
	set my_editor = `printf "%s -p" "vim-enhanced"`
	breaksw
endsw

${my_editor} "./src/Makefile" "./src/main.c" "./src/alacast.h" "./src/alacast.c" "./src/program.h" "./src/program.c" "./src/library.h" "./src/library.c" "./src/gui.h" "./src/gui.c"
