#!/bin/tcsh
#	Fixing my old, non-array based single rss listing & adding initial tag support:
#		1,$s/['"]rss['"]\s\?=>\s\?['"]\([^'"]*\)['"],\?/'rss'=>array(\r\t\t\t\t'default'=>"\1",\r\t\t\t),\r\t\t\t'tags'=>"",/
#
#	Removing padding around array value assignments:
#		1,$s/\s=>\s/=>/
#	
#	Adding initial 'tags' support:
#		1,$s/\('rss.*\n.*\n[^)]*),\)/\1\r\t\t\t'tags'=>"",/
#
#	Removing empty lines:
#		1,$s/^[\t\s]*[\n\r]\+//
#
#	Fixing feedburner's URIs:
#		This forces feedburner urls to display the feed's XML:
#			1,$s/\(http:\/\/feeds\.[^\/]\+\/\)\([^?]\+\)\([^"]\+\)\(",\)/\1\2\3?format=xml\4/g
#
#		1,$s/\(http:\/\/feeds\.[^\/]\+\/\)\([^\/?]\+\)\/\?\(?[^"]\+\)/\1\2\3/g
#
#	Coverting OPMLs to PHP Array:
#		s/^.*title=\('[^']\+'\).*xmlUrl='\([^']\+\)'.*htmlUrl='\([^']\+\)'.*/\t\t\1=>array(\r\t\t\t'www'=>"\3",\r\t\t\t'rss'=>array(\r\t\t\t\t"\2",\r\t\t\t),\r\t\t),/
#
