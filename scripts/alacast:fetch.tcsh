#!/bin/tcsh -f
if(! ${?eol} ) then
	set eol_set;
	set eol '$';
endif

if( "`printf '%s' '${0}' | sed -r 's/^[^\.]*(csh)${eol}/\1/'`" == "csh" ) then
	if( ${?eol_set} ) unset eol_set eol;
	set status=-1;
	exit ${status};
endif

if( "${1}" == "" ) goto usage;

set script_name="`basename '${0}'`";
set alacast_feed_downloader_script="alacast:feed:fetch-all:enclosures";
set alacast_fetch_all_script="`dirname '$argv[0]'`/${alacast_feed_downloader_script}";
if(! -x "${alacast_fetch_all_script}" ) then
	foreach alacast_fetch_all_script("`where '${alacast_feed_downloader_script}'`")
		if( "${alacast_fetch_all_script}" != "" && -x "${alacast_fetch_all_script}" ) break;
		unset alacast_fetch_all_script;
	end
	if(! ${?alacast_fetch_all_script} ) then
		printf "Failed to find %s needed which is needed to download enclosures\n" "${alacast_feed_downloader_script}" > /dev/stderr;
		set alacast_fetch_all_script="";
	endif
endif

set alacasts_catalog_search_results_log_prefix="alacasts:catalog:search:results:@:";
set alacasts_catalog_search_results_log_timestamp="`date '+%s'`";
set alacasts_catalog_search_results_log="./.${alacasts_catalog_search_results_log_prefix}.${alacasts_catalog_search_results_log_timestamp}";

while ( "${1}" != "" )
	set dashes="`printf "\""${1}"\"" | sed -r 's/([\-]{1,2})([^\=]+)=?['\''"\""]?(.*)['\''"\""]?/\1/'`";
	set option="`printf "\""${1}"\"" | sed -r 's/([\-]{1,2})([^\=]+)=?['\''"\""]?(.*)['\''"\""]?/\2/'`";
	set value="`printf "\""${1}"\"" | sed -r 's/([\-]{1,2})([^\=]+)=?['\''"\""]?(.*)['\''"\""]?/\3/'`";
	
	switch ( ${option} )
		case "fetch-all":
			set fetch_all;
			breaksw;
		case "l":
		case "download-limit":
			if(!( "${value}" != "" && "${value}" != "${1}" && ${value} > 0 )) then
				printf "%s%s must be followed by a valid number greater than zero." "${dashes}" "${option}";
				breaksw;
			endif
			
			set download_limit=${value};
		breaksw;
		
		case "s":
		case "start-with":
			if(! ( "${value}" != "" && "${value}" != "${1}" && ${value} > 0 )) then
				printf "%s%s must be followed by a valid number greater than zero." "${dashes}" "${option}";
				breaksw;
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
		
		case "download-from-xmlUrl":
		case "download-xmlUrl":
		case "download-URI":
		case "download-uri":
		case "download-URL":
		case "download-url":
		case "podcast-xmlUrl":
			if(!( "${value}" != "" && "`echo '${value}' | sed -r 's/^(http|https|ftp)(:\/\/).*/\2/i'`" == "://" )) then
				printf "--%s=[url] must specify a valid http, https, or ftp URI.\n" "${option}" > /dev/stderr;
			else
				set podcast_xmlUrl="${value}";
			endif
		breaksw;
		
		case "f":
		case "force":
		case "force-fetch":
			set force_fetch;
		breaksw;
		
		case "save-to":
		case "download-to":
		case "download-dir":
		case "download-directory":
			if( "${value}" != "" && -d "${value}" ) then
				set download_dir="${value}";
			else if( ${?2} && "${2}" != "" && -d "${2}" ) then
				set download_dir="${2}";
				shift;
			endif
			breaksw;
	
		case "xmlUrl":
		case "htmlUrl":
		case "title":
		case "text":
		case "description":
			set alacasts_catalog_search_attribute="`printf "\""${option}"\"" | sed 's/\-\-\([^=]\+\)=\(.*\)${eol}/\1/'`";
			set alacasts_catalog_search_phrase="`printf "\""${value}"\"" | sed 's/\-\-\([^=]\+\)=\(.*\)${eol}/\2/'`";
			set alacasts_catalog_search_attribute="${option}";
			set alacasts_catalog_search_phrase="${value}";
		breaksw;
		
		case "d":
		case "debug":
		case "enable-debug":
			set debug;
		breaksw;
		
		case "enable":
			switch( ${value} )
				case "debug":
					if(! ${?debug} ) set debug;
				breaksw;
				
				default:
					printf "%s cannot be %s.\n" "${value}" "${option}" > /dev/stderr;
				breaksw;
			endsw
		breaksw;
		
		case "disable":
			switch( ${value} )
				case "debug":
					if( ${?debug} ) unset debug;
				breaksw;
				
				default:
					printf "%s cannot be %s.\n" "${value}" "${option}" > /dev/stderr;
				breaksw;
			endsw
		breaksw;
		
		default:
			printf "--%s is not supported by %s.\n" "${option}" "${script_name}" > /dev/stderr;
		breaksw;
	endsw
	shift;
end

if(! ${?fetch_all} ) then
	if(! ${?download_limit} ) set download_limit=1;
	if(! ${?start_with} ) set start_with=0;
else
	if(! ${?download_limit} ) set download_limit=0;
	if(! ${?start_with} ) set start_with=0;
endif

if(! ${?download_dir} ) then
	if( -e "${HOME}/.alacast/profiles/${USER}/alacast.ini" ) then
		set download_dir="`cat '${HOME}/.alacast/profiles/${USER}/alacast.ini' | /bin/grep --perl-regexp 'save_to_path.*' | /bin/sed -r 's/.*[^=]*=["\""'\'']([^"\""'\'']*)["\""'\''];/\1/'`";
	endif
