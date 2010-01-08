#!/bin/tcsh -f
if(!( ${?1} && "${1}" != "" )) then
	printf "Usage: %s [podcast title]" "`basename '${0}'`";
	exit -1;
endif

if(! ${?eol} ) setenv eol '$';
set alacast_feed_downloader_script="alacast:feed:fetch-all:enclosures";

while ( "${1}" != "" )
	set option="`printf "\""${1}"\"" | sed -r 's/[\-]{1,2}([^\=]+)=?['\''"\""]?(.*)['\''"\""]?/\1/'`";
	set value="`printf "\""${1}"\"" | sed -r 's/[\-]{1,2}([^\=]+)=?['\''"\""]?(.*)['\''"\""]?/\2/'`";
	switch ( ${option} )
		case "fetch-all":
			set fetch_all;
			breaksw;
		case "l":
		case "download-limit":
			if(!( "${value}" != "" && ${value} > 0 )) then
				printf "-l or --download-limit must be followed by a number whicch is greater than zero.";
				continue;
			endif
			
			set download_limit=${value};
		breaksw;
		
		case "s":
		case "start-with":
			if(! ( "${value}" != "" && ${value} > 0 )) then
				printf "-s or --start-with must be followed by a number whicch is greater than zero.";
				continue;
			endif
		
			set start_with=${value};
		breaksw;
		
		case "l":
		case "list":
		case "list-episodes":
			set list_episodes;
		breaksw;
		
		case "k":
		case "keep-feed":
			set keep_feed;
		breaksw;
		
		case "d":
		case "debug":
		case "enable-debug":
			set debug;
		breaksw;
		
		case "enable":
			switch( ${value} )
				case "debug":
					set debug;
				breaksw;
			endsw
		breaksw;
		
		case "f":
		case "force":
		case "force-fetch":
			set force_fetch;
		breaksw;
		
		default:
			if(! ${?eol} ) setenv eol='$';
			set alacasts_catalog_search_attribute="`printf "\""${option}"\"" | sed 's/\-\-\([^=]\+\)=\(.*\)${eol}/\1/'`";
			set alacasts_catalog_search_phrase="`printf "\""${value}"\"" | sed 's/\-\-\([^=]\+\)=\(.*\)${eol}/\2/'`";
			set alacasts_catalog_search_attribute="${option}";
			set alacasts_catalog_search_phrase="${value}";
		breaksw;
	endsw
	shift;
end

if(! ${?fetch_all} ) then
	if(! ${?download_limit} ) set download_limit=1;
	if(! ${?start_with} ) set start_with=1;
else
	set download_limit=0;
	set start_with=0;
endif

if( -e "${HOME}/.alacast/profiles/${USER}/alacast.ini" ) then
	set download_dir="`cat '${HOME}/.alacast/profiles/${USER}/alacast.ini' | /bin/grep --perl-regexp 'save_to_path.*' | /bin/sed -r 's/.*[^=]*=["\""'\'']([^"\""'\'']*)["\""'\''];/\1/'`";
	if( "${download_dir}" != "" && -d "${download_dir}" ) then
		if( "${download_dir}" != "${cwd}" ) set starting_dir="${cwd}";
		cd "${download_dir}";
	endif
endif


