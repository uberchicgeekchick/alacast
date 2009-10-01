#!/bin/tcsh -f
if(!( ${?1} && "${1}" != "" )) then
	printf "Usage: %s [podcast title]" "`basename '${0}'`";
	exit -1;
endif

if(! ${?eol} ) setenv eol '$';

set alacasts_catalog_search_attribute="`echo "\""${1}"\"" | sed 's/\-\-\([^=]\+\)=\(.*\)/\1/'`";
set alacasts_catalog_search_phrase="`echo "\""${1}"\"" | sed 's/\-\-\([^=]\+\)=\(.*\)/\2/'`";
shift;

set download_limit=1;
foreach arg ( ${argv} )
	switch ( ${arg} )
		case "-l":
		case "--download-limit":
			shift;
			if ( ! ( ${?1} && "${1}" != "" && "${1}" > 1 ) ) then
				printf "--download-limit must be followed by a number whicch is greater than zero.";
				continue;
			endif
			
			set download_limit=${1};
			shift;
		breaksw;
		
		case "-s":
		case "--start-with":
			shift;
			if ( ! ( ${?1} && "${1}" != "" && "${1}" > 1 ) ) then
				printf "--start-with must be followed by a number whicch is greater than zero.";
				continue;
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
			set debug;
			breaksw;
		
		case "-f":
		case "--force":
		case "--force-fetch":
			set force_fetch;
			breaksw;
	endsw
end

if(! ${?start_with} ) set start_with=1;

if( -e "${HOME}/.alacast/profiles/${USER}/config.asc" ) cd "`cat ~/.alacast/profiles/uberChick/config.asc | /bin/grep --perl-regexp 'save_as_path.*' | /bin/sed --regexp-extended 's/.*[^=]*=["\""'\''](.*)["\""'\''];/\1/'`";


set alacasts_catalog_search_results_log_prefix="./.alacasts:catalog:search:results:@:`date '+%s'`";
alacast:catalogs:search.pl --${alacasts_catalog_search_attribute}="${alacasts_catalog_search_phrase}" | cut -d'>' -f2 | sort | uniq >! "${alacasts_catalog_search_results_log_prefix}.log";
set podcasts_count=`cat "${alacasts_catalog_search_results_log_prefix}.log"`;
if ( "${#podcasts_count}" < 1 ) then
	printf "Unable to find any podcasts who's %s matched your search phrase: %s\n\n" "${alacasts_catalog_search_attribute}" "${alacasts_catalog_search_phrase}";
	exit -1;
endif

