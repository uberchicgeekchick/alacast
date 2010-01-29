#!/bin/tcsh -f

set useUri="`printf '%s' '$argv[1]' | sed -r 's/(http)s?\:\/\//\1/'`";
if( "${useUri}" != "http" ) unset useUri;

set opml="`printf '%s' '$argv[1]' | sed -r 's/[^\.]\.(opml)/\1/'`";
if( "${opml}" != "opml" ) unset opml;

if(!( "$argv[1]" != "" && "$argv[1]" != "--help" )) goto usage;
if( ${?opml} && ! -e "$argv[1]" ) goto usage;
if(!( ${?useUri} || -d "$argv[1]" )) goto usage;


if( ${?useUri} ) 
foreach opml ( "`find '$argv[1]' -name '*.opml'`" )
	printf "Checking pubDates in: %s\n" $opml;
	set xmlUrls="`egrep '.*<outline.*.*xmlUrl="\""[^"\""]+"\"".*' $opml | sed 's/.*<outline.*xmlUrl="\""\([^"\""]\+\)"\"".*/"\""\1"\""\n/'`";
	set titles=`egrep '.*<outline.*.*title="\""[^"\""]+"\"".*' $opml | sed 's/.*<outline.*title="\""\([^"\""]\+\)"\"".*/\1/'| sed 's/<\!\[CDATA\[\(.*\)\]\]>/'\''\1'\''\n/'`;
	@ count=0;
	foreach xmlUrl ( ${xmlUrls} )
		printf "Checking pubDate of %s latest episode.\n" $titles[$count];
		if(!(-e "feed.xml")) then
			#wget -q -c -O "feed.xml"
			#ex -E '+1,$s/[\n\r]\+//g' '+s/#//g' '+s/<\/\(item\|entry\)\>/<\/\1>\r/g' '+$d' '+wq' "${podcasts_search_title}.xml" >& /dev/null;
		endif
		@ count++;
	end
end

usage:
	set this_script="`basename '$argv[0]'`";
	printf "Usage:\n\t%s [opml file] || [xmlUrl]\n%s check's a feed for its latest/most recent episode.\nIt checks for the episode buy downloding either:\n\tAll xmlUrl(s) listed in a specific opml.\n\t\t-or-\n\tor from the specified feed's URI.\n" "${this_script}" "${this_script}";
	unset this_script;
	evit -1;

