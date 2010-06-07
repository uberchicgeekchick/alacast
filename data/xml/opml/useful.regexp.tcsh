#!/bin/tcsh
#	Stripping an rss or atom xml document; leaving only certain elements:
#		( also a great example of vim's: [NO match] regexp )
#		
#		'+1,$s/\v\r\_$//' '+1,$s/\v^\ +//' '+1,$s/\v^\t+//' '+1,$s/\n//' '+1s/\v\>\</\>\r\</g'
#		'+1,$s/\v^\<(item|entry|title|description|pubDate|enclosure|\/item|\/entry)@!.*\>.*\n//'
#		'+1,$s/\n//' '+1s/\v(\<)(item|entry)[^>]*(\>)/\r\1\2\3/g' '2,$s//wget/'
#		'+2,$s/\v\>\</\>\r\t\</g' '+1,$s/\v^\t(\<\/)(item|entry).*(\>).*/\t\1\2\3/'
#		
#		E.G. leaves only <item> or <entry>, <title>, <description>, <enclosure>, and <guid> elements.
#
#-----------------------------------------------------------------------------------
#	An example of the above with 'ex':
#		ex -s '+set ff=unix' '+1,$s/\v\r\_$//' '+1,$s/\v^ +//' '+1,$s/\v^\t+//' '+1,$s/\v\n//' '+1s/\v\>\</\>\r\</g' '+1,$s/\v\<(item|entry|title|description|pubDate|enclosure|\/item|\/entry)@'\!'.*\>.*\>\n//' '+1,$s/\v\n//' '+1s/\v(\<)(item|entry)[^>]*(\>)/\r\1\2\3/' '+1s/\v\>\</\>\r\t\</g' '+1,$s/\v^\t(\<\/)(item|entry).*(\>).*\n/\1\2\3/' '+wq!' "feed.xml";
#	
#-----------------------------------------------------------------------------------
#	Transforms an rss or atom xml doc into a wget script:
#		ex -s '+set ff=unix' '+1,$s/\v\r\_$//' '+1,$s/\v^ +//' '+1,$s/\v^\t+//' '+1,$s/\v\n//' '+1s/\v\>\</\>\r\</g' '+1,$s/\v\<(item|entry|title|pubDate|enclosure|\/item|\/entry)@'\!'.*\>.*\>\n//' '+1,$s/\v\n//' '+1s/\v(\<)(item|entry)[^>]*(\>)/\r\1\2\3/g' '+wq!' "feed.xml";
#		ex -s '+set ff=unix' '+1,$s/\v\r\_$//' '+1,$s/\v^ +//' '+1,$s/\v^\t+//' '+1,$s/\v\n//' '+1s/\v\>\</\>\r\</g' '+1,$s/\v\<(item|entry|title|pubDate|enclosure|\/item|\/entry)@'\!'.*\>.*\>\n//' '+1,$s/\v\n//' '+1s/\v(\<)(item|entry)[^>]*(\>)/\r\1\2\3/g' '+2,$s/\v^\<(item|entry)\>\n?\t?\<title\>([^<]+)\<\/title\>\n?\t?\<pubDate\>([^<]*)\<.*\\n?\t?<enclosure.*(url|href)\="(.*)(\.[^."?]+)(\??[^"]*)".*\n?\<\/(item|entry)\>/wget -O "\2, released on: \3\6" "\5\6\7";/' '+2,$s/\v^\<\/(item|entry)\>\n?\t?\<title\>([^<]+)\<\/title\>\n?\t?\<enclosure.*(url|href)\="(.*)(\.[^."?]+)(\??[^"]*)".*\n?\t?\<pubDate\>([^<]*)\<.*\n?\<\/(item|entry)\>/wget -O "\2, released on: \7\5" "\4\5\6";/' '+wq!' "feed.xml";
#	
#	This is optional and only useful to make the feed more readable:
#		ex -s '+1s/\v\>\</\>\r\t\</g' '+1,$s/\v^\t(\<\/)(item|entry).*(\>).*$/\1\2\3/' '+wq!' "feed.xml";
#	
#	Or for a podcast novel, audio drama, or podiobook with chapter/episode numbers but no pubDates:
#		'+1,$s/\v^\<(item|entry)\>\n?\t?<title\>([^0-9]+ )([0-9]+)\<\/title\>\n?\t?.*<enclosure.*(url|href)\="(.*)(\.[^."?]+)(\??[^"]*)".*\n?\<(item|entry)\>/wget -O "\1\- Episode \2\5" "\4\5\6";'/
#	
#	w/pubDates:
#		ex -s '+1,$s/\v^\<(item|entry)\>\n?\t?\<title\>([^<]+)\<\/title\>\n?\t?\<pubDate\>([^<]*)\<.*\n?\t?\<enclosure.*(url|href)\="(.*)(\.[^."?]+)(\??[^"]*)".*\n?\<\/(item|entry)\>/wget -O "\2, released on: \3\6" "\5\6\7";/' '+wq!' "feed.xml";
#		ex -s '+1,$s/\v^\<\/(item|entry)\>\n?\t?\<title\>([^<]+)\<\/title\>\n?\t?\<enclosure (url|href)\="(.*)(\.[^."?]+)(\??[^"]*)".*\n?\t?\<pubDate\>([^<]*)\<.*\n?\<\/(item|entry)\>/wget -O "\2, released on: \7\5" "\4\5\6";/' '+wq!' "feed.xml";
#		ex -s '+1,$s/\v^\<(item|entry)\>\n?\t?\<title\>([^<]+)\<\/title\>\n?\t?\<enclosure.*(url|href)\="(.*)(\.[^."?]+)(\??[^"]*)".*\n?\<\/(item|entry)\>/wget -O "\2\5" "\4\5\6";/' '+wq!' "feed.xml";
#	
#	This cleans up any remaining <entry>s, or <item>s, that don't have any associated enclosures:
#		ex -s '+1,$s/\v\n\<(item|entry)\>.*\n?\t?.*\n?\t?.*\n?\<\/(item|entry)\>//' '+wq!' "feed.xml";
#
#-----------------------------------------------------------------------------------
#	Removing empty lines:
#		'+1,$s/\v\r\_$//g' '+1,$s/\v\n*[ \t]*//g'
#
#-----------------------------------------------------------------------------------
#	Converts DOS/Mac newlines to UNIX:
#		ex -s '+set ff=unix' '+1,$s/\v\r\n?\_$/\r/g' '+wq!' "file";
#
#-----------------------------------------------------------------------------------
#	URL encoding CDATA:
#		1,$s/'/\&apos;/g
#		1,$s/"/\&quot;/g
#		1,$s/& /\&amp; /g
#		1,$s/\v([a-z][\?\.\!])[ ]*([A-Z])/\1\&nbsp;\ \2/ig
#
#-----------------------------------------------------------------------------------
#	Reordering <outline/> attributes:
#		1,$s/^\([\t]\+\)\(<outline \)\(.*\)\(title='[^']\+' \)\(.*\)$/\1\2\4\3\5/g
#		1,$s/^\([\t]\+<outline \)\(.*\)\(htmlUrl='[^']*' \)\(.*\)\(description='[^']*'\/>\)$/\1\2\4\3\5/g
#		1,$s/^\([\t]\+<outline title='[^']*'\)\(.*\)\( type='rss'\)\(.*\)\( xmlUrl='[^']*'\)\(.*\)$/\1\5\3\2\4\5\6/g
#
#-----------------------------------------------------------------------------------
#	Adding CDATA padding to outlines:
#		1,$s/\v(title|text|description)(\=")(\<\!\[CDATA\[)@!([^"]+)(\]\]\>)@!(")/\1\2\<\!\[CDATA\[\3\4\]\]\>\6/g
#
#	Fixing quotes inside of titles, texts, and descriptions:
#		1,$s/\v(title|text|description)(\="\<\!\[CDATA\[[^"\]]+)"([^\]]+\]\]>")/\1\2\&quot;\3/g
#
#-----------------------------------------------------------------------------------
#	Auto-format podiobooks.com search result <tr> into opml outline(s):
#		1,$s/\v\<tr class\="(even|odd)row.*.*href\=\"\/(title\/[^"]+)\"\>([^<]+)\<\/a\>.*\<span class\="smalltext"\>([^\<]+)\<\/class\>\<\/td\>\<td\>(.*)\<br\/\>.*\<\/tr\>\t*\n*/\t\t\<outline title\="\<\!\[CDATA\[\3\]\]\>" xmlUrl\="http:\/\/www\.podiobooks\.com\/\2\/feed\/\"\ type\="rss" text\="\<\!\[CDATA\[\3 \- A free audiobook by \4\]\]\>" htmlUrl\="http:\/\/www\.podiobooks\.com\/\2\/" description\="\<\!\[CDATA\[\<h1\>\3 by \4\<\/h1\>\<p>\5\<\/p\>\]\]\>"\ \/>\r/
#	
#	A set of ex command to convert any podiobooks.com/podiobooks/search.php results page:
#		ex -s "+1,`/bin/grep --line-number 'tableheader' "\""${opml}.swp"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`d" '+wq!' "${opml}.swp";
#		
#		ex -s "+`/bin/grep --line-number '<\/table>' "\""${opml}.swp"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`,"\$"d" '+wq!' "${opml}.swp";
#		
#		ex -s '+1,$s/\v\r\_$//g' '+1,$s/\v\n//g' '+1,$s/\v\t*(\<tr)/\r\1/g' '+1,$s/\v(\<\/tr\>)\t*/\1\r/g' '+1,2d' '+1,$s/"/'\''/g' '+1,$s/\v\<tr class\='\''(even|odd)row.*.*href\='\''\/(title\/[^'\'']+)'\''\>([^<]+)\<\/a\>.*\<span class\='\''smalltext'\''\>([^\<]+)\<\/class\>\<\/td\>\<td\>(.*)\<br\/\>.*\<\/tr\>\t*\n*/\t\t\<outline title\="\<\!\[CDATA\[\3\]\]\>" xmlUrl\="http:\/\/www\.podiobooks\.com\/\2\/feed\/\"\ type\="rss" text\="\<\!\[CDATA\[\3 \- A free audiobook by \4\]\]\>" htmlUrl\="http:\/\/www\.podiobooks\.com\/\2\/" description\="\<\!\[CDATA\[\<h1\>\3 by \4\<\/h1\>\<p>\5\<\/p\>\]\]\>"\ \/>\r/' '+$d' '+wq!' "${opml}.swp";
#		
#		printf "<?xml version="\""1.0"\"" encoding="\""UTF-8"\""?>\n<opml version="\""2.0"\"">\n\t<head>\n\t\t<title>\n\t\t\t${title} podcast novels &ndash; prensented by: podiobooks.com\n\t\t</title>\n\t</head>\n\t<body>\n\t</body>\n</opml>\n" >! "${opml}";
#		
#		ex -s "+8r `printf "\""${opml}.swp"\"" | sed -r 's/(["\"\$\!"'\''\[\]\(\)\ \<\>])/\\\1/g'`" "+${validate}" "${opml}";
#
#-----------------------------------------------------------------------------------
#	Auto-formatting an RSS' channel & info into an opml <outline>:
#		For podiobooks.com feeds:
#			3s/\v\<channel\>\r*\n*.*title\>(.+)(\ \-\ .*)(by\ [^\<]+)\<.*\r*\n*.*link\>([^\<]*)\<.*\r*\n*.*href\="([^"]*)".*\r*\n*.*(description)\>([^:]*:[ ]*)?(.*)\<\/description\>.*/\r\t\t\<outline title\=\"\<\!\[CDATA\[\1\]\]\>\"\ xmlUrl\=\"\5\/\"\ type=\"rss\"\ text\=\"\<\!\[CDATA\[\1\2\3\]\]\]\>\"\ htmlUrl\=\"\4\/\"\ \6=\"\<\!\[CDATA\[\<h1\>\1\<\/h1\>\<h3\>\3\<\/h3\>\<p\>\8\<\/p\>\]\]\>\"\ \/\>/ig
#
#-----------------------------------------------------------------------------------
#		For all others:
#			<link> before <atom:link href="{xmlUrl}">:
#				s/\v\<channel\>[\r\n]+.*title\>(\<\!\[CDATA\[)?([^\<]*)(\]\]\>)?\<.*[\r\n]+.*link\>([^\<]*)\<.*[\r\n]+.*href\="([^"]*)".*[\r\n]+.*(description)\>(\<\!\[CDATA\[)?([^\<\]]+)(\]\]\>)?\<.*/\r\t\t\<outline title="\<\!\[CDATA\[\2\]\]\>" xmlUrl="\5" type="rss" text="\<\!\[CDATA\[\2\]\]\>" htmlUrl="\4" \6="\<\!\[CDATA\[\8\]\]\>" \/\>/
#			<atom:link href="{xmlUrl}"> before <link>:
#				s/\v\<channel\>[\r\n]+.*title\>(\<\!\[CDATA\[)?([^\<]*)(\]\]\>)?\<.*[\r\n]+.*href\="([^"]*)".*[\r\n]+.*link\>([^\<]*)\<.*[\r\n]+.*(description)\>(\<\!\[CDATA\[)?([^\<\]]+)(\]\]\>)?\<.*/\r\t\t\<outline title="\<\!\[CDATA\[\2\]\]\>" xmlUrl="\4" type="rss" text="\<\!\[CDATA\[\2\]\]\>" htmlUrl="\5" \6="\<\!\[CDATA\[\8\]\]\>" \/\>/
#
#		NOTE: be sure to add a line for, or move, the xmlUrl to the line after RSS's: <link>{htmlUrl}</link> element.
#		Usually its:
#			<atom10:link href="{xmlUrl}" rel="self" type="application/rss+xml" />
#		But could be as simply as adding:
#			<href="{xmlUrl}">
#
#-----------------------------------------------------------------------------------
#	Finding a feed's interal atom/rss link:
#		s/\v\<atom(10)?:link[^\>]+(href\=\"[^\"]+\")([^\>]+\>).*$/\<atom10:link \2\3/
#
#-----------------------------------------------------------------------------------
#
#
