#!/bin/tcsh -f
if ( "${?1}" == "0" || "${1}" == "" || "${1}" == "--help" ) goto usage

cd `dirname "${0}"`/../../data/xml/opml
source set_catalogs.tcsh

set attrib
set value
set searching_list

while ( "${?1}" != "" && "${1}" != "" )
	set attrib = "`printf '${1}' | sed 's/\-\-\([^=]\+\)=\(.*\)/\1/g'`"
	set value = "`printf '${1}' | sed 's/\-\-\([^=]\+\)=\(.*\)/\2/g'`"
	if ( "${?searching_list}" == "1" ) unset searching_list
	switch ( "${attrib}" )
	case "title":
	case "xmlUrl":
	case "htmlUrl":
	case "text":
	case "description":
		breaksw
	default:
		set attrib = "title"
		set value = "${1}"
		breaksw
	endsw
	if ( -e "${value}" ) set searching_list = "${value}"
	
	shift
	
	set show_attribute = ""
	switch ( "${2}" )
	case "--show=title":
	case "--show=htmlUrl":
	case "--show=text":
	case "--show=description":
		shift
		set show_attribute = "`printf '${2}' | sed 's/\-\-\([^=]\+\)=\(.*\)/\2/g'`"
		breaksw
	case "--show=xmlUrl":
		shift
	default:
		set show_attribute = "xmlUrl"
		breaksw
	endsw
	
	
	foreach catalog ( ${catalogs} )
		if ( "${?searching_list}" == "1" ) then
			foreach value ( "`cat '${searching_list}'`" )
				foreach opml_and_outline ( "`/usr/bin/grep --binary-files=without-match --with-filename -ri --perl-regex -e '^[\t\ ]+<outline.*${attrib}=["\""'\''].*${value}.*["\""'\'']' '${catalog}'`" )
				printf "%s" "${opml_and_outline}" | sed "s/.*${show_attribute}=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/"
				printf ": "
				printf "%s" "${opml_and_outline}" | cut -d':' -f1
				printf "\n"
			end
			continue
		endif
		
		foreach opml_and_outline ( "`/usr/bin/grep --binary-files=without-match --with-filename -ri --perl-regex -e '^[\t\ ]+<outline.*${attrib}=["\""'\''].*${value}.*["\""'\'']' '${catalog}'`" )
			printf "%s" "${opml_and_outline}" | sed "s/.*${show_attribute}=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/"
			printf ": "
			printf "%s" "${opml_and_outline}" | cut -d':' -f1
			printf "\n"
		end
	end
end

	exit

	usage:
		printf "Usage:\n\t %s [--title|(default)xmlUrl|htmlUrl|text|description]=]search_term or path to file containing search terms(one per line.) [--show=attribute-to-display. default: xmlUrl]\n\t\tBoth of these options may be repeated multiple times together or only multiple uses of the first argument.  Lastly multiple terms, or files using terms \n" `basename "${0}"`
		exit

