#!/bin/tcsh -f
if(! ${?0} ) then
	printf "this script does not support being sourced.\n" > /dev/stderr;
	goto exit_script;
endif

if(! ${?1} || "${1}" == "" )	\
	goto usage

set outputs=("title" "xmlUrl");

parse_argv:
	@ arg=0;
	@ argc=${#argv};
	while( $arg < $argc )
		@ arg++;
		
		if( ${?debug} || ${?diagnostic_mode} ) \
			printf "\t**debug:** parsing "\$"argv[%d]: (%s).\n" $arg "$argv[$arg]";
		
		set dashes="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\1/'`";
		if( "${dashes}" == "$argv[$arg]" ) \
			set dashes="";
		
		set option="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\2/'`";
		if( "${option}" == "$argv[$arg]" ) \
			set option="";
		
		set equals="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\3/'`";
		if( "${equals}" == "$argv[$arg]" ) \
			set equals="";
		
		set value="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\4/'`";
		if( "${dashes}" != "" && "${option}" != "" && "${equals}" == "" && "${value}" == "" ) then
			@ arg++;
			if(!( ${arg} > ${argc} )) then
				set test_dashes="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\1/'`";
				set test_option="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\2/'`";
				set test_equals="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\3/'`";
				set test_value="`printf "\""%s"\"" "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^=]+)(=)?(.*)"\$"/\4/'`";
				
				if(!("${test_dashes}" == "$argv[$arg]" && "${test_option}" == "$argv[$arg]" && "${test_equals}" == "$argv[$arg]" && "${test_value}" == "$argv[$arg]")) then
					@ arg--;
				else
					set equals=" ";
					set value="$argv[$arg]";
					set arg_shifted;
				endif
				unset test_dashes test_option test_equals test_value;
			endif
			@ arg--;
		endif
		
		if( ${?debug} || ${?diagnostic_mode} ) \
			printf "\t**debug:** parsed "\$"argv[%d]: %s%s%s%s\n" $arg "${dashes}" "${option}" "${equals}" "${value}";
		
		switch ( "${option}" )
			case "o":
			case "abs":
			case "only":
			case "absolute-match":
				if(! ${?absolute_match} ) \
					set absolute_match;
				breaksw;
			
			case "title":
			case "xmlUrl":
			case "htmlUrl":
			case "text":
			case "description":
				set attribute="${option}";
				if(! ${?attribute_value} )	\
					set attribute_value="${value}";
				breaksw;
			
			case "help":
				goto usage;
				breaksw;
				
			case "debug":
				if(! ${?debug} )	\
					set debug;
				breaksw;
			
			case "outline":
				if(! ${?output_outlines} )	\
					set output_outlines;
				breaksw;
			
			case "enable":
				switch ( "${value}" )
					case "debug":
						if(! ${?debug} )	\
							set debug;
						breaksw;
					
					case "outline":
						if(! ${?output_outlines} )	\
							set output_outlines;
						breaksw;
				endsw
				breaksw;
			
			case "disable":
				switch( "${value}" )
					case "debug":
						if( ${?debug} )	\
							unset debug;
						breaksw;
				
					case "outline":
						if( ${?output_outlines} )	\
							unset output_outlines;
						breaksw;
					
				endsw
				breaksw;
				
			case "output":
				switch( "${value}" )
					case "title":
					case "htmlUrl":
					case "text":
					case "description":
					case "xmlUrl":
					case "url":
					case "type":
						foreach output( ${outputs} )
							if( "${value}" == "${output}" ) \
								continue;
							unset output;
						end
						if(! ${?output} ) then
							if(! ${?outputs} ) then
								set outputs=("${value}");
							else
								set outputs=( ${outputs} "${value}" );
							endif
						else
							unset output;
						endif
						breaksw;
					
					case "outline":
						set output_outlines;
					
					default:
						printf "%s is not a valid output option.\n\tSupportted output options are: title, xmlUrl, text, htmlUrl, or description.\n" > /dev/stderr;
						breaksw;
					
				endsw
				breaksw;
			
			default:
				if(! ${?attribute} )	\
					set attribute="title";
				
				if(! ${?attribute_value} ) then
					set attribute_value="${value}";
				else if( "${attribute_value}" == "" ) then
					set attribute_value="${value}";
				endif
				breaksw;
		endsw
	end
#goto parse_argv;

main:
	if( "`basename '${0}' | sed -r 's/^(alacast).*/\1/ig'`" == "alacast" ) then
		set subscriptions_opml="subscriptions.opml";
		if( -e "${HOME}/.alacast/opml/${subscriptions_opml}" ) then
			set subscriptions_opml="${HOME}/.alacast/opml/${subscriptions_opml}";
		else if( -e "${HOME}/.alacast/profiles/${USER}/opml/${subscriptions_opml}" ) then
			set subscriptions_opml="${HOME}/.alacast/profiles/${USER}/opml/${subscriptions_opml}";
		else if( -e "`dirname "\""${0}"\""`../data/profiles/${USER}/${subscriptions_opml}" ) then
			set subscriptions_opml="`dirname '${0}'`../data/profiles/${USER}/opml/${subscriptions_opml}";
		else if( -e "`dirname "\""${0}"\""`../data/profiles/default/opml/${subscriptions_opml}" ) then
			set subscriptions_opml="`dirname '${0}'`../data/profiles/default/opml/${subscriptions_opml}";
		endif
		
		set alacast_ini="`dirname "\""${subscriptions_opml}"\""`/../alacast.ini";
		set download_dir="`/bin/grep -P '^download_dir' "\""${alacast_ini}"\"" | sed -r 's/^([^=]+)="\""([^"\""]+)"\"";"\$"/\2/'`";
		if( "`printf "\""%s"\"" "\""${download_dir}"\"" | sed -r 's/.*(\{media_dir\}).*/\1/'`" == "{media_dir}" ) then
			set escaped_media_dir="`/bin/grep -P '^media_dir' "\""${alacast_ini}"\"" | sed -r 's/^([^=]+)="\""([^"\""]+)"\"";"\$"/\2/' | sed -r 's/\//\\\//g'`";
			set download_dir="`printf "\""%s"\"" "\""${download_dir}"\"" | sed -r 's/\{media_dir\}/${escaped_media_dir}/g'`";
			unset escaped_media_dir;
		endif
		unset alacast_ini;
	else
		set subscriptions_opml="channels.opml";
		if( -e "${HOME}/.config/gpodder/${subscriptions_opml}" ) \
			set subscriptions_opml="${HOME}/.config/gpodder/${subscriptions_opml}";
		
		if( -e "${HOME}/.config/gpodder/gpodder.conf" ) \
			set download_dir="`grep 'download_dir' "\""${HOME}/.config/gpodder/gpodder.conf"\"" | cut -d= -f2 | cut -d' ' -f2`";
	endif
	
	if(! -e "${subscriptions_opml}" ) then
		printf "Unable to find [%s]'s needed [%s].\n" "`basename '${0}'`" "${subscriptions_opml}";
		goto exit_script;
	endif
	
	if(! ${?absolute_match} ) then
		set wild_card=".*";
	else
		set wild_card="";
	endif
	
	set attribute_value="`printf "\""%s"\"" "\""${attribute_value}"\"" | sed -r 's/([\(\)\[\.\|])/\\\1/g' | sed -r 's/(['\''"\""])/\1\\\1\1/g' | sed -r 's/([?])/\\\1/g'`";
	
	if( ${?debug} ) then
		printf "Searching for <%s="\""%s"\"">.\n\tUsing:\n\t" "${attribute}" "${attribute_value}";
		printf "grep --line-number -i --perl-regex -e '${attribute}="\""${wild_card}${attribute_value}${wild_card}"\""' "\""${subscriptions_opml}"\""";
	endif
	
	alias egrep "grep --line-number -i --perl-regex";
