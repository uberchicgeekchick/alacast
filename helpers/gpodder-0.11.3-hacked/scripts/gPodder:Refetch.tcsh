#!/bin/tcsh -f
# This is TRUE if this script is called via `source`
if( "`printf '%s' '${0}' | sed -r 's/^[^\.]*(csh)/\1/'`" == "csh" ) exit;

set script_name="`basename '${0}'`";
set search_script="`dirname '${0}'`/gPodder:Search:index.rss.tcsh";
if(! ${?1} || "${1}" == "" ) goto usage


parse_argv:
	@ arg=0;
	@ argc=${#argv};
	while( $arg < $argc )
		@ arg++;
		switch("$argv[$arg]")
			case "--diagnosis":
			case "--diagnostic-mode":
				printf "**%s debug:**, via "\$"argv[%d], diagnostic mode\t[enabled].\n\n" "${script_name}" $arg;
				set diagnostic_mode;
				break;
			
			case "--debug":
				printf "**%s debug:**, via "\$"argv[%d], debug mode\t[enabled].\n\n" "${script_name}" $arg;
				set debug;
				break;
			
			default:
				continue;
		endsw
	end
#parse_argv:



while ( "${1}" != "" )
	set option="`printf "\""%s"\"" "\""${1}"\"" | sed 's/\-\-\([^=]\+\)\(=\?\)\(.*\)/\1/g'`"
	set equals="`printf "\""%s"\"" "\""${1}"\"" | sed 's/\-\-\([^=]\+\)\(=\?\)\(.*\)/\2/g'`"
	set options_value="`printf "\""%s"\"" "\""${1}"\"" | sed 's/\-\-\([^=]\+\)\(=\?\)\(.*\)/\3/g'`"
	if( "${option}" != "${1}" && "${equals}" == "" && "${options_value}" == "" && "${2}" != "" )	\
		set options_value="${2}";
	#echo "Checking ${option}\n";
	
	switch ( "${option}" )
	case "title":
	case "xmlUrl":
	case "htmlUrl":
	case "text":
	case "description":
		set search_attribute="${option}";
		set search_value="`echo "\""${options_value}"\"" | sed -r "\""s/(['])/\1\\\1\1/g"\""`";
		breaksw;
	case "help":
		goto usage;
		breaksw;
	case "s":
	case "silent":
		set silent;
		breaksw;
	case "diagnosis":
		if(! ${?diagnosis} ) set diagnosis;
		if(! ${?keep_script} ) set keep_script;
		if(! ${?debug} ) set debug;
		breaksw;
	case "f":
	case "fetch-all":
	case "r":
	case "refetch":
	case "c":
	case "continue":
		set fetch_all;
		breaksw;
	case "debug":
	case "verbose":
		if(! ${?debug} ) set debug;
		breaksw;
	case "enable":
		switch ( "${options_value}" )
		case "diagnosis":
			if(! ${?diagnosis} ) set diagnosis;
			if(! ${?keep_script} ) set keep_script;
		case "debug":
		case "verbose":
			if(! ${?debug} ) set debug;
			breaksw;
		endsw
		breaksw;
	case "disable":
		switch( "${options_value}" )
		case "diagnosis":
			if( ${?diagnosis} ) set diagnosis;
			if( ${?keep_script} ) set keep_script;
		case "debug":
		case "verbose":
			if( ${?debug} ) unset debug;
			breaksw;
		endsw
		breaksw;
	case "k":
	case "keep-script":
		if(! ${?keep_script} ) set keep_script;
		breaksw;
	default:
		if( ${?debug} )	\
			printf "%s is not a valid option.\nPlease see %s --help\n\n" "${option}" "${script_name}" > /dev/stderr;
		breaksw;
	endsw
	shift;
end

if(! ${?silent} ) then
	set silent="";
else
	# for curl:
	# set silent=" --silent";
	# for wget:
	set silent=" --quiet";
endif

#set download_command="curl${silent} --location --fail --show-error --output";
set download_command="wget${silent} --continue --output-document";

if( ${?search_attribute} && ${?search_value} ) goto find_podcasts;

usage:
	printf "%s uses %s to find what episodes to re-download.\n\tIt supports all of its options in addition to:\n\t\t-s,--silent\tCauses ouptput to be surpressed.\t\n\t\n\tIn addition %s' options are:\n\n" `${script_name}` ${search_script} ${search_script};
	${search_script} --help
	set status=-1;
	goto exit_script;
#usage

find_podcasts:
	set status=0;
	set mp3_player_folder="`grep 'mp3_player_folder' '${HOME}/.config/gpodder/gpodder.conf' | cut -d= -f2 | cut -d' ' -f2`";
	cd "${mp3_player_folder}";
	
	if( ${?GREP_OPTIONS} ) then
		set grep_options="${GREP_OPTIONS}";
		unsetenv GREP_OPTIONS;
	endif
	
	alias ex "ex -E -n -X --noplugin";
	
	set podcasts=();
	
	if( ${?debug} ) \
		printf "Search for podcasts who <%s> matches: %s\n\tUsing:\n\t%s --match-only --%s="\""%s"\""" "${search_attribute}" "${search_value}" "${search_script}" "${search_attribute}" "${search_value}";
	foreach podcast_match( "`${search_script} --match-only --edisodes-only --${search_attribute}="\""${search_value}"\""`" )
		if( ${?debug} ) \
			printf "%s found: --%s="\""%s"\""\n" "${search_script}" "${search_attribute}" "${podcast_match}";
		set index_xml="`printf "\""${podcast_match}"\"" | sed -r 's/^<file:\/\/([^>]+)>:(.*)"\$"/\1/'`";
		
		if( ${?podcast_found} )	\
			unset podcast_found;
		foreach index ( ${podcasts} )
			if( ${?debug} ) \
				printf "Comparing <%s> against <%s>\n" "${index}" "${index_xml}";
			if( "${index}" != "${index_xml}" ) \
				continue;
			set podcast_found;
			break;
		end
		
		if( ${?podcast_found} ) \
			continue;
		
		set podcasts=( ${podcasts} ${index_xml} );
		
		set podcast_match="`printf "\""${podcast_match}"\"" | sed -r 's/^<file:\/\/([^>]+)>:(.*)"\$"/\2/' | sed 's/\([-!\(\)]\)/\\\1/g' | sed -r 's/[ \t]*"\$"//' | sed -r 's/\// \- /g'`";
		
		if( ${?debug} ) \
			printf "%s\n" "${podcast_match}";
		set refetch_script="`dirname "\""${index_xml}"\""`/.gPodder:Refetch:`date '+%s'`.tcsh";
		if( ${?debug} ) \
			printf "%s\n" "${refetch_script}";
		
		if( ${?debug} ) then
			printf "cp -f "\""%s"\"" "\""%s.tmp"\" "${index_xml}" "${refetch_script}";
			if( ${?diagnosis} ) \
				continue;
		endif
		
		cp -f "${index_xml}" "${refetch_script}.tmp";
		#${search_script} --match-only --verbose --${search_attribute}="${podcast_match}" >! "${refetch_script}.tmp";
		
		if( "`printf "\""${podcast_match}"\"" | sed -r 's/(The)(.*)/\1/g'`" == "The" ) \
			set podcast_match="`printf "\""${podcast_match}"\"" | sed -r 's/(The)\ (.*)/\2,\ \1/g'`";
		
		if(! ${?fetch_all} ) then
			set line_condition="\rif\(\! -e "\""${podcast_match}\/\1, released on: \5\.\3"\"" \) then";
			set line_padding="\t";
			set line_condition_end="\relse\r\tprintf "\""\\t\\t\<file:\/\/"\$"{cwd}\/${podcast_match}\/\1, released on: \5\.\3\> already exists.\\n\\n"\"";\rendif";
		else
			set line_condition="";
			set line_padding="";
			set line_condition_end="";
		endif
		
		while( `/bin/grep -P -c '.*\<title\>[^\<]*\/[^\<]*\<\/title\>' "${refetch_script}.tmp" | sed -r 's/^([0-9]+).*$/\1/'` != 0 )
			ex -s '+1,$s/\v(.*\<title\>[^\<]*)\/([^\<]*\<\/title\>.*)/\1\-\2/g' '+wq' "${refetch_script}.tmp";
		end
		
		ex -s '+1,$s/\v\r\n?\_$//g' '+1,$s/\n//g' '+s/\v(\<\/item\>)/\1\r/g' '+1,$s/[#\!]*//g' "+1,"\$"s/\v.*\<item\>.*\<title\>([^<]+)\<\/title\>.*\<url\>(.*)\.([^<\.?]+)([\.?]?[^<]*)\<\/url\>.*\<pubDate\>([^<]+)\<\/pubDate\>.*\<\/item\>/if\(\! -d "\""${podcast_match}"\"" \) then\r\tset new_dir;\r\tmkdir "\""${podcast_match}"\"";\rendif${line_condition}\r${line_padding}printf "\""Downloading: \\n\\t${podcast_match}\/\1, released on: \5\.\3\\n"\"";\r${line_padding}${download_command} "\""${podcast_match}\/\1, released on: \5\.\3"\"" '\2\.\3\4';\r${line_padding}if\(\! -e "\""${podcast_match}\/\1, released on: \5\.\3"\"" \) printf "\""\\n**error:** <%s> could not be downloaded.\\n\\n"\"" '\2\.\3\4';${line_condition_end}\rif\( "\$"{?new_dir} \) then\r\tif\( "\"\`"ls "\""\\"\"""\""${podcast_match}"\""\\"\"""\"""\`\"" \=\= "\"""\"" \) \\\r\t\trmdir "\""${podcast_match}"\"";\r\tunset new_dir;\rendif\r/g" '+$d' '+wq!' "${refetch_script}.tmp";
		
		if( `wc -l "${refetch_script}.tmp" | sed 's/^\([0-9]\+\)\ .*/\1/g'` > 0 ) then
			printf "#\!/bin/tcsh -f\ncd "\""%s"\"";\n" "${mp3_player_folder}" >! "${refetch_script}";
			cat "${refetch_script}.tmp" >> "${refetch_script}";
			chmod +x "${refetch_script}";
			
			if( ${?debug} ) \
				vim-enhanced "${refetch_script}";
			"${refetch_script}";
		endif
		#if( ! ${?keep_script} || ! ${?debug} )	\
			rm -f "${refetch_script}.tmp";
		if( ! ${?keep_script} || ! ${?debug} )	\
			rm -f "${refetch_script}";
	end
#find_podcasts

exit_script:
	if( ${?grep_options} ) then
		setenv GREP_OPTIONS "${grep_options}";
		unset grep_options;
	endif
	
	exit ${status};
#exit_script
