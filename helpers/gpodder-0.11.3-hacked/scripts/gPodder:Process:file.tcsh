#!/bin/tcsh -f
set scripts_basename="gPodder:Delete.tcsh";

if( ! ${?0} || ! ${?1} || "${1}" == "" || "${1}" == "--help" ) goto usage;

setup:
onintr exit_script;
if( ${?GREP_OPTIONS} ) then
	setenv grep_options="${GREP_OPTIONS}";
	unsetenv GREP_OPTIONS;
endif
#goto setup;


parse_argv:
	onintr exit_script;
	if( ${?attrib} ) \
		sleep 2;
	
	while ( ${?1} && "${1}" != "" )
		onintr parse_argv;
		if( ${?attrib} ) then
			shift;
			if( ${?value} ) then
				if( "${value}" == "${1}" ) \
					shift;
				unset value;
			endif
			unset attrib;
		endif
		
		set dashes="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/([\-]{1,2})([^=]+)(=)?(.*)"\$"/\1/'`";
		set attrib="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/([\-]{1,2})([^=]+)(=)?(.*)"\$"/\2/'`";
		set equals="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/([\-]{1,2})([^=]+)(=)?(.*)"\$"/\3/g'`";
		set value="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/([\-]{1,2})([^=]+)(=)?(.*)"\$"/\4/g'`";
		
		switch ( "${attrib}" )
			case "o":
			case "abs":
			case "only":
			case "absolute-match":
				if(! ${?absolute_match} ) \
					set absolute_match;
				continue;
				breaksw;
			
			case "add":
			case "subscribe":
				if(! ${?action} ) \
					set action="";
				if( "${action}" != "add" ) \
					set action="add";
				continue;
				breaksw;
			case "del":
			case "delete":
			case "unsubscribe":
				if(! ${?action} ) \
					set action="";
				if( "${action}" != "delete" ) \
					set action="delete";
				continue;
				breaksw;
			case "display":
				if(! ${?action} ) \
					set action="";
				if( "${action}" != "display" ) \
					set action="display";
				continue;
				breaksw;
		endsw
			
		if( "${attrib}" == "" ) \
			continue;
			
		if( "${attrib}" == "${1}" && ( "${value}" == "" || "${value}" == "${1}" ) ) then
			set value="${1}";
			set attrib="title";
		else if( "${equals}" == "" && "${value}" == "" && "${2}" != "" ) then
			set value="${2}";
			shift;
		endif
		shift;
		
		set values;
		switch ( "${attrib}" )
			case "title":
			case "htmlUrl":
			case "text":
			case "description":
				if( "${action}" == "add" ) then
					printf "Only xmlUrl(s) can be added/subscribed to.";
					continue;
				endif
			case "xmlUrl":
				if(! -e "${value}" ) then
					printf "**error:** cannot process %s.  Unable to read this file.\n" "${value}";
					continue;
				else
					breaksw;
				endif
			
			default:
				printf "%s is not supported.\n\tSupported options are: --[add|del] --[title|xmlUrl|htmlUrl|text|description]="\""[a regex, or file containing regexes, one per line, to search for]"\""\n\tFor more information see %s --help\n" "${attrib}" `basename "${0}"`
 				continue;
			breaksw
		endsw
	
		if(! ${?filename_list} ) then
			set filename_list="filename.list.${scripts_basename}.`date '+%s'`.XXXXXXXX";
			set filename_list="`mktemp --tmpdir -u "\""${filename_list}"\""`";
		endif
		cp -f "${value}" "${filename_list}";
		unset value;
		goto next_filename;
	end
	goto exit_script;
#goto parse_argv;


next_filename:
	onintr parse_argv;
	if( ${?value} ) \
		sleep 2;
	
	foreach value( "`cat "\""${filename_list}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g' | sed -r "\""s/(['])/\1\\\1\1/g"\"" | sed -r 's/([[()])/\\\1/g'`" )
		onintr next_filename;
		ex -s '+1d' '+wq!' "${filename_list}";
		
		if( `printf "%s" "${value}" | sed -r 's/^(.).*$/\1/'` == "#" ) \
			continue;
		
		if(! ${?absolute_match} ) then
			set wild_card=".*";
		else
			set wild_card="";
		endif
		
		printf "\n\tSearching for <%s="\""%s%s%s"\"">" "${attrib}" "${wild_card}" "${value}" "${wild_card}";
		if( ${?found_podcast} ) \
			unset found_podcast;
		
		goto find_podcast;
	end
	unset value;
	goto parse_argv;
#goto next_filename;


find_podcast:
	onintr next_filename;
	if( ${?podcast} ) \
		sleep 2;
	
	foreach podcast( "`grep -i --perl-regex '${attrib}="\""${wild_card}${value}${wild_card}"\""' '${HOME}/.config/gpodder/channels.opml'| sed 's/\(["\""'\'']\)/\1\\\1\1/g' | sed -r 's/(\&)amp;/\1/g'`" )
		onintr find_podcast;
		if( ${?found_podcast} ) \
			unset found_podcast;
		
		set title="`printf "\""%s"\"" "\""${podcast}"\"" | sed -r 's/[\\"\""]+/"\""/g' | sed -r 's/.*title="\""([^"\""]+)"\"".*/\1/'`";
		set text="`printf "\""%s"\"" "\""${podcast}"\"" | sed 's/[\\"\""'\'']\+/"\""/g' | sed 's/.*text=["\""]\([^"\""]\+\)["\""].*/\1/'`";
		set xmlUrl="`printf "\""%s"\"" "\""${podcast}"\"" | sed 's/[\\"\""]\+/"\""/g' | sed 's/.*xmlUrl=["\""]\([^"\""]\+\)["\""].*/\1/'`";
		if( "${xmlUrl}" == "" ) then
			#unset title text xmlUrl;
			continue;
		endif
		
		if( "${title}" != "" && "${xmlUrl}" != "" ) then
			#printf "\n\t%s: %s ( %s )\t[found]\n" "${title}" "${xmlUrl}" "${text}";
			if(! ${?found_podcast} ) then
				@ found_podcasts++;
				set found_podcast;
			endif
		endif
		
		switch( "${action}" )
			case "delete":
				printf "\n\tUnsubscribing from: <%s>\n" "${xmlUrl}";
				nice +5 gpodder --del="${xmlUrl}";
				breaksw;
			
			case "display":
				if( ${?found_podcast} ) then
					printf "\n\tSubscription to <%s="\""%s%s%s"\"">\t[found]\n\t\t%s\n" "${attrib}" "${wild_card}" "${value}" "${wild_card}" "${podcast}";
					break;
				endif
			
			case "add":
				if( ${?found_podcast} ) \
					break;
			
			default:
				printf "\n\tSubscription to <%s="\""%s%s%s"\"">\t[found]\n\t\t%s\n" "${attrib}" "${wild_card}" "${value}" "${wild_card}" "${podcast}";
				breaksw;
		endsw
		unset podcast;
		#unset title text xmlUrl;
	end
	
	if( ${?found_podcast} ) then
		if( ${?podcast} ) \
			unset podcast;
		if( ${?value} ) \
			unset value;
		unset title text xmlUrl;
		goto next_filename;
	endif
	
	if( ! ${?attrib} && ! ${?value} ) \
		goto next_filename;
	
	switch( "${action}" )
		case "add":
			printf "\n\tsubscribing to:\t<%s>\n\n" "${value}";
			nice +5 gpodder --add="${value}";
			breaksw;
		case "display":
		default:
			printf "\n\tNo subscriptions to <%s="\""%s%s%s"\"">\t[none found]\n\n" "${attrib}" "${wild_card}" "${value}" "${wild_card}";
			breaksw;
	endsw
	unset value;
	goto next_filename;
#goto find_podcast;


exit_script:
	unset scripts_basename;
	if( ${?filename_list} ) then
		if( -e "${filename_list}" ) \
			rm -f "${filename_list}";
	endif
	if( ${?grep_options} ) then
		setenv GREP_OPTIONS "${grep_options}";
		unsetenv grep_options;
	endif
	if(! ${?errno} ) \
		@ errno=0;
	set status=$errno;
	exit ${errno};
#goto exit_script;

usage:
	printf "Usage: %s [--help] [\n\t-f, --find, --search(default)\t\t search to see if you are subscribed to any podcasts matching the term.\n\t-d --del,--delete,--unsubscribe\t\t---add, --subscribe]\tonly valid if your using xmlUrl(s), this will subscribe you to the specified xmlUrl\n\t\t--[title|xmlUrl|htmlUrl|text|description]="\""[a regex, or file containing regexes, one per line, to search for, add, or delete]"\""\n" "${scripts_basename}";
	goto exit_script;
