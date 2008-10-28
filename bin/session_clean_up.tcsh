#!/bin/tcsh
set alacast_bin = `dirname "${0}"`
foreach session ( `find "${alacast_bin}/../" -name "session*.sem"` )
	rm -r "${session}"
end
