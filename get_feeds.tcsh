#!/usr/bin/tcsh -f
foreach feed ( "`cat new-podiobooks.lst`" )
	set feedfile = `dirname ${feed}`
	set feedfile = "feeds/"`basename ${feedfile}`".lst"
	wget -O "${feedfile}" "${feed}"
end
