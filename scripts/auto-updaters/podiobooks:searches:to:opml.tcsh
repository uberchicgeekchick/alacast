#!/bin/tcsh -f
if(! ${?0} ) then
	printf "This script cannot be sourced.\n" > /dev/stderr;
	exit -1;
endif

if( "${1}" == "--edit" || "${1}" == "--validate" ) then
	set validate;
	shift;
endif

if(!( "${1}" != "" && "${1}" != "--help" && "${2}" == "" )) then
	printf "Usage: %s "\""Author's name"\""\n";
	set status=-1;
	exit $status;
endif

alias	"wget"	"wget --no-check-certificate --continue --quiet";
alias	"ex"	"ex -E -n -X --noplugin";

set author="${1}";
set opml="`dirname "\""${0}"\""`/../../data/xml/opml/library/authors/`printf "\""${author}"\"" | sed -r 's/([^\ ]+)/\l\1/g' | sed -r 's/\ /\-/g'`.opml";

set display_name="${author}'";
set title="${author}&appos;";
if( "`printf "\""${author}"\"" | sed -r 's/^.*(.)"\$"/\l\1/'`" != "s" ) then
	set display_name="${title}s";
	set title="${title}s";
endif

printf "Downloading %s podcast novels" "${display_name}";
wget -O "${opml}.swp" "http://www.podiobooks.com/podiobooks/search.php?keyword=`printf "\""${author}"\"" | sed -r 's/\ /\+/g'`";
printf "\t[done]\n";

printf "Formating %s OPML" "${display_name}";
ex -s "+1,`/bin/grep --line-number 'tableheader' "\""${opml}.swp"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`d" '+wq!' "${opml}.swp";

ex -s "+`/bin/grep --line-number '<\/table>' "\""${opml}.swp"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`,"\$"d" '+wq!' "${opml}.swp";

ex -s '+1,$s/\v\r\_$//g' '+1,$s/\v\n//g' '+1,$s/\v\t*(\<tr)/\r\1/g' '+1,$s/\v(\<\/tr\>)\t*/\1\r/g' '+1,2d' '+1,$s/"/'\''/g' '+1,$s/\v\<tr class\='\''(even|odd)row.*.*href\=\'\''(\/title\/[^'\'']+)\'\''\>\<img.*alt\=\'\''([^'\'']+)\'\''.*\<span class\='\''smalltext'\''\>([^\<]+)\<\/class\>\<\/td\>\<td\>(.*)\<br\/\>.*\<\/tr\>\t*\n*/\t\t\<outline title\="\<\!\[CDATA\[\3\]\]\>" xmlUrl\="http:\/\/www\.podiobooks\.com\/\2\/feed\/\"\ type\="rss" text\="\<\!\[CDATA\[\3 \- A free audiobook by \4\]\]\>" htmlUrl\="http:\/\/www\.podiobooks\.com\/\2\/" description\="\<\!\[CDATA\[\<h1\>\3 by \4\<\/h1\>\<p>\5\<\/p\>\]\]\>"\ \/>\r/' '+$d' '+wq!' "${opml}.swp";
printf "\t[done]\n";

if(! -e "${opml}" ) then
	set new_opml;
	printf "Saving %s OPML" "${display_name}";
	printf "<?xml version="\""1.0"\"" encoding="\""UTF-8"\""?>\n<opml version="\""2.0"\"">\n\t<head>\n\t\t<title>\n\t\t\t${title} podcast novels &ndash; prensented by: podiobooks.com\n\t\t</title>\n\t</head>\n\t<body>\n\t</body>\n</opml>\n" >! "${opml}";
	set line=8;
else
	printf "Updatinging %s OPML" "${display_name}";
	set line="`/bin/grep --line-number '<\/body>' "\""${opml}"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`";
	if(!( "${line}" != "" && ${line} > 1 )) then
		set line=8;
	else
		set line="${line}-1";
	endif
endif

if(! ${?validate} ) then
	ex -s "+${line}r `printf "\""${opml}.swp"\"" | sed -r 's/([\ ])/\\\1/g'`" '+wq!' "${opml}";
else
	ex "+${line}r `printf "\""${opml}.swp"\"" | sed -r 's/([\ ])/\\\1/g'`" '+visual' "${opml}";
endif


rm -f "${opml}.swp";
printf "\t[done]\n\tSaved: <file://%s>\n" "${opml}";

