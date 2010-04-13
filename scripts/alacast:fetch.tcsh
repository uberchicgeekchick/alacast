#!/bin/tcsh -f
init:
	set scripts_basename="alacast:fetch.tcsh";
	
	if( `printf '%s' "${0}" | sed -r 's/^[^\.]*(csh)$/\1/'` == "csh" ) then
		set status=-1;
		printf "%s does not support being sourced and can only be executed.\n" "${scripts_basename}";
		goto usage;
	endif
	
	set old_owd="${cwd}";
	cd "`dirname '${0}'`";
	set scripts_path="${cwd}";
	cd "${owd}";
	set owd="${old_owd}";
	unset old_owd;
	
	set script="${scripts_path}/${scripts_basename}";
	
	if( ${#argv} < 1 ) then
		set status=-1;
		goto usage;
	endif
	
	if(! ${?eol} ) then
		set eol_set;
		set eol '$';
	endif
	
	alias	ex	"ex -E -n -X --noplugin";
	
	#set download_command="curl";
	#set download_command_with_options="${download_command} --location --fail --show-error --silent --output";
	
	set download_command="wget";
	set download_command_with_options="${download_command} --no-check-certificate --quiet --continue --output-document";
	
	alias	${download_command}	"${download_command_with_options}";
	
	set alacast_feed_downloader_script="alacast:feed:fetch-all:enclosures.tcsh";
	set alacast_fetch_all_script="`dirname '${0}'`/${alacast_feed_downloader_script}";
	if(! -x "${alacast_fetch_all_script}" ) then
		foreach alacast_fetch_all_script("`where '${alacast_feed_downloader_script}'`")
			if( "${alacast_fetch_all_script}" != "" && -x "${alacast_fetch_all_script}" ) break;
			unset alacast_fetch_all_script;
		end
		if(! ${?alacast_fetch_all_script} ) then
			printf "Failed to find %s needed which is needed to download enclosures\n" "${alacast_feed_downloader_script}" > /dev/stderr;
			exit -2;
		endif
	endif
	
	set alacast_search_pl_script="alacast:search:catalogs.pl";
	set alacast_search_pl="`dirname '${0}'`/${alacast_search_pl_script}";
	if(! -x "${alacast_search_pl}" ) then
		foreach alacast_search_pl("`where '${alacast_search_pl_script}'`")
			if( "${alacast_search_pl}" != "" && -x "${alacast_search_pl}" ) break;
			unset alacast_search_pl;
		end
		if(! ${?alacast_search_pl} ) then
			printf "Failed to find %s needed which is needed to download enclosures\n" "${alacast_search_pl_script}" > /dev/stderr;
			exit -3;
		endif
	endif
	
	set alacasts_catalog_search_results_log_prefix="alacasts:catalog:search:results@";
	set alacasts_catalog_search_results_log_timestamp="`date '+%s'`";
	set alacasts_catalog_search_results_log="./.${alacasts_catalog_search_results_log_prefix}${alacasts_catalog_search_results_log_timestamp}";
	
	goto  parse_argv; #returns to main or, possibly exits via 'usage:'.
#init:

main:
	set escaped_cwd="`printf '%s' '${cwd}' | sed -r 's/\//\\\//g'`";
	
	if(! ${?fetch_all} ) then
		if( ! ${?download_limit} && ! ${?start_with} )	\
			set fetch_all;
		
		if(! ${?download_limit} )	\
			set download_limit=0;
	
		if(! ${?start_with} )	\
			set start_with=0;
	else
		if(! ${?download_limit} )	\
			set download_limit=0;
		
		if(! ${?start_with} )	\
			set start_with=0;
	
	endif
	
if(! ${?save_to_dir} ) then
	if( -e "${HOME}/.alacast/alacast.ini" ) then
		set alacast_ini="${HOME}/.alacast/alacast.ini";
	else if( -e "${HOME}/.alacast/profiles/${USER}/alacast.ini" ) then
		set alacast_ini="${HOME}/.alacast/profiles/${USER}/alacast.ini";
	else if( -e "`dirname '${0}'`../data/profiles/${USER}/alacast.ini" ) then
		set alacast_ini="`dirname '${0}'`../data/profiles/${USER}/alacast.ini";
	else if( -e "`dirname '${0}'`../data/profiles/default/alacast.ini" ) then
		set alacast_ini="`dirname '${0}'`../data/profiles/default/alacast.ini";
	endif
	if( ${?alacast_ini} ) then
		set save_to_dir="`cat '${alacast_ini}' | /bin/grep --perl-regexp '.*save_to_dir.*' | /bin/sed -r 's/.*save_to_dir[^=]*=["\""'\'']([^"\""'\'']*)["\""'\''];/\1/'`";
		unset alacast_ini;
	endif
endif

if( ${?save_to_dir} ) then
	if( "${save_to_dir}" != "" && -d "${save_to_dir}" ) then
		if( "${save_to_dir}" != "${cwd}" ) then
			set starting_dir="${cwd}";
			cd "${save_to_dir}";
		endif
	endif
	unset save_to_dir;
endif

if( ${?podcast_xmlUrl} ) then
	printf "%s\n" "${podcast_xmlUrl}" >! "${alacasts_catalog_search_results_log}.log";
	goto fetch_podcasts;
endif

if(!( ${?alacasts_catalog_search_attribute} && ${?alacasts_catalog_search_phrase} )) then
	set status=-5;
	goto usage;
endif
#main:

find_podcasts:
	if( ${?debug} ) echo "Running:\n\t alacast:search.pl --output=outline --${alacasts_catalog_search_attribute}="\""${alacasts_catalog_search_phrase}"\"" | /bin/grep --perl-regexp 'xmlUrl=' | sed -r 's/.*xmlUrl=["\""'\\'']([^"\""'\\'']+)["\""'\\''].*/\1/' | sort | uniq \>\! "\""${alacasts_catalog_search_results_log}.log"\""";
	${alacast_search_pl} --output=outline --${alacasts_catalog_search_attribute}="${alacasts_catalog_search_phrase}" | /bin/grep --perl-regexp 'xmlUrl=' | sed -r 's/.*xmlUrl=["'\'']([^"'\'']+)["'\''].*/\1/' | sort | uniq >! "${alacasts_catalog_search_results_log}.log";
	set podcast_xmlUrl_count="`cat "\""${alacasts_catalog_search_results_log}.log"\""`";
	if(!( ${#podcast_xmlUrl_count} > 0 )) then
		printf "Unable to find any podcasts who's %s matched your search phrase: %s\n\n" "${alacasts_catalog_search_attribute}" "${alacasts_catalog_search_phrase}";
		set status=-1;
		unset podcast_xmlUrl_count;
		goto exit_script;
	endif
	unset podcast_xmlUrl_count;
#find_podcasts:

fetch_podcasts:
	set status=0;
	foreach podcast_xmlUrl ( "`cat "\""${alacasts_catalog_search_results_log}.log"\""`" )
		ex -s '+1d' '+wq' "${alacasts_catalog_search_results_log}.log";
		if( "${podcast_xmlUrl}" == "" ) continue;
		#if( ${?fetch_all} && ! ${?list_episodes} && ! ${?save_script} && "${alacast_fetch_all_script}" != "" && -x "${alacast_fetch_all_script}" ) then
		#if( ! ${?list_episodes} && ! ${?save_script} && "${alacast_fetch_all_script}" != "" && -x "${alacast_fetch_all_script}" ) then
			printf "Running %s --disable=logging $argv --xmlUrl="\""%s"\""\n" "${alacast_fetch_all_script}" "${podcast_xmlUrl}";
			${alacast_fetch_all_script} --disable=logging ${argv} --xmlUrl="${podcast_xmlUrl}";
			continue;
		#endif
		
		printf "Downloading: <%s>.\n" "${podcast_xmlUrl}";
		printf "Using:\n\t${download_command_with_options} "\""${alacasts_catalog_search_results_log}.xml"\"" "\""${podcast_xmlUrl}"\""\n\n";
		${download_command_with_options} "${alacasts_catalog_search_results_log}.xml" "${podcast_xmlUrl}";

		ex '+1,$s/[\n\r]\+//g' '+s/<\!\[CDATA\[//g' '+s/\]\]>//g' '+s/<\(item\|entry\)[^>]*>/\r<\1>/g' '+wq!' "${alacasts_catalog_search_results_log}.xml" >& /dev/null;
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

		printf "#\!/bin/tcsh -f\nalias\t'${download_command}'\t'${download_command_with_options}';\nif(\! -d "\""${cwd}/${podcasts_title}"\"" ) mkdir -p "\""${cwd}/${podcasts_title}"\"";\ncd "\""${cwd}/${podcasts_title}/"\"";\n" >! "${alacasts_catalog_search_results_log}.${download_command}.tcsh";
		ex "+1,${eol}s/\(\!\)/\\\1/g" "+wq!" "${alacasts_catalog_search_results_log}.xml" >& /dev/null;
		ex "+4r${alacasts_catalog_search_results_log}.xml" "+wq!" "${alacasts_catalog_search_results_log}.${download_command}.tcsh" >& /dev/null;
		chmod u+x  "${alacasts_catalog_search_results_log}.${download_command}.tcsh";

		ex '+5d' '+wq!' "${alacasts_catalog_search_results_log}.${download_command}.tcsh" >& /dev/null;

		if(! ${?force_fetch} ) then
			if( ${?debug} ) printf "Only episodes which have no existing file will be downloaded.\n";
			set episode_line_padding="\t";
			set episode_end_condition1="\relse\r\tprintf '\\t\\t"\""\2, released on: \7\.\5"\"" already exists.\\n\\n';\rendif";
			set episode_end_condition2="\relse\r\tprintf '\\t\\t"\""\2, released on: \3\.\6"\"" already exists.\\n\\n';\rendif";
			set episode_download_condition1="if(\! \-e "\""\2, released on: \7\.\5"\"" ) then\r";
			set episode_download_condition2="if(\! \-e "\""\2, released on: \3\.\6"\"" ) then\r";
		else
			if( ${?debug} ) printf "All episodes will be downloaded.  Partial downloads will be completed.\n";
			set episode_line_padding="";
			set episode_end_condition1="";
			set episode_end_condition2="";
			set episode_download_condition1="";
			set episode_download_condition2="";
		endif

		if( ${?list_episodes} ) then
			set episode_line_padding="${episode_line_padding}echo ";
			set episode_end_condition1=";";
			set episode_end_condition2=";";
			set episode_download_condition1="";
			set episode_download_condition2="";
		endif
		
		ex "+5,${eol}s/^<\(item\|entry\)[^>]*>.*<title>\([^<]*\)<\/title>.*<enclosure.*\(url\|href\)=["\""']\([^"\""']\+\)\.\([^\."\""'?]\+\)\([\.?]\?[^"\""']*\)["\""'].*<pubDate>\([^<]\+\)<\/pubDate>.*<\/\(item\|entry\)>.*/${episode_download_condition1}${episode_line_padding}printf "\""Downloading ${podcasts_title}'s episode: \2\\nUsing:\\n\\t${download_command_with_options} "\""\\"\"""\""\2, released on: \7\.\5"\""\\"\"""\"" "\""\\"\"""\""\4\.\5\6"\""\\"\"""\""\\n\\n"\"";\r${episode_line_padding}${download_command} "\""\2, released on: \7\.\5"\"" "\""\4\.\5\6"\"";${episode_end_condition1}/g" "+wq!" "${alacasts_catalog_search_results_log}.${download_command}.tcsh" >& /dev/null;
		ex "+5,${eol}s/.*<\(item\|entry\)>.*<title>\([^<]\+\)<\/title>.*<pubDate>\([^<]\+\)<\/pubDate>.*<.*enclosure.*\(href\|url\)=["\""']\([^"\""']\+\)\.\([^\."\""'?]\+\)\([\.?]\?[^"\""']*\)["\""'].*<\/\(item\|entry\)>.*/${episode_download_condition2}${episode_line_padding}printf "\""Downloading ${podcasts_title}'s episode: \2\\nUsing:\\n\\t${download_command_with_options} "\""\\"\"""\""\2, released on: \3\.\6"\""\\"\"""\"" "\""\\"\"""\""\5\.\6\7"\""\\"\"""\""\\n\\n"\"";\r${episode_line_padding}${download_command} "\""\2, released on: \3\.\6"\"" "\""\5\.\6\7"\"";${episode_end_condition2}/g" "+wq!" "${alacasts_catalog_search_results_log}.${download_command}.tcsh" >& /dev/null;
		ex "+5,${eol}s/.*<\(item\|entry\).*<\/\(item\|entry\)>.*[\r\n]//g" "+wq!" "${alacasts_catalog_search_results_log}.${download_command}.tcsh" >& /dev/null;
		
		if( ${start_with} > 1 ) then
			set last_line=${start_with};
			if(! ${?force_fetch} ) then
				set start_with="`echo '${start_with}*6' | bc`";
			else
				set start_with="`echo '${start_with}*2' | bc`";
				set start_with="`echo '${start_with}+2' | bc`";
			endif
			ex "+5,${start_with}d" "+wq!" "${alacasts_catalog_search_results_log}.${download_command}.tcsh" > /dev/null;
		endif
		
		if( ${download_limit} >= 1 ) then
			if(! ${?force_fetch} ) then
				set download_limit="`echo '${download_limit}*6' | bc`";
			else
				set download_limit="`echo '${download_limit}*2' | bc`";
			endif
			set download_limit="`echo '${download_limit}+5' | bc`";
			ex "+${download_limit},${eol}d" '+wq!' "${alacasts_catalog_search_results_log}.${download_command}.tcsh" > /dev/null;
		endif
		set episodes="`cat '${alacasts_catalog_search_results_log}.${download_command}.tcsh'`";

		@ podcast_count=1;
		if(! ${?save_script} ) then
			${alacasts_catalog_search_results_log}.${download_command}.tcsh;
		else
			printf "Saving %s's %s download script to: %s" "${podcasts_title}" "${download_command}" "${save_script}";
			mv -vf "${alacasts_catalog_search_results_log}.${download_command}.tcsh" "${save_script}";
		endif
	end
#fetch_podcasts:


exit_script:
	if( ${?eol_set} ) unset eol_set eol;
	if(! ${?keep_feed} ) then
		rm -v "${alacasts_catalog_search_results_log}".*;
	endif
	if( ${?starting_dir} ) then
		cd "${starting_dir}";
	endif
	exit ${status};
#exit_script:


usage:
	printf "Usage: %s --(title|text|xmlUrl|htmlUrl|description)="\""[podcast's search value]"\""\n" "${scripts_basename}";
	goto exit_script;
#usage:


parse_argv:
	set argc=${#argv};
	
	if( ${argc} == 0 ) goto main;
	
	@ arg=0;
	while( $arg < $argc )
		@ arg++;
		if( "$argv[$arg]" != "--debug" ) continue;
		printf "Enabling debug mode (via "\$"argv[%d]\n" $arg;
		set debug;
		break;
	end
	
	if( ${?debug} ) printf "Checking %s's argv options.  %d total.\n" "$argv[1]" "${argc}";
	
	@ arg=0;
	while ( $arg < $argc )
		@ arg++;
		
		if( ${?debug} || ${?diagnostic_mode} )		\
			printf "**%s debug:** Checking argv #%d (%s).\n" "${scripts_basename}" "${arg}" "$argv[$arg]";
		
		set dashes="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=?)['\''"\""]?(.*)['\''"\""]?${eol}/\1/'`";
		if( "${dashes}" == "$argv[$arg]" ) set dashes="";
		
		set option="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=?)['\''"\""]?(.*)['\''"\""]?${eol}/\2/'`";
		if( "${option}" == "$argv[$arg]" ) set option="";
		
		set equals="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=?)['\''"\""]?(.*)['\''"\""]?${eol}/\3/'`";
		if( "${equals}" == "$argv[$arg]" ) set equals="";
		
		set equals="";
		set value="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=?)['\''"\""]?(.*)['\''"\""]?${eol}/\4/'`";
		if( "${value}" != "" && "${value}" != "$argv[$arg]" ) then
			set equals="=";
		else if( "${option}" != "" ) then
			@ arg++;
			if( ${arg} > ${argc} ) then
				@ arg--;
			else
				set test_dashes="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=?)['\''"\""]?(.*)['\''"\""]?${eol}/\1/'`";
				set test_option="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=?)['\''"\""]?(.*)['\''"\""]?${eol}/\2/'`";
				set test_equals="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=?)['\''"\""]?(.*)['\''"\""]?${eol}/\3/'`";
				set test_value="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(\=?)['\''"\""]?(.*)['\''"\""]?${eol}/\4/'`";
				
				if( ${?debug} || ${?diagnostic_mode} )	\
					printf "\tparsed %sargv[%d] (%s) to test for replacement value.\n\tparsed %stest_dashes: [%s]; %stest_option: [%s]; %stest_equals: [%s]; %stest_value: [%s]\n" \$ "${arg}" "$argv[$arg]" \$ "${test_dashes}" \$ "${test_option}" \$ "${test_equals}" \$ "${test_value}";
				
				if(!("${test_dashes}" == "$argv[$arg]" && "${test_option}" == "$argv[$arg]" && "${test_equals}" == "$argv[$arg]" && "${test_value}" == "$argv[$arg]")) then
					@ arg--;
				else
					set equals="=";
					set value="$argv[$arg]";
				endif
				unset test_dashes test_option test_equals test_value;
			endif
		endif
		
		if( "`printf "\""${value}"\"" | sed -r "\""s/^(~)(.*)/\1/"\""`" == "~" ) then
			set value="`printf "\""${value}"\"" | sed -r "\""s/^(~)(.*)/${escaped_home_dir}\2/"\""`";
		endif
		
		if( "`printf "\""${value}"\"" | sed -r "\""s/^(\.)(.*)/\1/"\""`" == "." ) then
			set value="`printf "\""${value}"\"" | sed -r "\""s/^(\.)(.*)/${escaped_cwd}\2/"\""`";
		endif
		
		@ parsed_argc++;
		if(! ${?parsed_argv} ) then
			set parsed_argv=("${dashes}${option}${equals}${value}");
		else
			set parsed_argv=($parsed_argv "${dashes}${option}${equals}${value}");
		endif
		if( ${?debug} || ${?diagnostic_mode} )	\
			printf "\tparsed option %sparsed_argv[%d]: %s\n" \$ "$parsed_argc" "$parsed_argv[$parsed_argc]";
		
		switch ( "${option}" )
			case "fetch-all":
				set fetch_all;
				breaksw;
			
			case "l":
			case "download-limit":
				if(!( "${value}" != ""  && ${value} > 0 )) then
					printf "%s%s must be followed by a valid number greater than zero." "${dashes}" "${option}";
					breaksw;
				endif
				
				set download_limit=${value};
				breaksw;
			
			case "s":
			case "start-with":
				if(! ( "${value}" != ""  && ${value} > 0 )) then
					printf "%s%s must be followed by a valid number greater than zero." "${dashes}" "${option}";
					breaksw;
				endif
				
				set start_with=${value};
				breaksw;
			
			case "o":
			case "O":
			case "output":
			case "output-document":
			case "script":
			case "save-script":
				if( "${value}" != "" && -d "`dirname '${value}'`" ) then
					set save_script="${value}";
					printf "Enclosures will not be downloaded but instead the script: <file://%s> will be created.\n" "${save_script}";
					breaksw;
				endif
				
				@ arg++;
				if( $arg > $argc ) then
					@ arg--;
					printf "%s%s script's target must be within existing directory.  The script cannot be saved.\n" "${dashes}" "${option}" > /dev/stderr;
					goto exit_script;
				endif
				
				if(!( "$argv[$arg]" != "" && -d "`dirname '$argv[$arg]'`" )) then
					printf "%s%s script's target must be within existing directory.  The script cannot be saved.\n" "${dashes}" "${option}" > /dev/stderr;
					goto exit_script;
				endif
				
				set save_script="$argv[$arg]";
				printf "Enclosures will not be downloaded but instead the script: <file://%s> will be created.\n" "${save_script}";
				
				breaksw;
			
			case "l":
			case "ls":
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
			case "xmlUrl":
				if(!( "${value}" != "" && "`echo '${value}' | sed -r 's/^(http|https|ftp|file)(:\/\/).*/\2/i'`" == "://" )) then
					printf "--%s=[url] must specify a valid http, https, or ftp URI.\n" "${option}" > /dev/stderr;
					continue;
				else
					set podcast_xmlUrl="${value}";
				endif
				set argv[$arg]="";
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
					set save_to_dir="${value}";
					printf "Downloads will be saved to: <file://%s>\n" "${save_to_dir}";
					breaksw;
				endif
				
				@ arg++;
				if( $arg > $argc ) then
					@ arg--;
					printf "%s%s must specify, or be followed by a valid directory." "${dashes}" "${option}" > /dev/stderr;
					printf "\n\tDownloads will be saved to: <file://%s>\n" "${cwd}";
					breaksw;
				endif
				
				if( "$argv[$arg]" != "" && -d "$argv[$arg]" ) then
					set save_to_dir="$argv[$arg]";
					printf "Downloads will be saved to: <file://%s>\n" "${save_to_dir}";
				endif
				
				breaksw;
			
			case "htmlUrl":
			case "title":
			case "text":
			case "description":
				set alacasts_catalog_search_attribute="${option}";
				set alacasts_catalog_search_phrase="${value}";
				set argv[$arg]="";
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
				printf "--%s is not supported by %s.\n" "${option}" "${scripts_basename}" > /dev/stderr;
			breaksw;
		endsw
	end
	goto main;
#parse_argv:

