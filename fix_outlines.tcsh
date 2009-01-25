#!/bin/tcsh -f
source data/xml/opml/set_catalogs.tcsh
cd data/xml/opml

foreach podcast_catalog ( $catalogs )
	foreach opml_file ( "`/usr/bin/find '${podcast_catalog}' -iname '*.opml'`" )
		ex '+1,$s/\v^(.*<outline.*type\="rss")( htmlUrl\="[^"]*")( text\="[^"]*")(.*\/\>)$/\1\3\2\4/' '+wq' "${opml_file}"
	end
end
