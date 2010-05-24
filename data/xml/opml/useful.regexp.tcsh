#!/bin/tcsh
#	Removing empty lines:
#		1,$s/^[\ \t\s]*[\n\r]\+//
#
#	URL encoding CDATA:
#		1,$s/"/\&quot;/g
#		1,$s/'/\&#039;/g
#		1,$s/\.[\ ]\{1,2\}/\.\&nbsp;\ /g
#
#	Reordering <outline/> attributes:
#		1,$s/^\([\t]\+\)\(<outline \)\(.*\)\(title='[^']\+' \)\(.*\)$/\1\2\4\3\5/g
#		1,$s/^\([\t]\+<outline \)\(.*\)\(htmlUrl='[^']*' \)\(.*\)\(description='[^']*'\/>\)$/\1\2\4\3\5/g
#		1,$s/^\([\t]\+<outline title='[^']*'\)\(.*\)\( type='rss'\)\(.*\)\( xmlUrl='[^']*'\)\(.*\)$/\1\5\3\2\4\5\6/g
#
#	Adding CDATA padding to outlines:
#		1,$s/\v(title|text|description)(\=")(\<\!\[CDATA\[)@!([^"]+)(\]\]\>)@!(")/\1\2\<\!\[CDATA\[\3\4\]\]\>\6/g
#
#	Fixing quotes inside of titles, texts, and descriptions:
#		1,$s/\(title\|text\|description\)\(="<!\[CDATA\[[^"\]]\+\)"\([^\]]\+\]\]>"\)/\1\2\&quot;\3/g
#
#	Auto-format podiobooks.com search result <tr> into opml outline(s):
#		1,$s/\v\<tr class\="(even|odd)row.*.*href\=\"(\/title\/[^"]+)\"\>\<img.*alt\=\"([^"]+)\".*\<span class\="smalltext"\>([^\<]+)\<\/class\>\<\/td\>\<td\>(.*)\<br\/\>.*\<\/tr\>\t*\n*/\t\t\<outline title\="\<\!\[CDATA\[\3\]\]\>" xmlUrl\="http:\/\/www\.podiobooks\.com\/\2\/feed\/\"\ type\="rss" text\="\<\!\[CDATA\[\3 \- A free audiobook by \4\]\]\>" htmlUrl\="http:\/\/www\.podiobooks\.com\/\2\/" description\="\<\!\[CDATA\[\<h1\>\3 by \4\<\/h1\>\<p>\5\<\/p\>\]\]\>"\ \/>\r/
#	
#	Auto-formatting an RSS' channel & info into an opml <outline>:
#		For podiobooks.com feeds:
#			3s/\v\<channel\>\r*\n*.*title\>(.+)(\ \-\ .*)(by\ [^\<]+)\<.*\r*\n*.*link\>([^\<]*)\<.*\r*\n*.*href\="([^"]*)".*\r*\n*.*(description)\>([^:]*:[ ]*)?(.*)\<\/description\>.*/\r\t\t\<outline title\=\"\<\!\[CDATA\[\1\]\]\>\"\ xmlUrl\=\"\5\/\"\ type=\"rss\"\ text\=\"\<\!\[CDATA\[\1\2\3\]\]\]\>\"\ htmlUrl\=\"\4\/\"\ \6=\"\<\!\[CDATA\[\<h1\>\1\<\/h1\>\<h3\>\3\<\/h3\>\<p\>\8\<\/p\>\]\]\>\"\ \/\>/ig
#
#		For all others:
#			<link> before <atom:link href="{xmlUrl}">:
#				s/\v\<channel\>[\r\n]+.*title\>(\<\!\[CDATA\[)?([^\<]*)(\]\]\>)?\<.*[\r\n]+.*link\>([^\<]*)\<.*[\r\n]+.*href\="([^"]*)".*[\r\n]+.*(description)\>(\<\!\[CDATA\[)?([^\<\]]+)(\]\]\>)?\<.*/\r\t\t\<outline title="\<\!\[CDATA\[\2\]\]\>" xmlUrl="\5" type="rss" text="\<\!\[CDATA\[\2\]\]\>" htmlUrl="\4" \6="\<\!\[CDATA\[\8\]\]\>" \/\>/
#			<atom:link href="{xmlUrl}"> before <link>:
#				s/\v\<channel\>[\r\n]+.*title\>(\<\!\[CDATA\[)?([^\<]*)(\]\]\>)?\<.*[\r\n]+.*href\="([^"]*)".*[\r\n]+.*link\>([^\<]*)\<.*[\r\n]+.*(description)\>(\<\!\[CDATA\[)?([^\<\]]+)(\]\]\>)?\<.*/\r\t\t\<outline title="\<\!\[CDATA\[\2\]\]\>" xmlUrl="\4" type="rss" text="\<\!\[CDATA\[\2\]\]\>" htmlUrl="\5" \6="\<\!\[CDATA\[\8\]\]\>" \/\>/
#
#		NOTE: be sure to add a line for, or move, the xmlUrl to the line after RSS's: <link>{htmlUrl}</link> element.
#		Usually its:
#			<atom:link href="{xmlUrl}" rel="self" type="application/rss+xml" />
#		But could be as simply as adding:
#			<href="{xmlUrl}">
#
