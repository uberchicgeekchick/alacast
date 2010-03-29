#!/bin/tcsh -f
init:
	#for once update.tcsh gets moved to 'data/xml/opml/update-scripts':
	#set npr_dir="`dirname ${0}`/../radiocasts/npr";
	set npr_dir="`dirname ${0}`";
	cd "${npr_dir}";
	
	alias	"wget"	"wget --no-check-certificate --quiet --continue";
	alias	"ex"	"ex -E -n -X --noplugin";
#init:


goto find_xmlUrls;


update_index_opml:
	if( -e "index.opml.tmp" )	\
		rm "index.opml.tmp";
	
	printf "Downloading NPR's latest podcasts.\n";
	wget -O 'index.opml.tmp' 'http://www.npr.org/rss/podcast/podcast_directory.php?type=topic';

	# these regex's will make sure that each catagory is placed on one line for each catagory.
	printf "Converting  NPR's latest podcasts xhtml into opml.\n\tPlease be patient this will take several moments";
	ex '+1,$s/\v[\n\r]+[\ \t]*//g' '+wq!' 'index.opml.tmp' > /dev/null;
	ex '+s/\v.*\<div\ class\=\"topicForm\"\>(.*)/\1/g' '+wq!' 'index.opml.tmp' > /dev/null;
	ex '+s/\v(\<span\ class\=\"mainTopicLnk\"\>)/\r\r\r\1/g' '+1,3d' '+1,$s/\v\<div\ class\=\"spacer\"\>.*$//g' '+wq!' 'index.opml.tmp' > /dev/null;
	ex '+1,$s/\v(\<td class\=\"colTitle)(\ top)?(\"\>)/\r\t\t\1\2\3/g' '+wq!' 'index.opml.tmp' > /dev/null;
	
	ex '+1,$s/\v\<td class\=\"colTitle( top)?\"\>\<a\ href\=\"(\/[^\"]+)\"\>\<span\ class\=\"titleLnk\"\>([^\<]+)\<\/span\>.*\<td\ class\=\"colProducer(\ top)?\"\>(\<a\ href\=\"[^\"]+\")[^\>]*(\>[^\<]+\<\/a\>).*/\<outline title\=\"\<\!\[CDATA\[\3\]\]\>\" xmlUrl\=\"\" type\=\"rss\" text\=\"\<\!\[CDATA\[\5\6'\''s:\ \3\]\]\>\" htmlUrl\="http:\/\/www\.npr\.org\2\" description\=\"\<\!\[CDATA\[\3\ produced by\ \5\6\]\]\>\" \/\>/g' '+wq!' 'index.opml.tmp' > /dev/null;
	ex '+1,$s/\v\<td class\=\"colTitle( top)?\"\>\<a\ href\=\"(\/[^\"]+)\"\>\<span\ class\=\"titleLnk\"\>([^\<]+)\<\/span\>.*\<td\ class\=\"colProducer(\ top)?\"\>([^\ \t]+)[\ \t]*.*/\<outline title\=\"\<\!\[CDATA\[\3\]\]\>\" xmlUrl\=\"\" type\=\"rss\" text\=\"\<\!\[CDATA\[\5'\''s:\ \3\]\]\>\" htmlUrl\="http:\/\/www\.npr\.org\2\" description\=\"\<\!\[CDATA\[\3\ produced by\ \5\]\]\>\" \/\>/g' '+wq!' 'index.opml.tmp' > /dev/null;
	
	ex '+1,$s/\v^(\<.*)$/\t\t\<\!\-\-\ \1\ \-\-\>/g' '+wq!' 'index.opml.tmp' > /dev/null;
	
	printf '\n\t<!--<outline title="<\![CDATA[]]>" xmlUrl="" type="rss" text="<\![CDATA[]]>" htmlUrl="" description="<\![CDATA[]]>"/>-->\n\t</body>\n</opml>\n' >> 'index.opml.tmp';
	
	printf "\t[conversion complete]\n";
	
	if( -e "index.opml" )	\
		rm "index.opml";
	
	printf '<?xml version="1.0" encoding="UTF-8"?>\n<opml version="2.0">\n\t<head>\n\t\t<title>NPR'\''s podcasts</title>\n\t</head>\n\t<body>' >! 'index.opml';
	
	ex '+6r index.opml.tmp' '+wq!' 'index.opml' > /dev/null;
	rm "index.opml.tmp";
