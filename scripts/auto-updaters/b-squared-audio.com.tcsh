#!/bin/tcsh -f
init:
	set scripts_basename="b-squared-audio.com.tcsh";
	set scripts_dir="`printf "\""%s"\"" "\""${scripts_basename}"\"" | sed -r 's/^(.*)\.tcsh"\$"/\1/`";
	set website="`printf "\""%s"\"" "\""${scripts_dir}"\"" | sed -r 's/-//g'`";
	onintr exit_script;
	if(! ${?0} ) then
		set being_sourced;
	else
		if( "`basename "\""${0}"\""`" != "${scripts_basename}" ) then
			set being_sourced;
		endif
	endif
	
	if( ${?being_sourced} ) then
		printf "This script cannot be sourced.\n" > /dev/stderr;
		unset being_sourced;
		exit -1;
	endif
	
	set scripts_path="`dirname "\""${0}"\""`/../../data/xml/opml/library/audio-dramas/studios/${scripts_dir}/";
	if(! -d "${scripts_path}" ) \
		mkdir -vp "${scripts_path}";
	cd "${scripts_path}";
	
	alias "wget" "wget --no-check-certificate --quiet";
	alias "ex" "ex -E -n -X --noplugin";
	goto update_index_opml;
#init:

exit_script:
	if( ${?scripts_basename} ) \
		unset scripts_basename;
	
	if( ${?scripts_dir} ) \
		unset scripts_dir;
	
	if( ${?website} ) \
		unset website;
	
	if( ${?being_sourced} && ! ${?supports_being_sourced} ) then
		@ errno=-9;
		printf "This script cannot be sourced.\n" > /dev/stderr;
		unset being_sourced;
	endif
	
	if(! ${?errno} ) \
		@ errno=0;
	set status=$errno;
	exit $errno;
#goto exit_script;


update_index_opml:
	if( -e "index.opml.tmp" ) \
		rm "index.opml.tmp";
	
	printf "Downloading %s latest podcasts" "${website}";
	wget -O 'index.opml' "http://www.${website}/audio.html";
	printf "\t[finished]\n";
	
	
	set categories=( "series" "one-shot" );
	foreach category( ${categories} )
		grep "${catagory}<\/" "index.opml" >! "${category}.opml";
	
	# these regex's will make sure that each catagory is placed on one line for each catagory.
	printf "\nConverting NPR's latest podcasts xhtml into opml";
	ex '+1,$s/\v[\n\r]+[\ \t]*//g' '+wq!' 'index.opml.tmp' > /dev/null;
	ex '+s/\v.*\<div\ class\=\"topicForm\"\>(.*)/\1/g' '+wq!' 'index.opml.tmp' > /dev/null;
	ex '+s/\v(\<span\ class\=\"mainTopicLnk\"\>)/\r\r\r\1/g' '+1,3d' '+1,$s/\v\<div\ class\=\"spacer\"\>.*$//g' '+wq!' 'index.opml.tmp' > /dev/null;
	ex '+1,$s/\v(\<td class\=\"colTitle)(\ top)?(\"\>)/\r\t\t\1\2\3/g' '+wq!' 'index.opml.tmp' > /dev/null;
	ex '+1,$s/\v\<td class\=\"colTitle( top)?\"\>\<a\ href\=\"(\/[^\"]+)\"\>\<span\ class\=\"titleLnk\"\>([^\<]+)\<\/span\>.*\<td\ class\=\"colProducer(\ top)?\"\>(\<a\ href\=\"[^\"]+\")[^\>]*(\>[^\<]+\<\/a\>).*/\<outline title\=\"\<\!\[CDATA\[\3\]\]\>\" xmlUrl\=\"\" type\=\"rss\" text\=\"\<\!\[CDATA\[\5\6'\''s:\ \3\]\]\>\" htmlUrl\="http:\/\/www\.npr\.org\2\" description\=\"\<\!\[CDATA\[\3\ produced by\ \5\6\]\]\>\" \/\>/g' '+wq!' 'index.opml.tmp' > /dev/null;
	ex '+1,$s/\v\<td class\=\"colTitle( top)?\"\>\<a\ href\=\"(\/[^\"]+)\"\>\<span\ class\=\"titleLnk\"\>([^\<]+)\<\/span\>.*\<td\ class\=\"colProducer(\ top)?\"\>([^\ \t]+)[\ \t]*.*/\<outline title\=\"\<\!\[CDATA\[\3\]\]\>\" xmlUrl\=\"\" type\=\"rss\" text\=\"\<\!\[CDATA\[\5'\''s:\ \3\]\]\>\" htmlUrl\="http:\/\/www\.npr\.org\2\" description\=\"\<\!\[CDATA\[\3\ produced by\ \5\]\]\>\" \/\>/g' '+wq!' 'index.opml.tmp' > /dev/null;
	ex '+1,$s/\v^(\<.*)$/\t\t\<\!\-\-\ \1\ \-\-\>/g' '+wq!' 'index.opml.tmp' > /dev/null;
	printf "\t[conversion complete]\n";
	
	
	
	printf "\nFinalizing NPR's OPML <file://%s/index.opml>" "${cwd}";
	if( -e "index.opml" )	\
		rm "index.opml";
	printf '<?xml version="1.0" encoding="UTF-8"?>\n<opml version="2.0">\n\t<head>\n\t\t<title>NPR'\''s podcasts</title>\n\t</head>\n\t<body>' >! 'index.opml';
	ex '+6r index.opml.tmp' '+wq!' 'index.opml' > /dev/null;
	printf '\n\t</body>\n</opml>\n' >> 'index.opml';
	rm "index.opml.tmp";
	printf "\t[finished]\n";
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


