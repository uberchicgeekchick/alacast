#!/bin/tcsh
#	Removing empty lines:
#		1,$s/^[\t\s]*[\n\r]\+//
#
#	URL encoding CDATA:
#		1,$s/"/\&quot;/g
#		1,$s/'/\&#039;/g
#		1,$s/\.[\ ]\{1,2\}/\.\&nbsp;\ /g
#
#	Reordering <outline/> 'title' to the front of the outline:
#		1,$s/^\([\t]\+\)\(<outline \)\(.*\)\(title='[^']\+' \)\(.*\)$/\1\2\4\3\5/g
#		1,$s/^\([\t]\+<outline \)\(.*\)\(htmlUrl='[^']*' \)\(.*\)\(description='[^']*'\/>\)$/\1\2\4\3\5/g
#		1,$s/^\([\t]\+<outline title='[^']*'\)\(.*\)\( type='rss'\)\(.*\)\( xmlUrl='[^']*'\)\(.*\)$/\1\5\3\2\4\5\6/g
#
#	Adding CDATA padding to outlines:
#		1,$s/\v(title|text|description)(\=')([^\<']*)([^\<']*)'/\1\2<![CDATA[\3\4]]>'/g