#update_index_opml:

find_xmlUrls:
	if( -e "missing.xmlUrls.log" )	\
		rm "missing.xmlUrls.log";
	
	touch "missing.xmlUrls.log";
	
	if( -e "podcast.html" )	\
		rm "podcast.html";
	
	foreach htmlUrl( "`/bin/grep --perl-regexp '.*xmlUrl\="\"""\"".*htmlUrl\="\""([^"\""]+)"\""' index.opml | sed -r 's/.*xmlUrl\="\"""\"".*htmlUrl\="\""([^"\""]+)"\"".*/\1/'`" )
		set escaped_htmlUrl="`printf '%s' '${htmlUrl}' | sed -r 's/([\.\=\/\?\&])/\\\1/g'`";
		set line_number="`/bin/grep --binary-files=without-match --color --with-filename --line-number --initial-tab --no-messages --perl-regexp '.*xmlUrl\="\"""\"".*htmlUrl\="\""(${escaped_htmlUrl})"\""' index.opml | sed -r 's/^index\.opml[\ \t]*:[\ \t]*([0-9]+).*/\1/'`";
		printf "Finding xmlUrl for htmlUrl(on line: %s):\n\t<%s>\n" "${line_number}" "${htmlUrl}";
		wget -O "podcast.html" "${htmlUrl}";
		set xmlUrl="`/bin/grep 'podurl' 'podcast.html' | sed -r 's/.*value="\""([^"\""]+)"\"".*/\1/'`";
		
		if( "${xmlUrl}" == "" ) then
			printf "\t\t**error** Unable to find xmlUrl for\n"
			printf "%s\n" "${xmlUrl}" >> "missing.xmlUrls.log";
		else
			set escaped_xmlUrl="`printf '%s' '${xmlUrl}' | sed -r 's/([\.\=\/\?\&])/\\\1/g'`";
			printf "\t\tInserting xmlUrl:\n\t\t<%s>\n" "${xmlUrl}";
			ex "+${line_number}s/\v(.*xmlUrl\="\"")("\"".*htmlUrl\="\""${escaped_htmlUrl}"\"".*)/\1${escaped_xmlUrl}\2/" '+wq!' "index.opml" > /dev/null;
			set description="`/bin/grep --perl-regexp --after-context=2 'class\="\""slug"\""' podcast.html | tail -1 | sed -r 's/[\ \t]+//' | sed -r 's/['\'']/\&apos;/g' | sed -r 's/"\""/\&quot;/g'`";
			if( "${description}" != "" ) then
				set escaped_description="`printf '%s' '${description}' | sed -r 's/([\.\=\/\?\&])/\\\1/g'`";
				printf "\t\tUpdating podcast's description\n";
				ex "+${line_number}s/\v(.*)(htmlUrl\="\""${escaped_htmlUrl}"\"".*)description\="\""\<\!\[CDATA\[(.*)\]\]\>"\""\ \/\>"\$"/\1\2 description="\""\<\!\[CDATA\[${escaped_description}\ \ \3\]\]\>"\""\ \/\>/" '+wq!' "index.opml" > /dev/null;
				unset escaped_description;
			endif
			unset line_number description escaped_xmlUrl;
		endif
		rm "podcast.html";
		unset htmlUrl escaped_htmlUrl xmlUrl;
		printf "\nPlese wait\n\n";
		sleep 2;
	end
#find_xmlUrls:

