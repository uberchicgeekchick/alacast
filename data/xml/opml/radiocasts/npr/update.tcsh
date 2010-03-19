#!/bin/tcsh -f
#for once update.tcsh gets moved to 'data/xml/opml/update-scripts':
#set npr_dir="`dirname ${0}`/../radiocasts/npr";
set npr_dir="`dirname ${0}`";
cd "${npr_dir}";

alias wget 'wget --no-check-certificate --quiet --continue --output-document';

wget 'index.opml.tmp' 'http://www.npr.org/rss/podcast/podcast_directory.php?type=topic';

# these regex's will make sure that each catagory is placed on one line for each catagory.
ex '+1,$s/[\ \t]\+//g' '+1,$s/[\n\r]\+//g' '+s/.*<div class="topicForm">\(.*\)/\1/g' '+s/.*\(<span class="mainTopicLnk">\)/\r\r\r\1/g' '+1d' '+$s/<div class="spacer">.*$//g' '+1,$s/\v(\<td class\=\"colTitle)(\ top)?(\"\>)/\r\t\t\1\2\3/' '+wq!' 'index.opml.tmp';

ex '+1,$s/\v\<td class\=\"colTitle( top)?\"\>\<a\ href\=\"(\/[^\"]+)\"\>\<span\ class\=\"titleLnk\"\>([^\<]+)\<\/span\>.*\<td\ class\=\"colProducer(\ top)?\"\>(\<a\ href\=\"[^\"]+\")[^\>]*(\>[^\<]+\<\/a\>).*/\<outline title\=\"\<\!\[CDATA\[\3\]\]\>\" xmlUrl\=\"http:\/\/www\.npr\.org\2\" type\=\"rss\" text\=\"\<\!\[CDATA\[\5\6\'s:\ \3\]\]\>\" htmlUrl\="http:\/\/www\.npr\.org\2\" description\=\"\<\!\[CDATA\[\3\ produced by\ \5\6\]\]\>" \/\>/g' '+wq!' 'index.opml.tmp';

ex '+1,$s/\v^(\<.*)$/\t\t\<\!\-\-\ \1\ \-\-\>/g' '+wq!' 'index.opml.tmp';

printf '\n\t<!--<outline title="<![CDATA[]]>" xmlUrl="" type="rss" text="<![CDATA[]]>" htmlUrl="" description="<![CDATA[]]>"/>-->\n\t</body>\n</opml>\n' >> 'index.opml.tmp';

printf "<?xml version="\""1.0"\"" encoding="\""UTF-8"\""?>\n<opml version="\""2.0"\"">\n\t<head>\n\t\t<title>NPR's podcasts</title>\n\t</head>\n\t<body>" >! 'index.opml';

ex '+6r "index.opml.tmp"' '+wq!' 'index.opml';

#ex '+1,$s///g''+wq!' 'index.opml.tmp'

#ex '+1,$s///g''+wq!' 'index.opml.tmp'

#ex '+1,$s///g''+wq!' 'index.opml.tmp'

#ex '+1,$s///g''+wq!' 'index.opml.tmp'

#ex '+1,$s///g''+wq!' 'index.opml.tmp'

#ex '+1,$s///g''+wq!' 'index.opml.tmp'

#ex '+1,$s///g''+wq!' 'index.opml.tmp'

#ex '+1,$s///g''+wq!' 'index.opml.tmp'

