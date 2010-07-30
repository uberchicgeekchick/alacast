#!/bin/tcsh -f
if(! ${?0} ) then
	printf "This script cannot be executed and may only executed.\n";
	exit -1;
endif

init:
	@ argc=${#argv};
	if( $argc < 1 ) then
		if(! -e "./titles.lst" ) then
			@ errno=-1;
			goto usage;
		endif
		
		@ argc=1;
		set argv=("./titles.lst");
	endif
	@ arg=0;
#goto init;


find_titles:
	if( ${?attribute} ) \
		unset attribute;
	while( $arg < $argc )
		@ arg++;
		set dashes="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?"\$"/\1/'`";
		if( "${dashes}" == "$argv[$arg]" ) \
			set dashes="";
		
		set option="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?"\$"/\2/'`";
		if( "${option}" == "$argv[$arg]" ) \
			set option="";
		
		set equals="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?"\$"/\3/'`";
		if( "${equals}" == "$argv[$arg]" ) \
			set equals="";
		
		set value="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?"\$"/\4/'`";
		if( "${dashes}" != "" && "${option}" != "" && "${equals}" == "" && "${value}" == "" ) then
			@ arg++;
			if( ${arg} > ${argc} ) then
				@ arg--;
			else
				set test_dashes="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=)?(.*)"\$"/\1/'`";
				set test_option="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=)?(.*)"\$"/\2/'`";
				set test_equals="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=)?(.*)"\$"/\3/'`";
				set test_value="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{1,2})([^\=]+)(=)?(.*)"\$"/\4/'`";
				
				if(!( "${test_dashes}" == "$argv[$arg]" && "${test_option}" == "$argv[$arg]" && "${test_equals}" == "$argv[$arg]" && "${test_value}" == "$argv[$arg]" )) then
					@ arg--;
				else
					set equals=" ";
					set value="$argv[$arg]";
					set arg_shifted;
				endif
				unset test_dashes test_option test_equals test_value;
			endif
		endif
		switch("$option")
			case "help":
				goto usage;
				continue;
			
			case "debug":
				if(! ${?debug} ) \
					set debug;
				continue;
			
			case "title":
			case "xmlUrl":
			case "htmlUrl":
			case "text":
			case "description":
				set attribute="${option}";
				continue;
			
			case "search-for":
			case "attribute":
				if( "${value}" != "" && ! ${?attribute} ) \
					set attribute="${value}";
				continue;
			
			
			default:
				if(! -e "$argv[$arg]" ) then
					printf "**error:** %s is either an invalid option or a non-existant file.\n" > /dev/stderr;
					set return="find_titles";
					goto usage;
				endif
		endsw
		
		if(! ${?attribute} ) \
			set attribute="title";
		
		foreach attribute_value( "`cat "\""$argv[$arg]"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`" )
			printf "Validating: <%s>\n" "${attribute_value}" > /dev/stdout;
			
			printf "Searching catalogs for: <%s="\""%s"\"">\n" "${attribute}" "${attribute_value}" > /dev/stdout;
			alacast:catalogs:search.pl --${attribute}="${attribute_value}";
			
			printf "Searching subscriptions for: <%s="\""%s"\"">\n" "${attribute}" "${attribute_value}" > /dev/stdout;
			foreach gpodder_search_output("`gPodder:Search:channels.opml.tcsh --${attribute}="\""${attribute_value}"\""`")
				if( "${gpodder_search_output}" != "" ) then
					if(! ${?gpodder_channel_found} ) \
						set gpodder_channel_found;
					printf "%s\n" "${gpodder_search_output}";
				endif
				unset gpodder_search_output;
			end
			
			printf "\n\nPress ";
			if( ${?gpodder_channel_found} ) \
				printf "'d' to delete this podcast, ";
			printf "'q' to quit, or any other key to continue:";
			set confirmation="$<";
			printf "\n";
			
			switch(`printf "%s" "${confirmation}" | sed -r 's/^(.).*$/\l\1/'`)
				case "q":
					if( ${?gpodder_channel_found} ) \
						unset gpodder_channel_found;
					unset attribute_value confirmation;
					exit -1;
					breaksw;
				
				case "d":
					if(! ${?gpodder_channel_found} ) \
						breaksw;
					
					printf "Deleting subscriptions whose: <%s="\""%s"\"">\n" "${attribute}" "${attribute_value}" > /dev/stdout;
					gPodder:Delete.tcsh --${attribute}="${attribute_value}";
					printf "\n\n";
					breaksw;
				
				default:
					breaksw;
			endsw
			
			if( ${?gpodder_channel_found} ) \
				unset gpodder_channel_found;
			unset attribute_value confirmation;
		end
	end
#goto find_titles;


exit_script:
	if( ${?gpodder_channel_found} ) \
		unset gpodder_channel_found;
	if( ${?return} ) \
		unset return;
	if( ${?attribute_value} ) \
		unset attribute_value;
	if( ${?attribute} ) \
		unset attribute;
	if( ${?gpodder_search_output} ) \
		unset gpodder_search_output;
	if( ${?confirmation} ) \
		unset confirmation;
	if( ${?usage_displayed} ) \
		unset usage_displayed;
	
	if(! ${?errno} ) \
		@ errno=0;
	set status=$errno;
	exit $status;
#goto exit_script;


usage:
	if(! ${?usage_displayed} ) then
		printf "Usage: %s [titles.lst]...\n";
		set usage_displayed;
	endif
	if(! ${?return} ) \
		set return="exit_script";
	goto $return;
#goto usage;

