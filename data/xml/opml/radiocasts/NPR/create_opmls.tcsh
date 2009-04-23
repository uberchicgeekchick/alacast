#!/bin/tcsh -f
set NPR_DIR="`dirname ${0}`/data/xml/opml/Radiocasts/NPR";
cd "${NPR_DIR}"

if ( -e 'index.opml' ) wget -O 'index.opml' 'http://www.npr.org/rss/podcast/podcast_directory.php?type=topic';

# these regex's will make sure that each catagory is placed on one line for each catagory.
ex '+1,$s/[\ \t]\+//g' '+1,$s/[\n\r]\+//g' '+s/.*<div class="topicForm">\(.*\)/\1/g' '+s/.*\(<span class="mainTopicLnk">\)/\r\1/g' '+1d' '+$s/<div class="spacer">.*$//g' '+wq' 'index.opml'

ex '+1,$s///g' '+1,$s///g' '+1,$s///g' '+1,$s///g' '+1,$s///g' '+1,$s///g' '+1,$s///g' '+1,$s///g' '+1,$s///g' '+wq' 'index.opml'

#ex '+1,$s///g' '+1,$s///g' '+1,$s///g' '+1,$s///g' '+1,$s///g' '+1,$s///g' '+1,$s///g' '+1,$s///g' '+1,$s///g' '+wq' 'index.opml'

foreach podcast ( "`grep '<a href="\""[^"\""]+"\""' index.opml`" )
	wget -O feed.xml "${podcast}"
	rm feed.xml
end