endif

if( ${?download_dir} ) then
	if( "${download_dir}" != "" && -d "${download_dir}" ) then
		if( "${download_dir}" != "${cwd}" ) then
			set starting_dir="${cwd}";
			cd "${download_dir}";
		endif
	endif
	unset download_dir;
endif

if( ${?podcast_xmlUrl} ) then
	printf "%s\n" "${podcast_xmlUrl}" >! "${alacasts_catalog_search_results_log}.log";
	goto fetch_podcasts;
endif

find_podcasts:
	if( ${?debug} ) echo "Running:\n\t alacast:search.pl --output=xmlUrl --${alacasts_catalog_search_attribute}="\""${alacasts_catalog_search_phrase}"\"" \| cut -d'>' -f2 \| sort \| uniq \>\! "\""${alacasts_catalog_search_results_log}.log"\""";
	alacast:search.pl --output=xmlUrl --${alacasts_catalog_search_attribute}="${alacasts_catalog_search_phrase}" | cut -d'>' -f2 | sort | uniq >! "${alacasts_catalog_search_results_log}.log";
	set podcast_xmlUrl_count="`cat "\""${alacasts_catalog_search_results_log}.log"\""`";
	if(!( ${#podcast_xmlUrl_count} > 0 )) then
		printf "Unable to find any podcasts who's %s matched your search phrase: %s\n\n" "${alacasts_catalog_search_attribute}" "${alacasts_catalog_search_phrase}";
		if(! ${?keep_feed} ) rm -v "${alacasts_catalog_search_results_log_prefix}"*;
		set status=-1;
		unset podcast_xmlUrl_count;
		exit ${status};
	endif
	unset podcast_xmlUrl_count;
else
endif

fetch_podcasts:
	alias	ex	"ex -E -n -X --noplugin";
	set download_command="curl --location --fail --show-error --output";
	set status=0;
	foreach podcast_xmlUrl ( "`cat "\""${alacasts_catalog_search_results_log}.log"\""`" )
		if( "${podcast_xmlUrl}" == "" ) continue;
		if( ${?fetch_all} && ! ${?list_episodes} && "${alacast_fetch_all_script}" != "" && -x "${alacast_fetch_all_script}" ) then
			if( ${start_with} > 1 && ${download_limit} > 1 ) then
				printf "Running %s --start-with=%d --download-limit=%d %s\n" "${alacast_fetch_all_script}" ${start_with} ${download_limit} "${podcast_xmlUrl}";
				exec ${alacast_fetch_all_script} --disable=logging --start-with="${start_with}" --download-limit="${download_limit}" "${podcast_xmlUrl}";
			else if( ${start_with} > 1 ) then
				printf "Running %s --start-with=%d %s\n" "${alacast_fetch_all_script}" ${start_with} "${podcast_xmlUrl}";
				exec ${alacast_fetch_all_script} --disable=logging --start-with="${start_with}" "${podcast_xmlUrl}";
			else if( ${download_limit} > 1 ) then
				printf "Running %s --download-limit=%d %s\n" "${alacast_fetch_all_script}" ${download_limit} "${podcast_xmlUrl}";
				exec ${alacast_fetch_all_script} --download-limit="${download_limit}" "${podcast_xmlUrl}";
			else
				printf "Running %s %s\n" "${alacast_fetch_all_script}" "${podcast_xmlUrl}";
				exec ${alacast_fetch_all_script} --disable=logging "${podcast_xmlUrl}";
			endif
			continue;
		endif

		printf "Downloading: <%s>.\n" "${podcast_xmlUrl}";
		printf "Using:\n\t${download_command} "\""${alacasts_catalog_search_results_log}.xml"\"" "\""${podcast_xmlUrl}"\""\n\n";
		${download_command} "${alacasts_catalog_search_results_log}.xml" "${podcast_xmlUrl}";

		ex '+1,$s/[\n\r]\+//g' '+s/<\!\[CDATA\[//g' '+s/\]\]>//g' '+s/<\(item\|entry\)[^>]*>/\r<\1>/g' '+wq' "${alacasts_catalog_search_results_log}.xml" >& /dev/null;
		set podcasts_title="`head -1 '${alacasts_catalog_search_results_log}.xml' | sed 's/.*<title>\([^<]\+\)<\/title>.*/\1/' | sed 's/\//-/g'`"; # | sed 's/'\''/\\'\''/g'`";

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

		printf "#\!/bin/tcsh -f\nif(\! -d "\""${cwd}/${podcasts_title}"\"" ) mkdir -p "\""${cwd}/${podcasts_title}"\"";\ncd "\""${cwd}/${podcasts_title}/"\"";\n" >! "${alacasts_catalog_search_results_log}.curl.tcsh";
		ex "+1,${eol}s/\(\!\)/\\\1/g" "+wq" "${alacasts_catalog_search_results_log}.xml" >& /dev/null;
		ex "+3r${alacasts_catalog_search_results_log}.xml" "+wq!" "${alacasts_catalog_search_results_log}.curl.tcsh" >& /dev/null;
		chmod u+x  "${alacasts_catalog_search_results_log}.curl.tcsh";

		ex '+4d' '+wq!' "${alacasts_catalog_search_results_log}.curl.tcsh" >& /dev/null;

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
		ex "+4,${eol}s/^<\(item\|entry\)[^>]*>.*<title>\([^<]*\)<\/title>.*<enclosure.*\(url\|href\)=["\""']\([^"\""']\+\)\.\([^"\""']\+\)["\""'].*<pubDate>\([^<]\+\)<\/pubDate>.*<\/\(item\|entry\)>.*/${episode_download_condition1}${episode_line_padding}printf "\""Downloading ${podcasts_title}'s episode: \2\\nUsing:\\n\\t${download_command} "\""\\"\"""\""\2, released on: \6\.\5"\""\\"\"""\"" "\""\\"\"""\""\4\.\5"\""\\"\"""\""\\n\\n"\"";\r${episode_line_padding}${download_command} "\""\2, released on: \6\.\5"\"" "\""\4\.\5"\"";${episode_end_condition}/g" "+wq" "${alacasts_catalog_search_results_log}.curl.tcsh" >& /dev/null;
		ex "+4,${eol}s/.*<\(item\|entry\)>.*<title>\([^<]\+\)<\/title>.*<pubDate>\([^<]\+\)<\/pubDate>.*<.*enclosure.*\(href\|url\)=["\""'\'']\([^"\""'\'']\+\)\.\([^\."\""'\'']\+\)["\""'\''].*<\/\(item\|entry\)>.*/${episode_download_condition2}${episode_line_padding}printf "\""Downloading ${podcasts_title}'s episode: \2\\nUsing:\\n\\t${download_command} "\""\\"\"""\""\2, released on: \3\.\6"\""\\"\"""\"" "\""\\"\"""\""\5\.\6"\""\\"\"""\""\\n\\n"\"";\r${episode_line_padding}${download_command} "\""\2, released on: \3\.\6"\"" "\""\5\.\6"\"";${episode_end_condition}/g" "+wq" "${alacasts_catalog_search_results_log}.curl.tcsh" >& /dev/null;
		ex "+4,${eol}s/.*<\(item\|entry\).*<\/\(item\|entry\)>.*[\r\n]//g" "+wq" "${alacasts_catalog_search_results_log}.curl.tcsh" >& /dev/null;
		
		if( ${start_with} > 1 ) then
			set last_line=${start_with};
			if(! ${?force_fetch} ) then
				set start_with="`echo '${start_with}*4' | bc`";
				set last_line="`echo '${start_with}-1' | bc`";
			else
				set start_with="`echo '${start_with}*2' | bc`";
				set last_line="`echo '${start_with}+1' | bc`";
			endif
			ex "+4,${last_line}d" "+wq" "${alacasts_catalog_search_results_log}.curl.tcsh" >& /dev/null;
		endif
		
		if( ${download_limit} >= 1 ) then
			if(! ${?force_fetch} ) then
				set download_limit="`echo '${download_limit}*4' | bc`";
			else
				set download_limit="`echo '${download_limit}*2' | bc`";
			endif
			set last_line="`echo '${download_limit}+4' | bc`";
			ex "+${last_line},${eol}d" '+wq' "${alacasts_catalog_search_results_log}.curl.tcsh" >& /dev/null;
			set episodes="`cat '${alacasts_catalog_search_results_log}.curl.tcsh' | head -${download_limit}`";
		else
			set episodes="`cat '${alacasts_catalog_search_results_log}.curl.tcsh'`";
		endif

		@ podcast_count=1;
		exec "${alacasts_catalog_search_results_log}.curl.tcsh";
	end

exit_script:
	if(! ${?keep_feed} ) rm -v "${alacasts_catalog_search_results_log_prefix}"*;
	if( ${?starting_dir} ) then
		cd "${starting_dir}";
	endif
	exit ${status};

usage:
	printf "Usage: %s --(title|text|xmlUrl|htmlUrl|description)="\""[podcast's search value]"\""\n" "${script_name}";
	goto exit_script;

