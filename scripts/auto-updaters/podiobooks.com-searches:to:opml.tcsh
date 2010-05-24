#!/bin/tcsh -f
if(! ${?0} ) then
	printf "This script cannot be sourced.\n" > /dev/stderr;
	exit -1;
endif

set author="${1}";
set opml="data/xml/opml/library/authors/`printf "\""${author}"\"" | sed -r 's/([^\ ]+)/\L\1/g'`.opml";
set author="Steve Simons";

#wget -O "$yopml}" "http://www.podiobooks.com/podiobooks/search.php?keyword=`printf "\""${author}"\"" | sed -r 's/\ /\+/g'`";

ex -s "+1,`/bin/grep --line-number 'tableheader' data/xml/opml/library/authors/steve-simons.opml | sed -r 's/^([0-9]+).*"\$"/\1/'`d" '+wq!' "${opml}";

ex -s "+`/bin/grep --line-number '<\/table>' data/xml/opml/library/authors/steve-simons.opml | sed -r 's/^([0-9]+).*"\$"/\1/'`,"\$"d" '+wq!' "${opml}";

ex -s '+1,$s/\v\r\_$//g' '+1,$s/\v\n//g' '+1,$s/\v\t*(\<tr)/\r\1/g' '+1,$s/\v(\<\/tr\>)\t*/\1\r/g' '+1,2d' '+1,$s/\v\<tr class\="(even|odd)row.*.*href\=\"(\/title\/[^"]+)\"\>\<img.*alt\=\"([^"]+)\".*\<span class\="smalltext"\>([^\<]+)\<\/class\>\<\/td\>\<td\>(.*)\<br\/\>.*\<\/tr\>\t*\n*/\t\t\<outline title\="\<\!\[CDATA\[\3\]\]\>" xmlUrl\="http:\/\/www\.podiobooks\.com\/\2\/feed\/\"\ type\="rss" text\="\<\!\[CDATA\[\3 \- A free audiobook by \4\]\]\>" htmlUrl\="http:\/\/www\.podiobooks\.com\/\2\/" description\="\<\!\[CDATA\[\<h1\>\3 by \4\<\/h1\>\<p>\5\<\/p\>\]\]\>"\ \/>\r/' '+wq!' "${opml}";

printf "<opml version="\""2.0"\"">\n\t<head>\n\t\t<title>\n\t\t\t${author}&appos;" >! "${opml}.swp";
if( "`printf "\"""\"" | sed -r 's/^.*(.)"\$"/\L\1/'`" != "s" ) \
	printf "s" >> "${opml}.swp";
printf "podcast novels &ndash; prensented by: podiobooks.com\n\t\t</title>\n\t</head>\n\t<body>" >> "${opml}.swp";

ex -s "+9r `printf "\""${opml}"\"" | sed -r 's/([\ ])/\\\1/g'`" 'wq!' "${opml}.swp";

printf "\t</body>\n</opml>\n\n" >> "${opml}.swp";

mv -f "${opml}.swp" "${opml}";




