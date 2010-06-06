#!/bin/tcsh -f
if(! ${?0} ) then
	printf "this script does not support being sourced.\n" > /dev/stderr;
	goto exit_script;
endif

if(! ${?1} || "${1}" == "" )	\
	goto usage

set outputs=("title" "xmlUrl");

@ arg=0;
@ argc=${#argv};
while( $arg < $argc )
	@ arg++;
	set option = "`printf "\""%s"\"" "\""${argv[$arg]}"\"" | sed 's/\-\-\([^=]\+\)=\?\(.*\)/\1/g'`";
	set equals="`printf "\""%s"\"" "\""${argv[$arg]}"\"" | sed 's/\-\-\([^=]\+\)\(=\?\)\(.*\)/\2/g'`"
	set value="`printf "\""%s"\"" "\""${argv[$arg]}"\"" | sed 's/\-\-\([^=]\+\)\(=\?\)\(.*\)/\3/g'`"
	if( "${equals}" == "" && "${value}" == "" ) then
		@ arg++;
		if( $arg <= $argc ) then
			set value="${argv[$arg]}";
		else
			@ arg--;
		endif
	endif
	
	switch ( "${option}" )
		case "title":
		case "xmlUrl":
		case "htmlUrl":
		case "text":
		case "description":
			set attribute="${option}";
			if(! ${?attribute_value} )	\
				set attribute_value="`echo "\""${value}"\"" | sed -r "\""s/(['])/\1\\\1\1/g"\"" | sed -r 's/([\?])/\\\1/g'`";
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
				break;
			endif
			
			if( "${attribute_value}" == "" ) \
				set attribute_value="${value}";
			breaksw;
	endsw
end


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
	else
		set subscriptions_opml="channels.opml";
		if( -e "${HOME}/.config/gpodder/${subscriptions_opml}" ) \
			set subscriptions_opml="${HOME}/.config/gpodder/${subscriptions_opml}";
	endif
	
	if(! -e "${subscriptions_opml}" ) then
		printf "Unable to find [%s]'s needed [%s].\n" "`basename '${0}'`" "${subscriptions_opml}";
		goto exit_script;
	endif
	
	if( ${?debug} ) then
		printf "Searching for %s(s) matching: %s.\n\tUsing:\n\t" "${attribute}" "${attribute_value}";
		echo "/usr/bin/grep --line-number -i --perl-regex -e '${attribute}=["\""].*${attribute_value}.*["\""]' "\""${subscriptions_opml}"\""";
	endif
#main:


find_outlines:
	@ lines_output=0;
	foreach outline_escaped("`/usr/bin/grep --line-number -i --perl-regex -e '${attribute}=["\""].*${attribute_value}.*["\""]' "\""${subscriptions_opml}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`")
		@ lines_output++;
		
		set outline="`printf "\""%s"\"" "\""${outline_escaped}"\""`";
		if( ${?output_outlines} ) then
			printf "%s\n" "${outline}";
			continue;
		endif
		
		foreach output( ${outputs} )
			set attribute_found="`printf "\""%s"\"" "\""${outline_escaped}"\"" | sed 's/.*${output}=["\""]\([^"\""]\+\)["\""].*/\1/' | sed 's/\&amp;/\&/g'`";
			if( "${attribute_found}" != "${outline}" ) \
				printf "%s: %s\n" "${output}" "${attribute_found}";
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
