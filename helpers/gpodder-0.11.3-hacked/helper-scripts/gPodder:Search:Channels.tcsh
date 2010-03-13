#!/bin/tcsh -f
if(! ${?1} || "${1}" == "" ) goto usage

while ( ${?1} && "${1}" != "" )
	while(! ${?value} )
		set option = "`printf "\""${1}"\"" | sed 's/\-\-\([^=]\+\)=\?\(.*\)/\1/g'`";
		set options_value = "`printf "\""${1}"\"" | sed 's/\-\-\([^=]\+\)=\?\(.*\)/\2/g'`";
		#echo "Checking ${option}\n";
		
		switch ( "${option}" )
		case "title":
		case "xmlUrl":
		case "htmlUrl":
		case "text":
		case "description":
			set attribute="${option}";
			set value="`echo "\""${options_value}"\"" | sed -r "\""s/(['])/\1\\\1\1/g"\"" | sed -r 's/([\?])/\\\1/g'`";
			breaksw;
		
		case "help":
			goto usage;
			breaksw;
		
		case "debug":
			if(! ${?debug} ) set debug;
			breaksw;
		
		case "enable":
			switch ( "${options_value}" )
			case "debug":
				if(! ${?debug} ) set debug;
				breaksw;
			
			case "verbose":
				if(! ${?verbose_output} ) set verbose_output;
				breaksw;
			
			endsw
			breaksw;
		
		case "disable":
			switch( "${options_value}" )
			case "debug":
				if( ${?debug} ) unset debug;
				breaksw;
			
			case "verbose":
				if( ${?verbose_output} ) unset verbose_output;
				breaksw;
			
			endsw
			breaksw;
		
		case "verbose":
			if(! ${?verbose_output} ) set verbose_output;
			breaksw;
		
		case "output":
			switch( "${options_value}" )
				case "title":
				case "htmlUrl":
				case "text":
				case "description":
				case "xmlUrl":
					set value="`echo "\""${options_value}"\"" | sed -r "\""s/(['])/\1\\\1\1/g"\"" | sed -r 's/([\?])/\\\1/g'`";
					breaksw;
				
				default:
					printf "%s is not a valid output option.\n\tSupportted output options are: title, xmlUrl, text, htmlUrl, or description.\n" > /dev/stderr;
					breaksw;
				
				endsw
			breaksw;
		
		endsw
	shift;
	end
	
	if(!( ${?attribute} && ${?value} )) then
		set attribute="title";
		set value="${1}";
	endif

	if(!(${?output})) set output="xmlUrl";
	
	if( ${?debug} ) then
		printf "Searching for %s(s) matching: %s.\n\tUsing:\n\t" "${attribute}" "${value}";
		echo "/usr/bin/grep --line-number -i --perl-regex -e '${attribute}=["\""].*${value}.*["\""]' "\""${HOME}/.config/gpodder/channels.opml"\""";
	endif
	foreach outline ( "`/usr/bin/grep --line-number -i --perl-regex -e '${attribute}=["\""].*${value}.*["\""]' '${HOME}/.config/gpodder/channels.opml'`" )
		echo "${outline}" | sed "s/.*${output}=["\""]\([^"\""]\+\)["\""].*/\1/" | sed "s/\&amp;/\&/g";
		if( ${?verbose_output} ) echo "${outline}";
	end
	unset outline option options_value output value;
	if( ${?verbose_output} ) unset verbose_output;
end

exit

usage:
	printf "Usage| %s [--title|description|link|url|guid|pubData=]'search_term' [attribute to display, defaults to title]\n" `basename "${0}"`
	exit
