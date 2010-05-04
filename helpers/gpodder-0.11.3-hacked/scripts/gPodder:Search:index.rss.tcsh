#!/bin/tcsh -f
if(! ${?0} ) then
	printf "This script does not support being sourced.\n" > /dev/stderr;
	@ status=-501;
	exit ${status};
endif

if(!( ${?1} && "${1}" != "" && "${1}" != "--help" ))	\
	goto usage;
	
find_config:
	if(! -e "${HOME}/.config/gpodder/gpodder.conf" ) \
		goto create_config;
#find_config:


init:
	if(! ${?config} ) \
		set config="${HOME}/.config/gpodder/gpodder.conf";
	
	set dl_dir = "`grep 'download_dir' '${config}' | cut -d= -f2 | cut -d' ' -f2`";
	set mp3_dir = "`grep 'mp3_player_folder' '${config}' | cut -d= -f2 | cut -d' ' -f2`";
	set outputs=("title" "link" "url" "guid");
#init:


parse_argv:
	@ arg=0;
	@ argc=${#argv};
	while( $arg < $argc )
		@ arg++;
		switch("$argv[$arg]")
			case "--diagnosis":
			case "--diagnostic-mode":
				printf "**%s debug:**, via "\$"argv[%d], diagnostic mode\t[enabled].\n\n" "${scripts_basename}" $arg;
				set diagnostic_mode;
				if(! ${?debug} ) \
					set debug;
				break;
			
			case "--debug":
				printf "**%s debug:**, via "\$"argv[%d], debug mode\t[enabled].\n\n" "${scripts_basename}" $arg;
				set debug;
				break;
			
			default:
				continue;
		endsw
	end
#parse_argv:


while( "${1}" != "" )
	set option="`printf "\""%s"\"" "\""${1}"\"" | sed "\""s/\-\-\([^=]\+\)\(=\?\)\(.*\)/\1/g"\"" | sed -r "\""s/(['])/\1\\\1\1/g"\""`"
	set equals="`printf "\""%s"\"" "\""${1}"\"" | sed "\""s/\-\-\([^=]\+\)\(=\?\)\(.*\)/\2/g"\"" | sed -r "\""s/(['])/\1\\\1\1/g"\""`"
	set value="`printf "\""%s"\"" "\""${1}"\"" | sed "\""s/\-\-\([^=]\+\)\(=\?\)\(.*\)/\3/g"\"" | sed -r "\""s/(['])/\1\\\1\1/g"\""`"
	if( "${equals}" == "" && "${value}" == "" && "${2}" != "" )	\
		set value="${2}";
	switch ( "${option}" )
		case "title":
		case "description":
		case "link":
		case "url":
		case "guid":
		case 'link':
		case "pubDate":
			set attrib="${option}";
			set attrib_value="${value}";
			#set attrib_value="`printf '${value}' | sed -r "\""s/(['])/\1\\\1\1/g"\"" | sed -r 's/([\?])/\\\1/g'`";
		breaksw;
	
	case "output":
		switch ( "${value}" )
			case "title":
			case "description":
			case "url":
			case "guid":
			case "pubDate":
			case "link":
				if(! ${?output )	\
					set output="${value}";#"`printf "\""${value}"\"" | sed -r "\""s/(['])/\1\\\1\1/g"\"" | sed -r 's/([\?])/\\\1/g'`";
				foreach item(${outputs})
					if("${value}" == "${item}" )	\
						break;
					unset item;
				end
				if( ${?item} ) then
					unset item;
					breaksw;
				endif
				set outputs[${#outputs}]="${value}";#"`printf "\""${value}"\"" | sed -r "\""s/(['])/\1\\\1\1/g"\"" | sed -r 's/([\?])/\\\1/g'`";
				breaksw;
			
			default:
				if( ${?debug} )	\
					printf "%s is not a valid --output value.\nPlease see %s --help\n\n" "${value}" "`basename '${0}'`" > /dev/stderr;
				breaksw;
		endsw
		breaksw;
	
	case "verbose":
		set be_verbose;
		breaksw;
	
	case "match-only":
		set match_only;
		breaksw;
	
	case "refetch":
		set refetch;
		set silent="";
		if( "${value}" == "silent" ) then
			set silent="--silent";
		else if( "${value}" == "all" ) then
			set refetch="all"
		endif
		breaksw;
	
	case "all":
	case "force":
	case "fetch-all":
		set refetch="all"
		breaksw;
	
	case "help":
		goto usage;
		breaksw;
	
	default:
		if( ${?debug} )	\
			printf "%s is not a valid option.\nPlease see %s --help\n\n" "${option}" "`basename '${0}'`" > /dev/stderr;
		breaksw;
	
	endsw
	shift;
end

	if(! ${?attrib_value} )	\
		goto usage;
	
	if(! ${?attrib} )	\
		set attrib="title";
	
	if(! ${?output} )	\
		set output="${attrib}";
	
alias egrep "/usr/bin/grep --binary-files=without-match --color --with-filename --line-number --initial-tab --no-messages --perl-regexp";
alias ex "ex -E -n -X --noplugin";

foreach index ( ${dl_dir}/*/index.xml )
	if( "`egrep '<[^\/][^>]+>[^<]+"\$"' '${index}'`" != "" )	\
		ex -s '+2,$s/\v\r\n?\_$//g' '+2,$s/\n//g' '+wq!' "${index}";
	set found="`egrep '<${attrib}>.*${attrib_value}.*<\/${attrib}>' '${index}' | sed -r 's/[\r\n]+//' | sed -r 's/<${attrib}>/\n&/g' | sed -r 's/^(.*)<\/${attrib}>.*/\1\r/g'`";
	
	if( "${found}" == "" ) continue;
	
	@ items=0;
	foreach item("`egrep "\""<${output}>[^<]+<\/${output}>"\"" "\""${index}"\"" | sed -r 's/[\r\n]+//' | sed -r "\""s/<${output}>/\n&/g"\"" | sed -r "\""s/^<${output}>(.*)<\/${output}>.*/\1\r/g"\""`")
		@ items++;
		if( ${items} == 1 )	\
			continue;
		printf "<file://%s>:%s\n" "${index}" "${item}";
	end
	
	if(! ${?match_only} ) then
		@ attrib=0;
		foreach output_attrib(${outputs})
			@ attrib++;
			#if( "${output_attrib}" == "${output}" ) continue;
			#if( ${attrib} == 1 && "${output_attrib}" == "title" )	\
			#	continue;
			foreach item("`egrep "\""<${output_attrib}>[^<]+<\/${output_attrib}>"\"" "\""${index}"\"" | sed -r 's/[\r\n]+//' | sed -r "\""s/.*<${output_attrib}>(.*)<\/${output_attrib}>.*/\1/g"\""`")
				printf "\t<%s="\""%s"\"">\n" "${output_attrib}" "${item}";
			end
		end
	endif
	
	if( ${?be_verbose} ) then
		printf "----------------- Contents of: <%s> -----------------\n" "${index}";
		cat "${index}" | sed -r "s/<${output}>/\n&/g" | sed -r "s/<\/${output}>/&\n/g" | sed -r 's/^(.)/\t\1/';
		printf "\n\n";
	endif
	
	if( ${?refetch} ) then
		printf "#\!/bin/tcsh -f\ncd "\""%s"\"";\n" "${mp3_dir}" >! "${index}".tcsh;
		cat "${index}" >> "${index}".tcsh;
		ex -s '+3d' '+3,$s/\v\r\n?\_$//g' '+3,$s/\n//g' '+s/\(<\/item>\)/\1\r/g' '+3,$s/\(<title>\)/\r\1/g' '+3d' '+$d' '+3,$s/[\#\!]//g' '+wq!' "${index}".tcsh;
		ex -s '+3s/\v.*\<title\>([^<]+)\<\/title\>.*/\1/' '+3s/"/"\\""/' '+wq!' "${index}".tcsh;
		ex -s '+3s/\v(.*)/set podcasts_title="\1";\rif\( "\`printf "\\""${podcasts_title}"\\"" \| sed -r '\''s\/\(The\)\(\.*\)\/\\1\/g'\''\`" == "The" \)\ \\\r\tset podcasts_title="\`printf "\\""${podcasts_title}"\\"" \| sed -r '\''s\/\(The\)\ \(\.*\)\/\\2,\ \\1\/g'\''\`";\rif(\! -d "${podcasts_title}" ) then\r\tset new_dir;\r\tmkdir -p "${podcasts_title}";\rendif\r/' '+11,$s/\v\<title\>([^\<]+)\<\/title\>.*\<url\>(.*)\.([^\.\<]+)\<\/url\>.*\<pubDate\>([^\<]+)\<\/pubDate\>.*/if(! -e "${podcasts_title}\/\1, released on: \4\.\3" ) then\r\tprintf "Downloading ${podcasts_title} episode: \1\\n";\r\tcurl '${silent}'--location --fail --show-error --output "${podcasts_title}\/\1, released on: \4\.\3" "\2.\3";\r\tif( -e "${podcasts_title}\/\1, released on: \4\.\3" ) then\r\t\tif(\! ${?podcast_downloaded} ) set podcast_downloaded;\r\telse\r\t\tprintf "\\n**error:** <%s> could not be downloaded.\\n\\n" "${podcasts_title}\/\1, released on: \4\.\3";\r\tendif\rendif\r/' '+wq!' "${index}".tcsh;
		printf 'if( ${?new_dir} && ! ${?podcast_downloaded} ) then\n\trmdir "${podcasts_title}";\n\tif( ${?new_dir} ) \\\n\t\tunset new_dir;\nendif\n' >> "${index}".tcsh;
		chmod u+x "${index}".tcsh;
		"${index}".tcsh;
		if( ${?diagnostic_mode} ) then
			set index_xml_hash="`dirname '${index}'`";
			set index_xml_hash="`basename '${index}'`";
			cp -v "${index}".tcsh "${cwd}/${index_xml_hash}.tcsh";
		endif
		rm "${index}.tcsh";
	endif
end

exit;

usage:
	printf "Usage| %s [--help] [--verbose] [--output=[title(default)|description|link|url|guid|pubDate]attribute to display, defaults to title] [--title(default)|description|link|url|guid|pubDate=]'search_term'\n" `basename "${0}"`
	exit;
#usage:

create_config:
	if( -e "${HOME}/.alacast/helper.conf" ) then
		set config="${HOME}/.alacast/helper.conf";
	else if( -e "${HOME}/.alacast/profiles/${USER}/helper.conf" ) then
		set config="${HOME}/.alacast/profiles/${USER}/helper.conf";
	else
		set scripts_path="`dirname "\""${0}"\""`";
		if( -e "${scripts_path}../data/profiles/${USER}/helper.conf" ) then
			set config="${scripts_path}../data/profiles/${USER}/helper.conf";
		else if( -e "../data/profiles/default/helper.conf" ) then
			set config="${scripts_path}../data/profiles/default/helper.conf";
		endif
		unset scripts_path;
	endif
	
	if(! ${?config} ) then
		printf "Unable to find [%s]'s needed alacast.ini/gpodder.conf.\n" "`basename '${0}'`" > /dev/stderr;
		printf "alacast v1 was not setup and/or installed correctly.\n\(Please see alacast v1's README.\n" > /dev/stderr;
	
		@ status=-502;
		exit ${status};
	endif
	
	if(! -d "${HOME}/.config/gpodder" ) \
		mkdir -p "${HOME}/.config/gpodder";
	
	ln -s "${config}" "${HOME}/.config/gpodder/gpodder.conf";
	
	goto init;
#create_config:
