#!/bin/tcsh -f
if(!( ${?1} && "${1}" != "" && "${1}" != "--help" )) goto usage

set gpodder_dl_dir = "`grep 'download_dir' '${HOME}/.config/gpodder/gpodder.conf' | cut -d= -f2 | cut -d' ' -f2`"

while( "${1}" != "" )
	set param="`printf '${1}' | sed 's/\-\-\([^=]\+\)=\?\(.*\)/\1/g'`"
	set option="`printf '${1}' | sed 's/\-\-\([^=]\+\)=\?\(.*\)/\2/g'`"
	switch ( "${param}" )
		case "title":
		case "description":
		case "link":
		case "url":
		case "guid":
		case 'link':
		case "pubDate":
			set attrib="${param}";
			if( "${param}" == "" && "${2}" != "" ) then
				shift;
				set value="${1}";
			else
				set value="${option}";
			endif
		breaksw;
	case "output":
		switch ( "${option}" )
		case "title":
		case "description":
		case "url":
		case "guid":
		case "pubDate":
		case "link":
			set ouput="${option}";
			breaksw;
		default:
			printf "%s is not a valid --output option.\nPlease see %s --help\n\n" "${option}" "`basename '${0}'`" > /dev/stderr;
			breaksw;
		endsw
		breaksw;
	case "verbose":
		set be_verbose;
		breaksw;
	case "refetch":
		set refetch;
		if( "${option}" != "silent" ) then
			set silent="";
		else
			set silent="--silent";
		endif
		breaksw;
	case "help":
		goto usage;
		breaksw;
	default:
		printf "%s is not a valid option.\nPlease see %s --help\n\n" "${param}" "`basename '${0}'`" > /dev/stderr;
		breaksw;
	endsw
	shift;
end

if(! ${?attrib} ) set attrib="title";
if(! ${?value} ) set value="${1}";
if(! ${?output} ) set output="${attrib}";

alias egrep "/usr/bin/grep --binary-files=without-match --color --with-filename --line-number --initial-tab --no-messages --perl-regexp";
alias ex "ex -E -n -X --noplugin";

foreach index ( ${gpodder_dl_dir}/*/index.xml )
	set found="`egrep '<${attrib}>.*${value}.*<\/${attrib}>' '${index}' | sed -r 's/[\r\n]+//' | sed -r 's/<${attrib}>/\n&/g' | sed -r 's/^(.*)<\/${attrib}>.*/\1\r/g'`";
	
	if( "${found}" == "" ) continue;
	
	@ items=0;
	foreach item("`egrep "\""<${output}>[^<]+<\/${output}>"\"" "\""${index}"\"" | sed -r 's/[\r\n]+//' | sed -r "\""s/<${output}>/\n&/g"\"" | sed -r "\""s/^<${output}>(.*)<\/${output}>.*/\1\r/g"\""`")
		@ items++;
		if( ${items} == 1 ) continue;
		printf "%s:%s\n" "${index}" "${item}"
	end
	
	if( ${?be_verbose} ) then
		printf "\n";
		cat "${index}" | sed -r "s/<${output}>/\n&/g" | sed -r "s/<\/${output}>/&\n/g" | sed -r 's/^(.)/\t\1/';
		printf "\n\n";
	endif
	
	if( ${?refetch} ) then
		printf "#\!/bin/tcsh -f\n" >! "${index}".tcsh;
		cat "${index}" >> "${index}".tcsh;
		ex '+2d' '+2,$s/[\r\n]\+//g' '+s/\(<\/item>\)/\1\r/g' '+2,$s/\(<title>\)/\r\1/g' '+2d' '+2,$s/[\#\!]//g' '+wq!' "${index}".tcsh > /dev/null;
		ex '+2s/\v.*\<title\>([^<]+)\<\/title\>.*/\1/' '+2s/"/"\\""/' '+wq!' "${index}".tcsh > /dev/null;
		ex '+2s/\v(.*)/set podcast_title="\1";\rif( -d "${podcast_title}" ) then\relse\r\tset new_dir;\r\tmkdir -p "${podcast_title}";\rendif\r/' '+6,$s/\v\<title\>([^\<]+)\<\/title\>.*\<url\>(.*)\.([^\.\<]+)\<\/url\>.*\<pubDate\>([^\<]+)\<\/pubDate\>.*/if(! -e "${podcast_title}\/\1, released on \4\.\3" ) then\r\tprintf "Downloading ${podcast_title} episode: \1\\n";\r\tcurl '${silent}'--location --fail --show-error --output "${podcast_title}\/\1, released on \4\.\3" "\2.\3";\r\tif( -e "${podcast_title}\/\1, released on \4\.\3" ) then\r\t\tset podcast_downloaded;\r\telse\r\t\tprintf "\\n**error:** <%s> could not be downloaded.\\n\\n" "${podcast_title}\/\1, released on \4\.\3";\r\tendif\rendif\r/' '+wq!' "${index}".tcsh > /dev/null;
		ex '+6,$s/\v^\<\/?[^\<]+\>[\r\n]*//' '+wq!' "${index}".tcsh > /dev/null;
		printf 'if( ${?new_dir} && ! ${?podcasts_downloaded} ) then\n\trmdir "${podcast_title}";\n\tunset new_dir;\nendif\n' >> "${index}".tcsh;
		chmod u+x "${index}".tcsh;
		"${index}".tcsh;
		rm "${index}.tcsh"
	endif
end

exit

usage:
	printf "Usage| %s [--verbose] [--title(default)|description|link|url|guid|pubData=]'search_term' [attribute to display, defaults to title]\n" `basename "${0}"`
	exit

