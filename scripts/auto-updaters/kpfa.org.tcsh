#!/bin/tcsh -f
init:
	if(! ${?0} ) then
		printf "This script cannot be sourced.\n" > /dev/stderr;
		exit -1;
	endif
	
	set scripts_dir="`dirname "\""${0}"\""`/../../data/xml/opml/radiocasts/`basename "\""${0}"\"" | sed -r 's/^(.*)\.tcsh"\$"/\1/'`";
	if(! -d "${scripts_dir}" ) \
		mkdir -vp "${scripts_dir}";
	cd "${scripts_dir}";
	
	alias "wget" "wget --no-check-certificate --quiet";
	alias "ex" "ex -E -n -X --noplugin";
#init:


update_index_opml:
	if( -e "index.opml.tmp" ) \
		rm "index.opml.tmp";
	
	printf "\nDownloading KPFA's latest podcasts";
	wget -O 'index.opml.tmp' 'http://kpfa.org/podcasts/';
	printf "\t[done]\n";
	
	
	# these regex's will make sure that each catagory is placed on one line for each catagory.
	printf "\nConverting KPFA's latest podcasts xhtml into opml";
	ex -s "+1,`/bin/grep --line-number -P 'view-content view-content-podcast-directory' 'index.opml.tmp' | sed -r 's/^([0-9]+):.*"\$"/\1/'`d" '+wq!' "index.opml.tmp";
	ex -s "+`/bin/grep --line-number -P '\<\/div\>\<\/div\>' 'index.opml.tmp' | sed -r 's/^([0-9]+):.*"\$"/\1/'`,"\$"d" '+wq!' "index.opml.tmp";
	ex '+1,$s/\v^[ \t]*//g' '+1,$s/\v\r\_$//' '+1,$s/\v\n//g' '+1s/\v\>[ \t]+\</\>\</g' '+1s/"/'\''/g' '+1s/\v\<div id\='\''node\-[0-9]+'\'' class\='\''node'\''\>/\r&/g' '+1d' '+wq!' 'index.opml.tmp' > /dev/null;
	ex '+1,$s/\v.*\<h2[^>]+\>\<a href\='\''([^'\'']+)'\'' title\='\''([^'\'']+)'\''\>([^<]+)\<\/a\>\<\/h2\>.*(\<p\>.*\<\/p\>).*(\<ul\>.*\<\/ul\>).*Subscribe to this show'\''s podcast:\<br \/\>\<input[^>]*value\='\''([^'\'']+)'\''[^>]+\>.*$/\t\t\<outline title\="\<\!\[CDATA\[\2\]\]\>" xmlUrl\="\6" type\="rss" text\="\<\!\[CDATA\[\3\]\]\>" htmlUrl\="http:\/\/kpfa\.org\1" description\="\<\!\[CDATA\[\4\5\]\]\>" \/\>/' '+wq!' "index.opml.tmp" > /dev/null;
	ex '+1,$s/\v.*\<h2[^>]+\>\<a href\='\''([^'\'']+)'\'' title\='\''([^'\'']+)'\''\>([^<]+)\<\/a\>\<\/h2\>.*(\<ul\>.*\<\/ul\>).*Subscribe to this show'\''s podcast:\<br \/\>\<input[^>]*value\='\''([^'\'']+)'\''[^>]+\>.*$/\t\t\<outline title\="\<\!\[CDATA\[\2\]\]\>" xmlUrl\="\5" type\="rss" text\="\<\!\[CDATA\[\3\]\]\>" htmlUrl\="http:\/\/kpfa\.org\1" description\="\<\!\[CDATA\[\4\]\]\>" \/\>/' '+wq!' "index.opml.tmp" > /dev/null;
	
	ex '+1,$s/\v(\<a href\='\'')\//\1http:\/\/www\.kpfa\.org\//g' "+1,"\$"s/\v ?style\='[^']+'//g" '+wq!' "index.opml.tmp" > /dev/null;
	while( `/bin/grep -c -P "(\<a href\='http:\/\/[^']+)\.([a-z]{2,5})'" "index.opml.tmp"` > 0 )
		ex "+1,"\$"s/\v(\<a href\='http:\/\/[^']+)\.([a-z]{2,5})'/\1\.\2\/'/g" '+wq!' "index.opml.tmp";
	end
	printf "\t[conversion complete]\n";
	
	
	printf "\nFinalizing KPFA's OPML <file://%s/index.opml>" "${cwd}";
	if( -e "index.opml" )	\
		rm "index.opml";
	printf '<?xml version="1.0" encoding="UTF-8"?>\n<opml version="2.0">\n\t<head>\n\t\t<title>KPFA'\''s podcasts</title>\n\t</head>\n\t<body>\n' >! 'index.opml';
	ex '+6r index.opml.tmp' '+wq!' 'index.opml' > /dev/null;
	printf '\t</body>\n</opml>\n' >> 'index.opml';
	rm "index.opml.tmp";
	printf "\t[finished]\n";
#goto update_index_opml;


