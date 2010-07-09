#!/bin/tcsh -f

if(! ${?0} ) then
	printf "This script cannot be sourced.\n" > /dev/stderr;
	exit -1;
endif

setup:
	set website="`basename "\""${0}"\"" | sed -r 's/^(.*)\.tcsh"\$"/\1/'`";
	set target_dir="`dirname "\""${0}"\""`/../../data/xml/opml/podcasts/technology/networks/${website}";
	set website="podcast.${website}";
	alias ex "ex -E -X -n --noplugin";
	#set target_dir="${website}";
#goto setup;

backup:	
	if(! -d "${target_dir}" ) then
		mkdir -p "${target_dir}";
	else
		if(! -d "${target_dir}/back-up" ) then
			mkdir "${target_dir}/back-up";
		cp -rf "${target_dir}/"*.opml "${target_dir}/back-up";
		rm "${target_dir}"/*.opml;
	endif
#goto backup;


get_podcasts:
	cd "${target_dir}";
	
	printf "Finding %s's Podcasts" "${website}";
	wget --quiet -O "index.xhtml" "http://${website}";
	ex -s '+1,$s/\v\>\</\>\r\</g' '+wq!' "index.xhtml";
	set urls=("${website}/podcasts/" "`/bin/grep -P '\<a href\="\""\/[a-z]*\-?podcasts\/"\""\>' index.xhtml | sed -r 's/<a href\="\""([^"\""]+)"\"">.*"\$"/${website}\1/'`");
	rm "index.xhtml";
	printf "\n\t\t\t\t\t\t\t\t\t\t[finished]\n";
#goto get_podcasts;


fetch_and_format_opmls:
	foreach url( ${urls} )
		set category="`basename "\""${url}"\"" | sed -r 's/([^\-]+)/\u\1/g' | sed -r 's/\-/\ /g'`";
		set opml="`basename "\""${url}"\""`.opml";
		
		printf "Downloading %s's %s" "${website}" "${category}";
		wget --quiet -O "${opml}" "${url}";
		printf "\n\t\t\t\t\t\t\t\t\t\t[finished]\n";
		
		printf "Preparing %s's %s OPML" "${website}" "${category}";
		set line_number_to_delete="`/bin/grep --line-number 'podcastTab' "\""${opml}"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`";
		set line_number_to_delete="`printf "\""${line_number_to_delete}-1\n"\"" | bc`";
		set opml_file_for_editor="`printf "\""${opml}.tmp"\"" | sed -r 's/(["\"\$\!"'\''\[\(\)\ \<\>])/\\\1/g'`";
		
		ex -s "+1,${line_number_to_delete}d" "+2,"\$"d" '+s/\v(\<div class\=\"podcastTab\"\>)/\r\t\t\1/g' '+$s/\v(\<\!\--podcastTab\-\-\>)/\1\r/' '+$d' '+1d' '+1,$s/"/'\''/g' "+1,"\$"s/\v(href\=')(\/[^']+')/\1http:\/\/${website}\2/" "+wq!" "${opml}";
		set lines=`wc -l "${opml}" | sed -r 's/^([0-9]+).*$/\1/'`;
		mv "${opml}" "${opml}.tmp";
		printf "\n\t\t\t\t\t\t\t\t\t\t[finished]\n";
		
		printf "Formating %s's %s OPML's audio podcasts feeds" "${website}" "${category}";
		ex -s "+"\$"r ${opml_file_for_editor}" '+wq!' "${opml}.swp";
		ex -s "+1,${lines}s/\v.*\<h2 class\='first'\>\<a[^>]+\>\<\/a\>\<a href\='([^']+)'[^>]*\>([^<]+)\<\/a\>\<\/h2\>.*\<div class\='desc'\>(.*) \<p class\='hosts'\>.*\<div class\='rss'\> \<a href\='([^']+)'[^>]*\>(RSS).*"\$"/\t\t\<outline title\="\""\<\!\[CDATA\[\2\]\]\>"\"" xmlUrl\="\""\4"\"" type="\""rss"\"" htmlUrl\="\""\1"\"" text\="\""\<\!\[CDATA\[\2\]\]\>"\"" description\="\""\<\!\[CDATA\[\<h1\>\2\&apos; audio podcast \5 feed\<\/h1\>\<p\>\3\<\/p\>\]\]\>"\"" \/\>/" '+wq!' "${opml}.swp";
		printf "\n\t\t\t\t\t\t\t\t\t\t[finished]\n";
		
		printf "Formating %s's %s OPML's video podcasts feeds" "${website}" "${category}";
		ex -s "+"\$"r ${opml_file_for_editor}" '+wq!' "${opml}.swp";
		ex -s "+`printf "\""${lines}+1\n"\"" | bc`,"\$"s/\v.*\<h2 class\='first'\>\<a[^>]+\>\<\/a\>\<a href\='([^']+)'[^>]*\>([^<]+)\<\/a\>\<\/h2\>.*\<div class\='desc'\>(.*) \<p class\='hosts'\>.*\<div class\='rss'\>.*\<a href\='([^']+)'[^>]*\>(RSS) \((video)\).*"\$"/\t\t\<outline title\="\""\<\!\[CDATA\[\2\]\]\>"\"" xmlUrl\="\""\4"\"" type="\""rss"\"" htmlUrl\="\""\1"\"" text\="\""\<\!\[CDATA\[\2\&apos; \6 podcast \5 feed\]\]\>"\"" description\="\""\<\!\[CDATA\[\<h1\>\2\&apos; \6 podcast \5 feed\<\/h1\>\<p\>\3\<\/p\>\]\]\>"\"" \/\>/" '+wq!' "${opml}.swp";
		ex -s "+1,"\$"s/\v^\t\t\<div class\='podcastTab'\>.*\n//" '+wq!' "${opml}.swp";
		printf "\n\t\t\t\t\t\t\t\t\t\t[finished]\n";
		
		printf "Formating %s's %s OPML's HD podcasts feeds" "${website}" "${category}";
		ex -s "+"\$"r ${opml_file_for_editor}" '+wq!' "${opml}.swp";
		ex -s "+`printf "\""${lines}+${lines}+2\n"\"" | bc`,"\$"s/\v.*\<h2 class\='first'\>\<a[^>]+\>\<\/a\>\<a href\='([^']+)'[^>]*\>([^<]+)\<\/a\>\<\/h2\>.*\<div class\='desc'\>(.*) \<p class\='hosts'\>.*\<div class\='rss'\>.*\<a href\='([^']+)'[^>]*\>(RSS) (HD).*"\$"/\t\t\<outline title\="\""\<\!\[CDATA\[\2\]\]\>"\"" xmlUrl\="\""\4"\"" type="\""rss"\"" htmlUrl\="\""\1"\"" text\="\""\<\!\[CDATA\[\2\&apos; \6 podcast \5 feed\]\]\>"\"" description\="\""\<\!\[CDATA\[\<h1\>\2\&apos; \6 podcast \5 feed\<\/h1\>\<p\>\3\<\/p\>\]\]\>"\"" \/\>/" '+wq!' "${opml}.swp";
		ex -s "+1,"\$"s/\v^\t\t\<div class\='podcastTab'\>.*\n//" '+wq!' "${opml}.swp";
		printf "\n\t\t\t\t\t\t\t\t\t\t[finished]\n";
		
		printf "Saving %s's %s OPML" "${website}" "${category}";
		mv -f "${opml}.swp" "${opml}.tmp";
		printf "<?xml version="\""1.0"\"" encoding="\""UTF-8"\""?>\n<opml version="\""2.0"\"">\n\t<head>\n\t\t<title>%s&apos;s %s</title>\n\t</head>\n\t<body>\n" "${website}" "${category}" >! "${opml}";
		
		ex -s "+"\$"r ${opml_file_for_editor}" '+wq!' "${opml}";
		rm "${opml}.tmp";
		
		printf "\t</body>\n</opml>\n" >> "${opml}";
		printf "\n\t\t\t\t\t\t\t\t\t\t[finished]\n\n";
	end
#goto fetch_and_format_opmls;


