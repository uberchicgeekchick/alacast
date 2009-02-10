#!/bin/tcsh -f
cd "`dirname '${0}'`"
source set_catalogs.tcsh

foreach podcast_catalog ( ${catalogs} )
	foreach opml ( "`find './${podcast_catalog}' -name '*.opml'`" )
		ex '+1,$s/^\(.*xmlUrl=["]http:\/\/feeds\.feedburner\.com\/[^"\?]\+\)\(".*\)/\1\?format\=xml\2/' '+wq' "${opml}"
	end
end
