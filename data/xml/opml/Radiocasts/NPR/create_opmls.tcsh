#!/bin/tcsh -f
foreach podcast ( "`grep '<a href="\""[^"\""]+"\""' index.opml`" )
	wget -O feed.xml "${podcast}"
	rm feed.xml
end
