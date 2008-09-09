#!/bin/tcsh
#	Fixing my old, non-array based single rss listing &adding initial tag support:
#		1,$s/['"]rss['"]\s\?=>\s\?['"]\([^'"]*\)['"],\?/'rss'=>array(\r\t\t\t\t'default'=>"\1",\r\t\t\t),\r\t\t\t'tags'=>"",/
#
#	Adding initial 'tags' support:
#		1,$s/\('rss.*\n.*\n[^)]*),\)/\1\r\t\t\t'tags'=>"",/
#
#	Removing empty lines:
#		1,$s/^[\s\n\r]\+//
#
#	Fixing feedburner's URIs:
#		1,$s/\(http:\/\/feeds\.[^\/]\+\/\)\([^\/?]\+\)\/\?\(?[^"]\+\)/\1\2\3/
#