#main:


find_outlines:
	@ lines_output=0;
	foreach outline_escaped("`egrep '${attribute}="\""${wild_card}${attribute_value}${wild_card}"\""' "\""${subscriptions_opml}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`")
		@ lines_output++;
		
		set outline="`printf "\""%s"\"" "\""${outline_escaped}"\""`";
		if( ${?output_outlines} ) then
			printf "%s\n" "${outline}";
			continue;
		endif
		
		foreach output( ${outputs} )
			set attribute_found="`printf "\""%s"\"" "\""${outline_escaped}"\"" | sed 's/.*${output}="\""\([^"\""]\+\)"\"".*/\1/' | sed 's/\&amp;/\&/ig'`";
			if( "${attribute_found}" != "${outline}" ) \
				printf "<%s>%s</%s>\n" "${output}" "${attribute_found}" "${output}";
			unset attribute_found;
		end
		printf "\n";
	end
#find_outlines:

exit_script:
	if( ${?outline} ) \
		unset outline;
	if( ${?option} ) \
		unset option;
	if( ${?value} ) \
		unset value;
	if( ${?output} ) \
		unset output;
	if( ${?attribute_found} ) \
		unset attribute_found;
	if( ${?attribute} ) \
		unset attribute;
	if( ${?attribute_value} ) \
		unset attribute_value;
	
	if( ${?outputs} ) \
		unset outputs;
	if( ${?output} ) \
		unset output;
	if( ${?output_escaped} ) \
		unset output_escaped;
	if( ${?output_outlines} ) \
		unset output_outlines;
	
	exit;
#exit_script:


usage:
	printf "Usage| %s [--title|description|link|url|guid|pubData=]'search_term' [attribute to display, defaults to title]\n" `basename "${0}"`;
	godo exit_script;
