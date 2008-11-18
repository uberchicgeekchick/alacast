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
#	Converts PHP arrays to OPML items:
#		With 'info' tags:
#			1,$s/\('[^']\+'\)=>array([\r\n\t]\+'www'=>"\([^"]*\)"[,\r\n\t]\+'info'=>"\([^"]\+\)"[,\t\r\n]\+'rss'=>array([,\r\n\t]\+'default'=>"\([^"]*\)"[\t\r\n),]*'tags'=>"",[\t\r\n]*),\c/<outline title=\1 xmlUrl='\4' type='rss' text=\1 htmlUrl='\2' description='\3'\/>/g
#		Without 'info' tags:
#			1,$s/\('[^']\+'\)=>array([\r\n\t]\+'www'=>"\([^"]*\)"[,\r\n\t]\+'rss'=>array([,\r\n\t]\+'default'=>"\([^"]*\)"[\t\r\n),]*'tags'=>"",[\t\r\n]*),\c/<outline title=\1 xmlUrl='\3' type='rss' text=\1 htmlUrl='\2' description=''\/>/g
#
#	Reformating OPML outline entries to the order I prefer:
#		1,$s/^\([\t]*<outline\) \(title='[^']*'\) \(text='[^']*'\) \(htmlUrl='[^']*'\) \(xmlUrl='[^']*'\) \(type='rss'\) \(description='[^']*'\)\ \(\/>\)$/\1 \2 \5 \6 \3 \4 \6 \7\8/g
#
