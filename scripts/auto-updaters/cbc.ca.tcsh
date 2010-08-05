#!/bin/tcsh -f

if(! ${?0} ) then
	printf "This script cannot be sourced.\n" > /dev/stderr;
	exit -1;
endif

setup:
	onintr exit_script;
	if( ${?GREP_OPTIONS} ) then
		set grep_options="${GREP_OPTIONS}";
		unsetenv GREP_OPTIONS;
	endif
	
	set website="`basename "\""${0}"\"" | sed -r 's/^(.*)\.tcsh"\$"/\1/'`";
	set target_dir="`dirname "\""${0}"\""`/../../data/xml/opml/radiocasts/${website}";
	set podcasting_path="/podcasting/";
	set podcasting_index="index.html";
	set podcasting_uri="http://${website}${podcasting_path}${podcasting_index}";
	set escaped_uri=`printf "%s" "${podcasting_uri}" | sed -r 's/([\/\\\(\[\.])/\\\1/g'`;
	alias ex "ex -E -X -n --noplugin";
#goto setup;


exit_script:
	if( ${?grep_options} ) then
		setenv GREP_OPTIONS "${grep_options}";
		unset grep_options;
	endif
	
	if( -e "index.xhtml" ) \
		rm -f "index.xhtml";
	
	if( ${?opml} ) then
		if( -e "${opml}.tmp" ) \
			rm -f "${opml}.tmp";
		
		if( -e "${opml}" ) \
			rm -f "${opml}";
	endif
#goto exit_script;


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
	wget --quiet -O "index.xhtml" "${podcasting_uri}";
	ex -s '+1,$s/\v\>\</\>\r\</g' '+wq!' "index.xhtml";
	set podcasting_categories=("`/bin/grep -P 'href="\""index\.html(\?[a-z]+)"\""' index.xhtml | sed -r 's/\&amp;/and/g' | sed -r 's/.*href="\""index\.html(\?[a-z]+)"\""[^>]*>(.+)<\/a>.*"\$"/\2\nhttp:\/\/cbc\.ca\/podcasting\/index\.html\1/g'`");
	printf "\n\t\t\t\t\t\t\t\t\t\t[finished]\n";
	rm -f "index.xhtml";
	@ podcasting_info_index=0;
#goto get_podcasts;


fetch_and_format_opmls:
	while( $podcasting_info_index < ${#podcasting_categories} )
		@ podcasting_info_index++;
		set category="$podcasting_categories[$podcasting_info_index]";
		@ podcasting_info_index++;
		set url="$podcasting_categories[$podcasting_info_index]";
		set opml="`printf "\""%s"\"" "\""${category}"\"" | sed -r 's/([^\-]+)/\L\1/g' | sed -r 's/ /\-/g'`.opml";
		
		printf "Downloading %s's %s" "${website}" "${category}";
		wget --quiet -O "${opml}" "${url}";
		printf "\n\t\t\t\t\t\t\t\t\t\t[finished]\n";
		
		
		
		printf "Preparing %s's %s OPML" "${website}" "${category}";
		ex -s '+1,$s/\v\r\_$//' '+1,$s/\v^[\t ]*//' '+1,$s/\v[ \t]\_$//' '+wq!' "${opml}";
		set line_number="`grep --line-number -P '\<\!\-\-start pod class.*tiles\-\-\>' "\""${opml}"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`";
		ex -s "+1,${line_number}d" '+wq!' "${opml}";
		set line_number="`grep --line-number -P '\<\!\-\-end pod class.*tiles\-\-\>' "\""${opml}"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`";
		ex -s "+${line_number},"\$"d" '+wq!' "${opml}";
		unset line_number;
		printf "\n\t\t\t\t\t\t\t\t\t\t[finished]\n";
		
		
		
		printf "Formating %s's %s OPML" "${website}" "${category}";
		mv -f "${opml}" "${opml}.tmp";
		ex -s '+1,$s/\n//' '+wq!' "${opml}.tmp";
		ex -s '+1s/\v(\<\!\-\-pod tile[^-]*\-\-\>)/\r\1\r/g' '+1,$s/"/'\''/g' '+wq!' "${opml}.tmp";
		set opml_file_for_editor="`printf "\""${opml}.tmp"\"" | sed -r 's/(["\"\$\!"'\''\[\(\)\ \<\>])/\\\1/g'`";
		ex -s "+"\$"r ${opml_file_for_editor}" '+wq!' "${opml}.swp";
		ex -s "+1,"\$"s/\v^.*\<span class\='pd_title'\>(.+)\<\/span\>.*\<div class\='pd_descp'\>(.+)\<form.*\<a href\='([^']+)'\>RSS\<\/a\>.*(\<span class\='programlink caption'\>)?\<a href\='([^']+)'\>.*\n\<\!\-\-pod tile[^-]+\-\-\>/\t\t\<outline title\="\""\<\!\[CDATA\[\1\]\]\>"\"" xmlUrl\="\""\4"\"" type\="\""rss"\"" text\="\""\<\!\[CDATA\[CBC\'s: \1\]\]\>"\"" htmlUrl\="\""\5"\"" description\="\""\<\!\[CDATA\[\<h1\>CBC\'s: \1\<\/h1\>\<p\>\2\<\/p\>\]\]\>"\"" \/\>\r/" '+wq!' "${opml}.swp";
		ex -s '+1,$s/\v^(\t\t\<outline)@'\!'.*\>.*\n//' '+wq!' "${opml}.swp";
		printf "\n\t\t\t\t\t\t\t\t\t\t[finished]\n";
		
		printf "Saving %s's %s OPML" "${website}" "${category}";
		mv -f "${opml}.swp" "${opml}.tmp";
		printf "<?xml version="\""1.0"\"" encoding="\""UTF-8"\""?>\n<opml version="\""2.0"\"">\n\t<head>\n\t\t<title>%s&apos;s %s</title>\n\t</head>\n\t<body>\n" "${website}" "${category}" >! "${opml}";
		ex -s "+"\$"r ${opml_file_for_editor}" '+wq!' "${opml}";
		rm "${opml}.tmp";
		printf "\t</body>\n</opml>\n" >> "${opml}";
		ex -s '+1,$s/^\n//' '+wq!' "${opml}";
		vim-enhanced "${opml}";
		printf "\n\t\t\t\t\t\t\t\t\t\t[finished]\n\n";
		unset category url opml opml_file_for_editor;
	end
#goto fetch_and_format_opmls;


