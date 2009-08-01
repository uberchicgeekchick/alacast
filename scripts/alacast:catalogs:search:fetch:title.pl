#!/bin/tcsh -f
if(!( ${?1} && "${1}" != "" )) then
	printf "Usage: %s [podcast title]";
	exit -1;
endif

set podcasts_search_title="${1}";
shift;

set download_limit=1;
foreach arg ( ${argv} )
	switch ( ${arg} )
		case "-l":
		case "--download-limit":
			shift;
			set download_limit=${1};
			shift;
		breaksw;
		
		case "-s":
		case "--start-with":
			shift;
			if ( ! ( ${?1} && "${1}" != "" && "${1}" > 1 ) ) then
				printf "--download-limit and --start-with must be followed by a number.";
				breaksw;
			endif
		
			set start_with=${1};
			if( ${download_limit} < ${start_with} ) set download_limit=${start_with};
			shift;
		breaksw;
	
		case "-k":
		case "--keep-feed":
			set keep_feed;
			breaksw;
		
		case "-d":
		case "--enable-debug":
			set debug_output;
			breaksw;
		
		case "-f":
		case "--force":
		case "--force-fetch":
			set force_fetch;
			breaksw;
	endsw
end

set podcasts="`alacast:catalogs:search.pl --title='${podcasts_search_title}' | cut -d'>' -f2 | sort | uniq`";
if ( "${#podcasts}" < 1 ) then
	printf "Unable to find any podcasts titled: %s\n\talacast:catalogs:search.pl returned\n\n%s\n\n" "${podcasts_search_title}" "${podcasts}";
	exit -1;
endif

foreach podcast_xmlUrl ( "`alacast:catalogs:search.pl --title='${podcasts_search_title}' | cut -d'>' -f2 | sort | uniq`" )
	if ( ! -e "${podcasts_search_title}.xml" ) then
		wget -O "${podcasts_search_title}.xml" "${podcast_xmlUrl}";
		ex -E '+1,$s/[\n\r]\+//g' '+s/<\/\(item\|entry\)\>/<\/\1>\r/g' '+$d' '+wq' "${podcasts_search_title}.xml" >& /dev/null;
	endif
	set podcasts_title="`head -1 '${podcasts_search_title}.xml' | egrep '<title>' | sed 's/<title>\([^<]\+<\/title>\)/\n\1/' | head -2 | tail -1 | sed 's/\([^<]\+\)<\/title>.*/\1/'`";
	
	set episodes="`cat '${podcasts_search_title}.xml' | sed 's/.*<\(item\|entry\).*>.*<title>\([^<]\+\)<\/title>.*<.*enclosure[^=]*\(href\|url\)=["\""'\'']\([^"\""'\'']\+\)\.\([^\."\""'\'']\+\)["\""'\''].*<\/\(item\|entry\)>/if\ ( \! \-e "\""${podcasts_title}\/\2\.\5"\"" ) wget\ \-c\ \-O\ "\""${podcasts_title}\/\2\.\5"\"" "\""\4.\5"\"";\ \n/g' | head -${download_limit}`";
	
	if ( "${#episodes}" < 1 ) then
		printf "Unable to find any podcasts titled: %s\n\tWhile searching for enclosure all I got was this:\n\n%s\n\n" "${podcasts_title}" "${episodes}";
		if ( ! ( ${?keep_feed} ) ) rm "${podcasts_search_title}.xml";
		exit -1;
	endif
	
	@ podcast_count=1;
	if ( ! -d "${podcasts_title}" ) mkdir -p "${podcasts_title}";
	# TODO: FIXME: This adds an if() condition so only downloads w/o existing files.
	# It needs to be converted to a stat check against the feeds 'length'value.
	# I'll do this while writing Alacast 2.
	#
	#foreach episode ( "`cat '${podcasts_search_title}.xml' | sed 's/.*<\(item\|entry\).*>.*<title>\([^<]\+\)<\/title>.*<.*enclosure[^=]*\(href\|url\)=["\""'\'']\([^"\""'\'']\+\)\.\([^\."\""'\'']\+\)["\""'\''].*length=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*<\/\(item\|entry\)>/if\ ( \! \-e "\""${podcasts_title}\/\2\.\5"\""\ \|\|\ exec\(find\ "\""${podcasts_title}\/\2\.\5"\""\ \-printf '\''%s'\''\)\ \!=\ \6\ )\ wget\ \-c\ \-O\ "\""${podcasts_title}\/\2\.\5"\"" "\""\4.\5"\""/g' | head -${download_limit}`" )
	
	foreach episode ( "`cat '${podcasts_search_title}.xml' | sed 's/.*<\(item\|entry\).*>.*<title>\([^<]\+\)<\/title>.*<.*enclosure[^=]*\(href\|url\)=["\""'\'']\([^"\""'\'']\+\)\.\([^\."\""'\'']\+\)["\""'\''].*length=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*<\/\(item\|entry\)>/if\ ( \! \-e "\""${podcasts_title}\/\2\.\5"\""\ )\ wget\ \-c\ \-O\ "\""${podcasts_title}\/\2\.\5"\"" "\""\4.\5"\""/g' | head -${download_limit}`" )
	#foreach episode ( ${episodes} )
		#if( ${?start_with} && ${podcast_count} < ${start_with} ) continue;
		if ( ${?force_fetch} ) then
			set episode="`echo '${episode}' | sed 's/^if[^)]\+)\ \(.*\)/\1/g'`";
			printf "Forcing download/continue of episode: %s\n" "`echo '${episode}' | sed 's/^[^"\""]\+\([^"\""]\+\)"\""[^"\""]\+"\""\([^"\""]\+\)"\"".*/\1\ from\ \2/g'`";
		endif
		if ( ${?debug_output} ) echo "${episode}";
		set test="`${episode}`";
		@ podcast_count++;
		#if( ${?download_limit} && ${podcast_count} >= ${download_limit} ) continue;
	end
	if ( ! ( ${?keep_feed} ) ) rm "${podcasts_search_title}.xml";
end

