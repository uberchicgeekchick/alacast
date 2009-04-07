#!/bin/tcsh -f
set my_editor = "`printf "\""${0}"\"" | sed 's/.*\/\([^\.]\+\).*/\1/g'`"
switch ( "${my_editor}" )
case "connectED":
case "gedit":
	breaksw
case "vi":
case "vim":
case "vim-enhanced":
default:
	set my_editor = `printf "%s -p" "vim-enhanced"`
	breaksw
endsw

${my_editor} "./src/Makefile" "./src/main.c" "./src/alacast.c" "./src/alacast.h" "./src/program.c" "./src/program.h" "./src/library.c" "./src/library.h" "./src/gui.c" "./src/gui.h" "./src/gui/clutter.c" "./src/gui/clutter.h" "./src/gui/gtk.c" "./src/gui/gtk.h" "./src/debug.c" "./src/debug.h"