foreach podcast_xmlUrl ( "`cat "\""${alacasts_catalog_search_results_log_prefix}.log"\""`" )
	wget -O "${alacasts_catalog_search_results_log_prefix}.xml" "${podcast_xmlUrl}";
	cp --verbose "${alacasts_catalog_search_results_log_prefix}.xml" "${alacasts_catalog_search_results_log_prefix}.wget.tcsh";
	chmod u+x  "${alacasts_catalog_search_results_log_prefix}.wget.tcsh";
	ex -E -n -X '+1,$s/[\n\r]\+//g' '+s/<\!\[CDATA\[//g' '+s/\]\]>//g' '+s/<\(item\|entry\)[^>]*>/\r<\1>/g' '+wq' "${alacasts_catalog_search_results_log_prefix}.wget.tcsh";
	
	set podcasts_title="`head -1 '${alacasts_catalog_search_results_log_prefix}.wget.tcsh' | sed 's/.*<title>\([^<]\+\)<\/title>.*/\1/' | sed 's/\//-/g' | sed 's/'\''/\\'\''/g'`";
	
	if( "${podcasts_title}" != "" ) then
		printf "\n\nDownloading %s episode(s) of %s.\n\n" "${download_limit}" "${podcasts_title}";
		#set podcasts_title="`echo "${podcasts_title}" | sed 's/'\''/'\''\\'\'''\''/g'`";
	else
		printf "A podcasts title could not be found for the podcast @:\n\t%s\nEpisodes will be saved to: 'Untitled podcast(s)'.\n" "${podcast_xmlurl}";
		set podcasts_title="Untitled podcast(s)";
	endif
	ex -E -n -X '+1d' '+wq!' "${alacasts_catalog_search_results_log_prefix}.wget.tcsh";
	
	if(! ${?force_fetch} ) then
		if( ${?debug} ) printf "All episodes will be downloaded.  Partial downloads will be completed.";
		set episode_download_condition="";
	else
		if( ${?debug} ) printf "Only episodes which have no existing file will be downloaded.";
		set episode_download_condition="if\ ( \! \-e "\""${podcasts_title}\/\2\.\6"\"" ) ";
	endif
	ex -E -n -X "${alacasts_catalog_search_results_log_prefix}.wget.tcsh" "+1,${eol}s/^<\(item\|entry\)>.*<title>\([^<]\+\)<\/title>.*<pubDate>\([^<]\+\)<\/pubDate>.*<.*enclosure.*\(href\|url\)=["\""'\'']\([^"\""'\'']\+\)\.\([^\."\""'\'']\+\)["\""'\''].*<\/\(item\|entry\)>/${episode_download_condition}wget\ \-c\ \-O\ "\""${podcasts_title}\/\2, released on: \3\.\6"\"" "\""\5\.\6"\"";\r/g" "+wq!";
	
	set episodes="`cat '${alacasts_catalog_search_results_log_prefix}.wget.tcsh' | head -${download_limit}`";
	
	if(! ( "${#episodes}" > 0 && ${#episodes} >= ${start_with} ) ) then
		printf "Unable to find any downloadable episodes for: "\""%s"\"".\n\n" "${podcasts_title}";
		if (! ${?keep_feed} ) rm "${alacasts_catalog_search_results_log_prefix}."*;
		continue;
	endif
	
	@ podcast_count=1;
	if ( ! -d "${podcasts_title}" ) mkdir -p "${podcasts_title}";
	# TODO: FIXME: if() conditions are added so only
	# non-existing files are downloaded.
	# It needs to be converted to a stat check against episodes 'length'.
	# I'll do this while writing Alacast 2.
	#foreach episode ( "`cat '${podcasts_search_title}.xml' | sed 's/.*<\(item\|entry\).*>.*<title>\([^<]\+\)<\/title>.*<pubDate>\([^<]\+\)<\/pubDate>.*<.*enclosure[^=]*\(href\|url\)=["\""'\'']\([^"\""'\'']\+\)\.\([^\."\""'\'']\+\)["\""'\''].*length=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*<\/\(item\|entry\)>/if\ ( \! \-e "\""${podcasts_title}\/\2, released on: \3\.\6"\""\ )\ wget\ \-c\ \-O\ "\""${podcasts_title}\/\2, released on: \3\.\6"\"" "\""\5.\6"\""/g' | head -${download_limit}`" )
	foreach episode ( "`cat '${alacasts_catalog_search_results_log_prefix}.wget.tcsh' | head -${download_limit}`" )
		#if( ${?start_with} && ${podcast_count} < ${start_with} ) continue;
		if ( ${?force_fetch} ) then
			set episode="`echo '${episode}' | sed 's/^if[^)]\+)\ \(.*\)/\1/g'`";
			printf "Forcing download/continue of episode: %s\n" "`echo '${episode}' | sed 's/^[^"\""]\+"\""\([^"\""]\+\)"\""[^"\""]\+"\""\([^"\""]\+\)"\"".*/\1\ from\ \2/g'`";
		endif
		if ( ${?debug} ) echo "Downloading an episode of %s using:\n\t%s" "${podcasts_title}" "${episode}";
		set test="`${episode}`";
		@ podcast_count++;
		#if( ${?download_limit} && ${podcast_count} >= ${download_limit} ) continue;
	end
	if (! ${?keep_feed} ) rm "${alacasts_catalog_search_results_log_prefix}."*;
end

