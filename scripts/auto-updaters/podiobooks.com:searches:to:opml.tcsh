#!/bin/tcsh -f
setenv:
	if(! ${?0} ) then
		printf "This script cannot be sourced.\n" > /dev/stderr;
		exit -1;
	endif
	
	onintr exit_script;
	
	alias "wget" "wget --no-check-certificate --continue --quiet";
	alias "ex" "ex -E -n -X --noplugin";
#setenv

parse_argv:
	@ arg=0;
	@ argc=${#argv};
	while( $arg < $argc )
		@ arg++;
		set dashes="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{2})(.*)/\1/'`";
		if( "${dashes}" != "$argv[$arg]" ) \
			set dashes="";
		
		set option="`printf "\""$argv[$arg]"\"" | sed -r 's/^([\-]{2})(.*)/\2/'`";
		
		switch("${option}")
			case "h":
			case "help":
				goto usage;
				breaksw;
			
			case "edit":
			case "validate":
				set validate;
				breaksw;
			
			case "Alternative History":
				set author_or_category="12";
				breaksw;
			
			case "Audiodrama":
				set author_or_category="20";
				breaksw;
			
			case "Business":
				set author_or_category="3";
				breaksw;
			
			case "Chick Lit":
				set author_or_category="28";
				breaksw;
			
			case "Children":
				set author_or_category="9";
				breaksw;
			
			case "Erotica":
				set author_or_category="26";
				breaksw;
			
			case "Essays":
				set author_or_category="8";
				breaksw;
			
			case "Fabulist Satire":
				set author_or_category="34";
				breaksw;
			
			case "Fantasy":
				set author_or_category="2";
				breaksw;
			
			case "Fiction":
				set author_or_category="7";
				breaksw;
			
			case "Historical Fantasy":
				set author_or_category="32";
				breaksw;
			
			case "Historical Fiction":
				set author_or_category="21";
				breaksw;
			
			case "History":
				set author_or_category="19";
				breaksw;
			
			case "Horror/Dark Fantasy":
				set author_or_category="11";
				breaksw;
			
			case "Humor":
				set author_or_category="6";
				breaksw;
			
			case "Inspirational Fiction":
				set author_or_category="30";
				breaksw;
			
			case "Literature":
				set author_or_category="29";
				breaksw;
			
			case "Magical Realism":
				set author_or_category="13";
				breaksw;
			
			case "Mystery":
				set author_or_category="5";
				breaksw;
			
			case "Non-Fiction":
				set author_or_category="18";
				breaksw;
			
			case "Public Domain":
				set author_or_category="17";
				breaksw;
			
			case "Romance":
				set author_or_category="31";
				breaksw;
			
			case "Science Fiction":
				set author_or_category="1";
				breaksw;
			
			case "Self-Help":
				set author_or_category="33";
				breaksw;
			
			case "Spirituality":
				set author_or_category="22";
				breaksw;
			
			case "Steampunk":
				set author_or_category="35";
				breaksw;
			
			case "Thriller":
				set author_or_category="27";
				breaksw;
			
			case "Travelogue":
				set author_or_category="24";
				breaksw;
			
			case "Young Adult":
				set author_or_category="10";
				breaksw;
			
			default:
				set author_or_category="$argv[$arg]";
				breaksw;
		endsw
	end
	goto main;
#goto parse_argv;


usage:
	printf "Usage: %s "\""Podiobook Category"\"", an "\""Author's name"\"", or other "\""Search Phrase"\"",\n";
	if(!${?status}) \
		set status=0;
	exit $status;
#goto usage;


exit_script:
	if( ${?opml} ) then
		if( -e "${opml}.swp" ) \
			rm -f "${opml}.swp";
		if( ! -e "${opml}" && ${?new_dir} ) then
			if( -d "${new_dir}" ) \
				rmdir "${new_dir}";
			unset new_dir;
		endif
		unset opml;
	endif
	
	if( ${?opml_template} ) then
		if( -e "${opml_template}" ) \
			rm -f "${opml_template}";
	endif
	
	if(! ${?status} ) \
		set status=0;
	exit $status;
#goto usage;


main:
	printf "Downloading podiobooks.com's listings";
	set website="http://www.podiobooks.com/podiobooks/search.php";
	if( "`printf "\""${author_or_category}"\"" | sed -r 's/^[0-9]+"\$"//'`" != "" ) then
		set opml="`dirname "\""${0}"\""`/../../data/xml/opml/library/authors/`printf "\""${author_or_category}"\"" | sed -r 's/([^ ]+)/\L\1/g' | sed -r 's/\ /\-/g'`.opml";
		set website="${website}?keyword=`printf "\""${author_or_category}"\"" | sed -r 's/\ /\+/g'`&includeAdult=1";
		
		if(! -d "`dirname "\""${opml}"\""`" ) then
			set new_dir="`dirname "\""${opml}"\""`";
			mkdir -p "${opml}";
		endif
		
		wget -O "${opml}.swp" "${website}";
	else
		set website="${website}?category=${author_or_category}";
		wget -O search.xhtml "${website}";
		set author_or_category="`/bin/grep -P '\<option[^<]+ selected[^<]+\>' search.xhtml | sed -r 's/<option[^<]+>([^<]+)<\/option>/\1/'`";
		set opml="`dirname "\""${0}"\""`/../../data/xml/opml/library/podiobooks.com/categories/`printf "\""${author_or_category}"\"" | sed -r 's/([^ ]+)/\L\1/g' | sed -r 's/\ /\-/g'`.opml";
		
		if(! -d "`dirname "\""${opml}"\""`" ) then
			set new_dir="`dirname "\""${opml}"\""`";
			mkdir -p "${opml}";
		endif
		
		mv -f "search.xhtml" "${opml}.swp";
	endif

	set display_name="${author_or_category}'";
	set title="${author_or_category}&appos;";
	if( "`printf "\""${author_or_category}"\"" | sed -r 's/^.*(.)"\$"/\l\1/'`" != "s" ) then
		set display_name="${title}s";
		set title="${title}s";
	endif

	printf "\t[finished]\n";
	goto opml_format_swap;
#goto main;


opml_format_swap:
	printf "Formating %s OPML" "${display_name}";
	ex -s "+1,`/bin/grep --line-number 'tableheader' "\""${opml}.swp"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`d" '+wq!' "${opml}.swp";
	
	ex -s "+`/bin/grep --line-number '<\/table>' "\""${opml}.swp"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`,"\$"d" '+wq!' "${opml}.swp";
	
	ex -s '+1,$s/\v\r\_$//g' '+1,$s/\v\n//g' '+1,$s/\v\t*(\<tr)/\r\1/g' '+1,$s/\v(\<\/tr\>)\t*/\1\r/g' '+1,2d' '+1,$s/"/'\''/g' '+1,$s/\v\<tr class\='\''(even|odd)row.*.*href\='\''\/(title\/[^'\'']+)'\''\>([^<]+)\<\/a\>.*\<span class\='\''smalltext'\''\>([^\<]+)\<\/class\>\<\/td\>\<td\>(.*)\<br\/\>.*\<\/tr\>\t*\n*/\t\t\<outline title\="\<\!\[CDATA\[\3\]\]\>" xmlUrl\="http:\/\/www\.podiobooks\.com\/\2\/feed\/\"\ type\="rss" text\="\<\!\[CDATA\[\3 \- A free audiobook by \4\]\]\>" htmlUrl\="http:\/\/www\.podiobooks\.com\/\2\/" description\="\<\!\[CDATA\[\<h1\>\3 by \4\<\/h1\>\<p>\5\<\/p\>\]\]\>"\ \/>\r/' '+$d' '+wq!' "${opml}.swp";
	printf "\t[finished]\n";

	if(! -e "${opml}" ) \
		goto new_opml;
	
	set line_count="`wc -l "\""${opml}"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`";
	if( "${line_count}" == "" ) \
		goto new_opml;
	
	if(! $line_count > 9 ) \
		goto new_opml;
	
	goto open_opml;
#goto opml_format_swap;


new_opml:
	printf "Creating %s OPML" "${display_name}";
	set opml_template="`mktemp --tmpdir template.opml.xml.XXXXXX`";
	printf "<?xml version="\""1.0"\"" encoding="\""UTF-8"\""?>\n<opml version="\""2.0"\"">\n\t<head>\n\t\t<title>\n\t\t\t${title} podcast novels &ndash; prensented by: podiobooks.com\n\t\t</title>\n\t</head>\n\t<body>\n\t</body>\n</opml>\n" >! "${opml_template}";
	set line=8;
	set opml_is_new="+0r ${opml_template}";
	goto save_opml;
#goto new_opml;


open_opml:
	set line="`/bin/grep --line-number '<\/body>' "\""${opml}"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`";
	if( "${line}" == "" ) then
		set line="`/bin/grep --line-number '<body>' "\""${opml}"\"" | sed -r 's/^([0-9]+).*"\$"/\1/'`";
		if( "${line}" == "" ) \
			goto new_opml;
	endif
	
	if(! ${line} > 1 ) \
		goto new_opml;
	
	printf "Updating %s OPML" "${display_name}";
	set line="${line}-1";
	set opml_is_new="+${line}";
	goto save_opml;
#goto open_opml;


save_opml:
	if(! ${?validate} ) then
		alias "ex" "ex -E -n -X --noplugin -s";
		set validate="wq!";
	else
		set validate="visual";
	endif
	
	ex "${opml_is_new}" "+${line}r `printf "\""${opml}.swp"\"" | sed -r 's/(["\"\$\!"'\''\[\]\(\)\ \<\>])/\\\1/g'`" "+${validate}" "${opml}";
	
	rm -f "${opml}.swp";
	printf "\t[finished]\n";
	
	if(! -e "${opml}" ) then
		printf "\tAbonded: <file://%s>\t[canceled]\n" "${opml}";
	else
		printf "\tSaving: <file://%s>\t[finished]\n" "${opml}";
	endif
	goto exit_script;
#goto save_opml;


