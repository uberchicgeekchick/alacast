#!/bin/tcsh
set add_or_del = ""
switch ( "${1}" )
	case "del":
		set add_or_del = "del"
	breaksw

	default
		set add_or_del = "add"
	breaksw
endsw

foreach podcast ( `cat add.lst` )
	gpodder --"${add_or_del}"="${podcast}"
end

