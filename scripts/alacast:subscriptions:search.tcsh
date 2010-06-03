#!/bin/tcsh -f
if(! ${?0} ) then
	printf "this script does not support being sourced.\n" > /dev/stderr;
	goto exit_script;
endif

if(! ${?1} || "${1}" == "" )	\
	goto usage

while( "${1}" != "" )
	set option = "`printf "\""${1}"\"" | sed 's/\-\-\([^=]\+\)=\?\(.*\)/\1/g'`";
	set equals="`printf "\""%s"\"" "\""${1}"\"" | sed 's/\-\-\([^=]\+\)\(=\?\)\(.*\)/\2/g'`"
	set options_value="`printf "\""%s"\"" "\""${1}"\"" | sed 's/\-\-\([^=]\+\)\(=\?\)\(.*\)/\3/g'`"
	if( "${equals}" == "" && "${options_value}" == "" && "${2}" != "" )	\
		set options_value="${2}";
	#echo "Checking ${option}\n";
	
	switch ( "${option}" )
		case "title":
		case "xmlUrl":
		case "htmlUrl":
		case "text":
		case "description":
			set attribute="${option}";
			if(! ${?value} )	\
				set value="`echo "\""${options_value}"\"" | sed -r "\""s/(['])/\1\\\1\1/g"\"" | sed -r 's/([\?])/\\\1/g'`";
			breaksw;
		
		case "help":
			goto usage;
			breaksw;
		
		case "debug":
			if(! ${?debug} )	\
				set debug;
			breaksw;
		
		case "verbose":
			if(! ${?verbose_output} )	\
				set verbose_output;
			breaksw;
		
		case "enable":
			switch ( "${options_value}" )
				case "debug":
					if(! ${?debug} )	\
						set debug;
					breaksw;
				
				case "verbose":
					if(! ${?verbose_output} )	\
						set verbose_output;
					breaksw;
			endsw
			breaksw;
		
		case "disable":
			switch( "${options_value}" )
				case "debug":
					if( ${?debug} )	\
						unset debug;
					breaksw;
			
				case "verbose":
					if( ${?verbose_output} )	\
						unset verbose_output;
					breaksw;
				
			endsw
			breaksw;
			
		case "output":
			switch( "${options_value}" )
				case "title":
				case "htmlUrl":
				case "text":
				case "description":
				case "xmlUrl":
					set output="`echo "\""${options_value}"\"" | sed -r "\""s/(['])/\1\\\1\1/g"\"" | sed -r 's/([\?])/\\\1/g'`";
					if(! ${?outputs} ) then
						set outputs=( "${output}" );
					else
						set outputs=( ${outputs} "${output}" );
					endif
					unset output;
					breaksw;
				
				default:
					printf "%s is not a valid output option.\n\tSupportted output options are: title, xmlUrl, text, htmlUrl, or description.\n" > /dev/stderr;
					breaksw;
				
			endsw
			breaksw;
		
		default:
			if( "${2}" != "" )	\
				continue;
			
			if(! ${?attribute} )	\
				set attribute="title";
			
			if(! ${?value} ) then
				set value="${1}";
				break;
			endif
			
			if( "${value}" == "" )	\
				set value="${1}";
			breaksw;
	endsw
	shift;
end


main:
	if(! ${?outputs} )	\
		set outputs=("title" "xmlUrl");
	
	if( "`basename '${0}' | sed -r 's/^(alacast).*/\1/ig'`" == "alacast" ) then
		if( -e "${HOME}/.alacast/opml/subscriptions.opml" ) then
			set subscriptions_opml="${HOME}/.alacast/opml/subscriptions.opml";
		else if( -e "${HOME}/.alacast/profiles/${USER}/opml/subscriptions.opml" ) then
			set subscriptions_opml="${HOME}/.alacast/profiles/${USER}/opml/subscriptions.opml";
		else if( -e "`dirname '${0}'`../data/profiles/${USER}/subscriptions.opml" ) then
			set subscriptions_opml="`dirname '${0}'`../data/profiles/${USER}/opml/subscriptions.opml";
		else if( -e "`dirname '${0}'`../data/profiles/default/opml/subscriptions.opml" ) then
			set subscriptions_opml="`dirname '${0}'`../data/profiles/default/opml/subscriptions.opml";
		endif
	else
		if( -e "${HOME}/.config/gpodder/channels.opml" )	\
			set subscriptions_opml="${HOME}/.config/gpodder/channels.opml";
	endif
	
	if(! ${?subscriptions_opml} ) then
		printf "Unable to find [%s]'s needed subscription.opml/channels.opml.\n" "`basename '${0}'`";
		goto exit_script;
	endif
	
	if( ${?debug} ) then
		printf "Searching for %s(s) matching: %s.\n\tUsing:\n\t" "${attribute}" "${value}";
		echo "/usr/bin/grep --line-number -i --perl-regex -e '${attribute}=["\""].*${value}.*["\""]' "\""${subscriptions_opml}"\""";
	endif
#main:


find_outlines:
	@ lines_output=0;
	foreach outline ( "`/usr/bin/grep --line-number -i --perl-regex -e '${attribute}=["\""].*${value}.*["\""]' '${subscriptions_opml}'`" )
		if( ${?verbose_output} )	\
			echo "${outline}";
		
		@ lines_output++;
		foreach output( ${outputs} )
			printf "%s: " "${output}";
			printf "%s" "${outline}" | sed "s/.*${output}=["\""]\([^"\""]\+\)["\""].*/\1/" | sed "s/\&amp;/\&/g";
			printf "\n";
		end
		printf "\n";
	end
#find_outlines:

exit_script:
	if( ${?outline} )	\
		unset outline;
	if( ${?option} )	\
		unset option;
	if( ${?options_value} )	\
		unset options_value;
	if( ${?output} )	\
		unset output;
	if( ${?value} )	\
		unset value;;
	
	if( ${?verbose_output} )	\
		unset verbose_output;
	
	exit;
#exit_script:


usage:
	printf "Usage| %s [--title|description|link|url|guid|pubData=]'search_term' [attribute to display, defaults to title]\n" `basename "${0}"`;
	godo exit_script;
