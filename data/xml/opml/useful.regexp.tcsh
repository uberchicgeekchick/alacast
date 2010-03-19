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
#			3s/\v\<channel\>[\r\n]+.*title\>(.*)(audiobook)([^\<]+)\<.*[\r\n]+.*link\>([^\<]*)\<.*[\r\n]+.*href\="([^"]*)".*[\r\n]+.*(description)\>In this podiobook: ([^\<]+)\<.*/\r\t\t\<outline title="\<\!\[CDATA\[\1podcast novel\3\]\]\>" xmlUrl="\5\/" type="rss" text="\<\!\[CDATA\[\1\2\3\]\]\>" htmlUrl="\4\/" \6="\<\!\[CDATA\[\7\]\]\>" \/\>/
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
