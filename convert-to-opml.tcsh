#!/bin/tcsh -f
foreach list ( "`find podcast_arrays/ -name '*.php' -printf '%p\n'`" )
	echo $list
	vi '+1,$s/\('"'"'[^'"'"']\+'"'"'\)=>array([\t\r\n]\+'"'"'www'"'"'=>"\([^"]*\)"[,\t\r\n]\+'"'"'rss'"'"'=>array([\t\r\n]\+'"'"'default'"'"'=>"\([^"]*\)"[\t\r\n),]*'"'"'tags'"'"'=>"",[\t\r\n]*),\c/<outline title=\1 xmlUrl='"'"'\3'"'"' type='"'"'rss'"'"' text=\1 htmlUrl='"'"'\2'"'"' description='"''"'\/>/' "${list}"
end