set alacasts_catalog_search_results_log_prefix="./.alacasts:catalog:search:results:@:`date '+%s'`";
if( ${?debug} ) echo "Running:\n\t alacast:search.pl --output=xmlUrl --${alacasts_catalog_search_attribute}="\""${alacasts_catalog_search_phrase}"\"" \| cut -d'>' -f2 \| sort \| uniq \>\! "\""${alacasts_catalog_search_results_log_prefix}.log"\""";
alacast:search.pl --output=xmlUrl --${alacasts_catalog_search_attribute}="${alacasts_catalog_search_phrase}" | cut -d'>' -f2 | sort | uniq >! "${alacasts_catalog_search_results_log_prefix}.log";
set podcast_xmlUrl_count="`cat "\""${alacasts_catalog_search_results_log_prefix}.log"\""`";
if(!( ${#podcast_xmlUrl_count} > 0 )) then
	printf "Unable to find any podcasts who's %s matched your search phrase: %s\n\n" "${alacasts_catalog_search_attribute}" "${alacasts_catalog_search_phrase}";
	if(! ${?keep_feed} ) rm "${alacasts_catalog_search_results_log_prefix}."*;
	set status=-1;
	exit ${status};
endif

set status=0;
foreach podcast_xmlUrl ( "`cat "\""${alacasts_catalog_search_results_log_prefix}.log"\""`" )
	if( ${?fetch_all} && ! ${?list_episodes} ) then
		if(! ${?alacast_fetch_all_script} ) then
			set alacast_fetch_all_script="`dirname '$argv[0]'`/${alacast_feed_downloader_script}";
			if(! -x "${alacast_fetch_all_script}" ) then
				foreach alacast_fetch_all_script("`where '${alacast_feed_downloader_script}'`")
					if( "${alacast_fetch_all_script}" != "" && -x "${alacast_fetch_all_script}" ) break;
					unset alacast_fetch_all_script;
				end
				if(! ${?alacast_fetch_all_script} ) then
					printf "Failed to find %s needed which is needed to download enclosures\n" "${alacast_feed_downloader_script}";
				endif
			endif
		endif
		${alacast_fetch_all_script} "${podcast_xmlUrl}";
		continue;
	endif
	
	printf "Downloading: <%s>.\n" "${podcast_xmlUrl}";
	wget -q -O "${alacasts_catalog_search_results_log_prefix}.xml" "${podcast_xmlUrl}";
	
	ex -E -n -X '+1,$s/[\n\r]\+//g' '+s/<\!\[CDATA\[//g' '+s/\]\]>//g' '+s/<\(item\|entry\)[^>]*>/\r<\1>/g' '+wq' "${alacasts_catalog_search_results_log_prefix}.xml" >& /dev/null;
	set podcasts_title="`head -1 '${alacasts_catalog_search_results_log_prefix}.xml' | sed 's/.*<title>\([^<]\+\)<\/title>.*/\1/' | sed 's/\//-/g'`";# | sed 's/'\''/\\'\''/g'`";
	
	if( "${podcasts_title}" != "" ) then
		if( "`printf "\""${podcasts_title}"\"" | sed -r 's/(The)(.*)/\1/g'`" == "The" ) \
			set podcasts_title="`printf "\""${podcasts_title}"\"" | sed -r 's/(The)\ (.*)/\2,\ \1/g' | sed 's/&[^;]\+;/ /'`";
	else
		printf "A podcasts title could not be found for the podcast @:\n\t%s\nEpisodes will be saved to: 'Untitled podcast(s)'.\n" "${podcast_xmlurl}";
		set podcasts_title="Untitled podcast(s)";
	endif
	if(! ${?fetch_all} ) then
		printf "\n\nDownloading %s episode(s) of %s.\n\n" "${download_limit}" "${podcasts_title}";
	else
		printf "\n\nDownloading all episode(s) of %s.\n\n" "${podcasts_title}";
	endif
	
	printf "#\!/bin/tcsh -f\nif(\! -d "\""${download_dir}/${podcasts_title}"\"" ) mkdir -p "\""${download_dir}/${podcasts_title}"\"";\ncd "\""${download_dir}/${podcasts_title}/"\"";\n" >! "${alacasts_catalog_search_results_log_prefix}.wget.tcsh";
	ex -E -n -X "+1,${eol}s/\(\!\)/\\\1/g" "+wq" "${alacasts_catalog_search_results_log_prefix}.xml" >& /dev/null;
	ex -E -n -X --noplugin "+3r${alacasts_catalog_search_results_log_prefix}.xml" "+wq!" "${alacasts_catalog_search_results_log_prefix}.wget.tcsh" >& /dev/null;
	chmod u+x  "${alacasts_catalog_search_results_log_prefix}.wget.tcsh";
	
	ex -E -n -X '+4d' '+wq!' "${alacasts_catalog_search_results_log_prefix}.wget.tcsh" >& /dev/null;
	
	if(! ${?force_fetch} ) then
		if( ${?debug} ) printf "Only episodes which have no existing file will be downloaded.\n";
		set episode_download_condition1="if(\! \-e "\""\2, released on: \6\.\5"\"" ) then\r";
		set episode_download_condition2="if(\! \-e "\""\2, released on: \3\.\6"\"" ) then\r";
		set episode_end_condition="\rendif";
		set episode_line_padding="\t";
	else
		if( ${?debug} ) printf "All episodes will be downloaded.  Partial downloads will be completed.\n";
		set episode_download_condition1="";
		set episode_download_condition2="";
		set episode_end_condition="";
		set episode_line_padding="";
	endif
	
	if( ${?list_episodes} ) then
		set episode_line_padding="${episode_line_padding}echo ";
		set episode_end_condition=";${episode_end_condition}";
	endif
	ex -E -n -X "+4,${eol}s/^<\(item\|entry\)[^>]*>.*<title>\([^<]*\)<\/title>.*<enclosure.*\(url\|href\)=["\""']\([^"\""']\+\)\.\([^"\""']\+\)["\""'].*<pubDate>\([^<]\+\)<\/pubDate>.*<\/\(item\|entry\)>.*/${episode_download_condition1}${episode_line_padding}printf "\""Downloading ${podcasts_title}'s episode: \2"\"";\r${episode_line_padding}wget -c -O "\""\2, released on: \6\.\5"\"" "\""\4\.\5"\"";${episode_end_condition}/g" "+wq" "${alacasts_catalog_search_results_log_prefix}.wget.tcsh" >& /dev/null;
	ex -E -n -X "+4,${eol}s/.*<\(item\|entry\)>.*<title>\([^<]\+\)<\/title>.*<pubDate>\([^<]\+\)<\/pubDate>.*<.*enclosure.*\(href\|url\)=["\""'\'']\([^"\""'\'']\+\)\.\([^\."\""'\'']\+\)["\""'\''].*<\/\(item\|entry\)>.*/${episode_download_condition2}${episode_line_padding}printf "\""Downloading ${podcasts_title}'s episode: \2"\"";\r${episode_line_padding}wget -c -O "\""\2, released on: \3\.\6"\"" "\""\5\.\6"\"";${episode_end_condition}/g" "+wq" "${alacasts_catalog_search_results_log_prefix}.wget.tcsh" >& /dev/null;
	ex -E -n -X "+4,${eol}s/.*<\(item\|entry\).*<\/\(item\|entry\)>.*[\r\n]//g" "+wq" "${alacasts_catalog_search_results_log_prefix}.wget.tcsh" >& /dev/null;
	#ex -E -n -X "+4,${eol}s/\//\-/g" "+wq" "${alacasts_catalog_search_results_log_prefix}.wget.tcsh" >& /dev/null;
	
	if( ${start_with} >= 1 ) then
		set last_line=${start_with};
		if(! ${?force_fetch} ) then
			set start_with="`echo '${start_with}*4' | bc`";
		else
			set start_with="`echo '${start_with}*2' | bc`";
		endif
		set last_line="`echo '${start_with}+3' | bc`";
		ex -E -n -X "+4,${last_line}d" "+wq!" "${alacasts_catalog_search_results_log_prefix}.wget.tcsh" >& /dev/null;
	endif
	
	if( ${download_limit} >= 1 ) then
		if(! ${?force_fetch} ) then
			set download_limit="`echo '${download_limit}*4' | bc`";
		else
			set download_limit="`echo '${download_limit}*2' | bc`";
		endif
		set download_limit="`echo '${download_limit}+3' | bc`";
		set last_line="`echo '${download_limit}+1' | bc`";
		if(! ${?eol} ) set eol='$';
		ex -E -n -X "+${last_line},${eol}d" '+wq' "${alacasts_catalog_search_results_log_prefix}.wget.tcsh" >& /dev/null;
		set episodes="`cat '${alacasts_catalog_search_results_log_prefix}.wget.tcsh' | head -${download_limit}`";
	else
		set episodes="`cat '${alacasts_catalog_search_results_log_prefix}.wget.tcsh'`";
	endif
	
	if(! ( ${#episodes} > 0 && ${#episodes} >= ${start_with} && ${#episodes} >= ${download_limit}   ) ) then
		printf "Unable to find any downloadable episodes for: "\""%s"\"".\n\n" "${podcasts_title}";
		if(! ${?keep_feed} ) rm "${alacasts_catalog_search_results_log_prefix}."*;
		continue;
	endif
	
	@ podcast_count=1;
	${alacasts_catalog_search_results_log_prefix}.wget.tcsh;
	if(! ${?keep_feed} ) rm "${alacasts_catalog_search_results_log_prefix}."*;
end

if( ${?starting_dir} ) then
	cd "${starting_dir}";
endif

exit ${status};
