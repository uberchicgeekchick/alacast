#!/bin/tcsh -f
if(!( ${?1} && "${1}" != "" )) then
	printf "Usage: %s [podcast title]";
	exit -1;
endif

set download_limit=1;
foreach arg ( ${argv} )
	if(!(${?podcasts_search_title})) then
		set podcasts_search_title="${1}";
		shift;
		continue;
	endif

	switch ( ${arg} )
		case "-l":
		case "--download-limit":
			shift;
			set download_limit="`echo ${1}+1 | bc`";
			shift;
		breaksw;
		
		case "-s":
		case "--start-with":
			shift;
			if ( ! ( ${?1} && "${1}" != "" && "${1}" > 1 ) ) then
				printf "--download-limit and --start-with must be followed by a number.";
				breaksw;
			endif
		
			set start_with="`echo ${1}+1 | bc`";
			if( ${download_limit} < ${start_with} ) set download_limit=${start_with};
			shift;
		breaksw;
	
		case "-k":
		case "--keep-feed":
			set keep_feed;
			shift;
			breaksw;
		
		case "-d":
		case "--enable-debug":
			set debug_output;
			shift;
			breaksw;
		
		case "-f":
		case "--force":
		case "--force-fetch":
			set force_fetch;
			shift;
			breaksw;
	endsw
end

#set podcasts="`alacast:catalogs:search.pl --title='${podcasts_search_title}' | cut -d'>' -f2 | sort | uniq`";
set podcasts="`alacast:catalogs:search.pl ${podcasts_search_title} | cut -d'>' -f2 | sort | uniq`";
if ( "${#podcasts}" < 1 ) then
	printf "Unable to find any podcasts titled: %s\n\talacast:catalogs:search.pl returned\n\n%s\n\n" "${podcasts_search_title}" "${podcasts}";
	exit -1;
endif

cd "`grep 'mp3_player_folder' '${HOME}/.config/gpodder/gpodder.conf' | cut -d= -f2 | cut -d' ' -f2`";
set podcastsXmlFile="`printf "\""${podcasts_search_title}"\"" | sed --regexp-extended 's/^\-\-([^=]+)=(.*)${eol}/\1:\2\.xml/'`";

foreach podcast_xmlUrl ( "`alacast:catalogs:search.pl --title='${podcasts_search_title}' | cut -d'>' -f2 | sort | uniq`" )
	if ( ! -e "${podcastsXmlFile}" ) then
		wget -O "${podcastsXmlFile}" "${podcast_xmlUrl}";
		ex -E '+1,$s/[\n\r]\+//g' '+s/#//g' '+s/<!\[CDATA\[//g' '+s/\]\]>//g' '+s/\|//g' '+s/<\/\(item\|entry\)\>/<\/\1>\r/g' '+$d' '+wq!' "${podcastsXmlFile}" >& /dev/null;
	endif
	set podcasts_title="`head -1 '${podcastsXmlFile}' | egrep '<title>' | sed 's/<title>\([^<]\+<\/title>\)/\n\1/' | head -2 | tail -1 | sed 's/\([^<]\+\)<\/title>.*/\1/'`";
	printf "\n\n'%s' saved to '%s'\n\n" "${podcastsXmlFile}" "${podcasts_title}";
	set mv_test="`mv '${podcastsXmlFile}' '${podcasts_title}.xml'`";
	
	set episodes="`ex -E '+1,${eol}s/\v.*\<(item|entry).*\>.*\<title\>([^<]+)\<\/title\>.*\<.*enclosure[^=]*(href|url)\=["\""'\'']([^"\""'\'']+)\.([^\."\""'\'']+)["\""'\''].*\<\/(item|entry)\>/if\ \(\ \!\ \-e\ "\""${podcasts_title}\/\2\.\5"\""\ \)\ wget\ \-c\ \-O\ "\""${podcasts_title}\/\2\.\5"\""\ "\""\4.\5"\"";\ \r/g' '+wq!' '${podcasts_title}.xml'`";
	set episodes="`cat '${podcasts_title}.xml' | head -${download_limit}`";
	
	if ( "${#episodes}" < 1 ) then
		printf "Unable to find any podcasts titled: %s\n\tWhile searching for enclosure all I got was this:\n\n%s\n\n" "${podcasts_title}" "${episodes}";
		if ( ! ( ${?keep_feed} ) ) rm "${podcasts_title}.xml";
		exit -1;
	endif
	
	@ podcast_count=1;
	if ( ! -d "${podcasts_title}" ) mkdir -p "${podcasts_title}";
	foreach episode ( "`cat '${podcasts_title}.xml' | head -${download_limit}`" )
		if ( "${episode}" == "" ) continue;
		#if( ${?start_with} && ${podcast_count} < $1{start_with} ) continue;
		if ( ${?force_fetch} ) then
			set episode="`echo '${episode}' | sed --regexp-extended 's/.*if[^)]+)\ (.*)${eol}/\1/'`";
			printf "Forcing download/continue of episode: %s\n" "`echo '${episode}' | sed --regexp-extended 's/^[^"\""]+("\""[^"\""]+"\"")[^"\""]+"\""([^"\""]+)"\""\ (.*).*${eol}/\1\ from\ \3/g'`";
			set episode="`echo '${episode}' | sed --regexp-extended 's/^[^"\""]+("\""[^"\""]+"\"")[^"\""]+"\""([^"\""]+)"\""\ (.*).*${eol}/wget\ \-c \-O\ \1\ \3/g'`";
		endif
		if ( ${?debug_output} ) echo "${episode}";
		set episode="`echo '${episode}' | sed --regexp-extended 's/.*if[^)]+\)\ (.*)${eol}/\1/g'`";
		echo "${episode}";
		set test="`${episode}`";
		@ podcast_count++;
		#if( ${?download_limit} && ${podcast_count} >= ${download_limit} ) continue;
	end
	if ( ! ( ${?keep_feed} ) ) rm "${podcasts_title}.xml";
end

