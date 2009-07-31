#!/bin/tcsh -f
set urls=("http://www.npr.org/rss/podcast/podcast_directory.php?type=topic")

foreach url ( "${urls}" )
	printf "Downloading %s\n" "${url}"
	wget --quiet -O feed.xhtml "${url}"
	sleep 2;
	if ( ! -e feed.xhtml ) then
		printf "I could not download %s or its format is incorrect.\nPlease \n" "${url}"
		continue;
	endif
	printf "Parsing xhtml in multiple opmls"
	rm feed.xhtml
end
