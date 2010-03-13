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
#		1,$s/\(title\|text\|description\)\(="<!\[CDATA\[[^'\]]\+\)'\([^\]]\+\]\]>"\)/\1\2\&apos;\3/g
#	
#	Auto-formatting an RSS' channel & info into an opml <outline>:
#		For podiobooks.com feeds:
#			3s/\v\<channel\>\n.*title\>(.*)(audiobook)([^\<]+)\<.*\n.*link\>([^\<]*)\<.*\n.*href\="([^"]*)".*\n.*(description)\>In this podiobook: ([^\<]+)\<.*/\r\t\t\<outline title="\<\!\[CDATA\[\1podcast novel\3\]\]\>" xmlUrl="\5\/" type="rss" text="\<\!\[CDATA\[\1\2\3\]\]\>" htmlUrl="\4\/" \6="\<\!\[CDATA\[\7\]\]\>" \/\>/
#		For all others:
#		3s/\v\<channel\>\n.*title\>([^\<]*)\<.*\n.*link\>([^\<]*)\<.*\n.*href\="([^"]*)".*\n.*(description)\>([^\<]+)\<.*/\r\t\t\<outline title="\<\!\[CDATA\[\1\]\]\>" xmlUrl="\3\/" type="rss" text="\<\!\[CDATA\[\1\]\]\>" htmlUrl="\2\/" \4="\<\!\[CDATA\[\5\]\]\>" \/\>
#
#
