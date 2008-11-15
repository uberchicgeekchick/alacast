#!/bin/tcsh
set alacast_dir = `dirname "${0}"`
foreach session ( `find "${alacast_dir}/../" -name "session*.sem"` )
	rm -r "${session}"
end
