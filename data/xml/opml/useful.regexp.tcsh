#!/bin/tcsh
#	Stripping an xml document; leaving only certain elements:
#		( also a great example of vim's: [NO match] regexp )
#		
#		'+1,$s/\v\r\_$//' '+1,$s/\n//' '+1,$s/\v\>\</\>\r\</g'
#		'+1,$s/\v^[\ \t]*\<(title|description|pubDate|enclosure)@!.*\>.*\n//'
#		
#		E.G. leaves only <title>, <description>, and <guid> elements.
#
#	An exampl of the same but with 'ex':
#		ex -s '+set ff=unix' '+1,$s/\v\r\_$//' '+1,$s/\v^\ +//' '+1,$s/\v^\t+//' '+1,$s/\v\n//' '+1s/\v\>\</\>\r\</g' '+1,$s/\v\<(title|description|pubDate|enclosure)@'\!'.*\>.*\>\n//' '+1,$s/\v^\<[^>]+\>\n//' '+wq!' "feed0.xml"; vi feed0.xml
#
#-----------------------------------------------------------------------------------
#	Transforms the above xml doc into a wget script:
#		'+1,$s/\v\<title\>([^0-9]+ )([0-9]+)\<\/title\>\n.*\n.*\n\<enclosure (url|href)\="(.*)(\.[^."]+)".*/wget -O "\1\- Episode \2\5" "\4\5";'
#		'+1,$s/\v\<title\>([^<]+)\<\/title\>\n.*\n.*\n\<enclosure (url|href)\="(.*)(\.[^."]+)".*/wget -O "\1\4" "\3\4";'
#
#-----------------------------------------------------------------------------------
#	Removing empty lines:
#		'+1,$s/\v\r\_$//g' '+1,$s/\v\n*[\ \t]*//g'
#
#-----------------------------------------------------------------------------------
#	Converts DOS newlines to UNIX:
#	ex -s '+set ff=unix' "+0r file" '+1,$s/\v\r\n?\_$//g' "+w! file" '+q';
#
#-----------------------------------------------------------------------------------
#	URL encoding CDATA:
#		1,$s/"/\&quot;/g
#		1,$s/'/\&apos;/g
#		1,$s/& /\&amp; /g
#		1,$s/\v([a-z][\?\.\!])[\ ]*([A-Z])/\1\&nbsp;\ \2/ig
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
#		1,$s/\(title\|text\|description\)\(="<!\[CDATA\[[^"\]]\+\)"\([^\]]\+\]\]>"\)/\1\2\&quot;\3/g
#
#-----------------------------------------------------------------------------------
#	Auto-format podiobooks.com search result <tr> into opml outline(s):
#		1,$s/\v\<tr class\="(even|odd)row.*.*href\=\"(\/title\/[^"]+)\"\>\<img.*alt\=\"([^"]+)\".*\<span class\="smalltext"\>([^\<]+)\<\/class\>\<\/td\>\<td\>(.*)\<br\/\>.*\<\/tr\>\t*\n*/\t\t\<outline title\="\<\!\[CDATA\[\3\]\]\>" xmlUrl\="http:\/\/www\.podiobooks\.com\/\2\/feed\/\"\ type\="rss" text\="\<\!\[CDATA\[\3 \- A free audiobook by \4\]\]\>" htmlUrl\="http:\/\/www\.podiobooks\.com\/\2\/" description\="\<\!\[CDATA\[\<h1\>\3 by \4\<\/h1\>\<p>\5\<\/p\>\]\]\>"\ \/>\r/
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
