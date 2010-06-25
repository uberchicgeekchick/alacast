#!/bin/tcsh -f
	if(!(${?1} && "${1}" != "" && "${1}" != "--help")) \
		goto usage
	
	set return="parse_argv_and_nuke";
	
	alias egrep "grep --line-number -i --perl-regex";
	
	if(! -e "${HOME}/.config/gpodder/gpodder.conf" ) then
		printf "gpodder doesn't appear to have been setup.\nUnable to read %s/.config/gpodder/gpodder.conf\n" "${HOME}" > /dev/stderr;
		exit -1;
	endif
	set download_dir="`grep 'download_dir' "\""${HOME}/.config/gpodder/gpodder.conf"\"" | cut -d= -f2 | cut -d' ' -f2`";
	
parse_argv_and_nuke:
	while( "${1}" != "" )
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
		endsw
		
		if( "${attrib}" == "${1}" && ( "${value}" == "" || "${value}" == "${1}" ) ) then
			set value="${1}";
			set attrib="title";
		else if( "${equals}" == "" && "${value}" == "" && "${2}" != "" ) then
			set value="${2}";
			shift;
		endif
		shift;
		
		if(!( "${attrib}" != "" && "${value}" != "" )) then
			printf "**error:** Cannot parse [%s]\n" "${1}";
			goto usage;
		endif
		
		switch ( "${attrib}" )
			case "title":
			case "xmlUrl":
			case "htmlUrl":
			case "text":
			case "description":
				breaksw;
			default:
				printf "**error:** [%s] is an unsupport search attribute\n" "${attrib}":
				goto usage;
				breaksw;
		endsw
		
		if(! ${?absolute_match} ) then
			set wild_card=".*";
		else
			set wild_card="";
		endif
		
		set value="`printf "\""%s"\"" "\""${value}"\"" | sed -r 's/(['\''"\""])/\1\\\1\1/g' | sed -r 's/([?])/\\\1/g'`";
		foreach xmlUrl( "`egrep '${attrib}="\""${wild_card}${value}${wild_card}"\""' '${HOME}/.config/gpodder/channels.opml' | sed 's/.*xmlUrl=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/' | sed 's/\(\&\)amp;/\1/g'`" )
			printf "Deleting: %s\n" "${xmlUrl}";
			( nice +5 gpodder --del="${xmlUrl}" > /dev/tty ) >& /dev/null;
			set clean_up_dir="${download_dir}/`printf "\""%s"\"" "\""${xmlUrl}"\"" | md5sum | sed -r 's/^([^ \t]+).*"\$"/\1/'`";
			if( -d "${clean_up_dir}" ) \
				rm -rv "${clean_up_dir}";
			unset clean_up_dir;
			unset xmlUrl;
		end
	end
#goto parse_argv_and_nuke;


exit_script:
	exit;
#goto exit_script;


usage:
	printf "Usage: %s --[title|xmlUrl|htmlUrl|text|description]="\""[search_term]"\""\n" "`basename "\""${0}"\""`";
	if( ${?return} ) \
		goto $return;
	
	goto exit_script;
#goto usage;


