#!/bin/tcsh -f

setenv:
	alias ex 'ex -E -n -X --noplugin';
	if(! -e "${HOME}/.config/gpodder/gpodder.conf" ) then
		printf "Unable to find gpodder's config file.\n" > /dev/stderr;
		exit -1;
	endif
	
	set download_dir = "`grep 'download_dir' '${HOME}/.config/gpodder/gpodder.conf' | cut -d= -f2 | cut -d' ' -f2`"
	if(!( "${download_dir}" != "" && -d "${download_dir}" )) then
		printf "Unable to find gpodder's download directory.\n" > /dev/stderr;
		exit -1;
	endif
	
	if( "${download_dir}" != "${cwd}" ) then
		set old_owd="${cwd}";
		cd "${download_dir}";
	endif
#goto setenv;


parse_argv:
	while("${1}" != "")
		set dashes="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/([-]{1,2})([^=]+)(=)?(.*)/\1/'`";
		if( "${dashes}" == "${1}" ) \
			set dashes="";
		set option="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/([-]{1,2})([^=]+)(=)?(.*)/\2/'`";
		if( "${option}" == "${1}" ) \
			set option="";
		set equals="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/([-]{1,2})([^=]+)(=)?(.*)/\3/'`";
		set value="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/([-]{1,2})([^=]+)(=)?(.*)/\4/'`";
		if( "${option}" != "" && "${value}" == "" && "${equals}" == "" && "${2}" != "" )	\
			set value="${2}";
		
		switch("${option}")
			case "no-check":
			case "do-not-remove":
			case "skip-clean-up":
				if(! ${?skip_clean_up} ) \
					set skip_clean_up;
				breaksw;
			
			case "interactive":
				if(! ${?interactive} ) \
					set interactive;
				breaksw;
			
			case "check":
			case "remove":
			case "clean-up":
				switch("${value}")
					case "force":
						if(! ${?force_clean_up} ) \
							set force_clean_up;
						breaksw;
					
					default:
						breaksw;
				endsw
				breaksw;
			
			case "verbose":
				if(! ${?be_verbose} ) \
					set be_verbose;
				breaksw;
			
			case "force":
				if(! ${?force_clean_up} ) \
					set force_clean_up;
				breaksw;
			
			case "O":
			case "output":
			case "output-document":
				if( "${value}" != "" ) \
					set pubDate_log="${value}";
				breaksw;
			
			default:
				printf "%s is an unsupported option" "${1}";
				goto usage:
				breaksw;
		endsw
		unset dashes option equals value;
		shift;
	end
#goto parse_argv;


init:
	if(! ${?pubDate_log} ) \
		set pubDate_log="${cwd}/pubDate.log";
	printf "Podcast pubDates will be saved to: %s\n" "${pubDate_log}";

	if( -e "${pubDate_log}" ) rm "${pubDate_log}";
	touch "${pubDate_log}";
	
	set escaped_cwd="`printf "\""%s"\"" "\""${cwd}"\"" | sed -r 's/([/.])/\\\1/g'`";
	#@ max_indexes=200;
#goto init;


check_indexes:
	foreach index(*/index.xml)
		@ index_count++;
		cp -f "${index}" "./index.swp";
		ex '+1,$s/\v\r\n?\_$//' '+1,$s/\n//g' '+wq' "./index.swp" > /dev/null;
		
		set title="`cat "\""./index.swp"\"" | sed -r 's/.*<channel><title>([^<]+)<\/title>.*/\1/' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
		set escaped_index="`printf "\""%s"\"" "\""${index}"\"" | sed -r 's/([/.])/\\\1/g'`";
		ex "+1,"\$"s/\v.*\<channel\>\<title\>([^<]+)\<\/title\>.*\<item\>\<title\>([^<]+)\<\/title\>.*\<url\>(.*)(\.[^<\.?]+)([\.?]?[^<]*)\<\/url\>.*\<pubDate\>([^<]+)\<\/pubDate\>\<\/item\>\<\/rss\>.*"\$"/${escaped_cwd}\/${escaped_index} \-\- <\1>, \<\2\>, released on: \6\4/g" '+wq!' index.swp > /dev/null;
		
		if( ${?be_verbose} ) \
			printf "Checking <%s>'s pubDate.\n" "${title}" > /dev/stdout;
		
		if(! ${?skip_clean_up} ) then
			set escaped_title="`printf "\""${title}"\"" | sed -r 's/([\(\)\[\.\|])/\\\1/g' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g' | sed -r "\""s/(['])/\1\\\1\1/g"\""`";# | sed -r 's/'\''/'\'''\\\\\'''\''/g'`";
			if( "`/bin/grep -Pi '^[ \t]+\<outline.*title\="\""${escaped_title}"\"".*"\$"' "\""${HOME}/.config/gpodder/channels.opml"\""`" == "" && ${?interactive} ) then
				set confirmation;
				if(! ${?force_clean_up} ) then
					printf "You are no longer subscribed to <%s>'s feed.\n\tWould you like to delete it? [Yes(default)/No] " "${title}";
					set confirmation="$<";
					printf "\n";
					switch(`printf "%s" "${confirmation}" | sed -r 's/^(.).*$/\l\1/'`)
						case "n":
							unset confirmation;
							breaksw;
						
						case "y":
						default:
							breaksw;
					endsw
				endif
				
				if( ${?confirmation} ) then
					rm -rfv "`dirname "\""${index}"\""`";
					unset confirmation;
				endif
				
				if(! -e "./index.swp" ) then
					unset escaped_index index title;
					continue;
				endif
			else if( ${?interactive} ) then
				set podcast_pubdate="`tail -1 "\""${pubDate_log}"\"" | sed -r 's/(.*)\ \:\ (.*)(\/index\.xml)\ \-\-\ <(.*)>,\ <(.*)>(,.*)/\1/'`";
				printf "<%s>'s last episode was released on [%s].\n\tWould you like to unsubscribe from it's feed? [Yes/No(default)] " "${title}" "${podcast_pubdate}";
				set confirmation="$<";
				printf "\n";
				switch(`printf "%s" "${confirmation}" | sed -r 's/^(.).*$/\l\1/'`)
					case "y":
						breaksw;
					
					case "n":
					default:
						unset confirmation;
						breaksw;
				endsw
					
				if( ${?confirmation} ) then
					gPodder:Delete.tcsh --absolute-match --title="${title}";
					rm -rfv "`dirname "\""${index}"\""`";
					unset confirmation podcast_pubdate escaped_index index title;
					continue;
				endif
				unset podcast_pubdate;
			endif
		endif
		
		cat index.swp \
			| sed -r 's/(.*\/)(.*, released on\:? [^,]+, )([0-9]+ )(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)( [^.]+)(\.[^\.]+)/\3\4\5\ \:\ \1\2\3\4\5\6/' \
			| sed -r 's/([0-9]+ )(Jan) ([0-9]+) ([^\:]+)(\:.*)/\3\-01\-\1\4\5/' \
			| sed -r 's/([0-9]+ )(Feb) ([0-9]+) ([^\:]+)(\:.*)/\3\-02\-\1\4\5/' \
			| sed -r 's/([0-9]+ )(Mar) ([0-9]+) ([^\:]+)(\:.*)/\3\-03\-\1\4\5/' \
			| sed -r 's/([0-9]+ )(Apr) ([0-9]+) ([^\:]+)(\:.*)/\3\-04\-\1\4\5/' \
			| sed -r 's/([0-9]+ )(May) ([0-9]+) ([^\:]+)(\:.*)/\3\-05\-\1\4\5/' \
			| sed -r 's/([0-9]+ )(Jun) ([0-9]+) ([^\:]+)(\:.*)/\3\-06\-\1\4\5/' \
			| sed -r 's/([0-9]+ )(Jul) ([0-9]+) ([^\:]+)(\:.*)/\3\-07\-\1\4\5/' \
			| sed -r 's/([0-9]+ )(Aug) ([0-9]+) ([^\:]+)(\:.*)/\3\-08\-\1\4\5/' \
			| sed -r 's/([0-9]+ )(Sep) ([0-9]+) ([^\:]+)(\:.*)/\3\-09\-\1\4\5/' \
			| sed -r 's/([0-9]+ )(Oct) ([0-9]+) ([^\:]+)(\:.*)/\3\-10\-\1\4\5/' \
			| sed -r 's/([0-9]+ )(Nov) ([0-9]+) ([^\:]+)(\:.*)/\3\-11\-\1\4\5/' \
			| sed -r 's/([0-9]+ )(Dec) ([0-9]+) ([^\:]+)(\:.*)/\3\-12\-\1\4\5/' \
			#| sort \
			#| sed -r 's/(.*)\ \:\ (.*)/\2/' \
		>> "${pubDate_log}";
		
		rm ./index.swp;
		unset escaped_index index title;
		
		if( ${?max_indexes} ) then
			if( $index_count > $max_indexes ) then
				unset index_count max_indexes;
				break;
			endif
		endif
	end
#goto check_indexes;


finalize:
	if( -e "./index.swp" ) \
		rm "./index.swp";
	
	sort "${pubDate_log}" \
		| sed -r 's/(.*)\ \:\ (.*)(\/index\.xml)\ \-\-\ (<.*>),\ (<.*>)(,.*)/\4 @ \1\:\ \<file\:\/\/\2\>/' \
		#| sed -r 's/(.*)\ \:\ (.*)(\/index\.xml)\ \-\-\ (<.*>,\ )(<.*>)(,.*)/\4\5 @ \1,\ \<file\:\/\/\2\3\>/' \
		#| sed -r 's/(.*)\ \:\ (.*)(\/index\.xml)\ \-\-\ (.*)/\1 \:\ \4\ \<file\:\/\/\2\3\>/' \
		#| sed -r 's/(.*)\ \:\ (.*)(\/index\.xml)/\2\3/' \
		#| sed -r 's/(.*)\ \-\-\ (.*)(\/index\.xml)/\2\3/' \
	>! "${pubDate_log}.swp";
	
	mv -f "${pubDate_log}.swp" "${pubDate_log}";
	
	printf "Saving name value sorted log to [%s.names]..." "${pubDate_log}";
	sort "${pubDate_log}" >! "${pubDate_log}.names";
	printf "\t[finished]\n";

	if( ${?skip_clean_up} ) \
		unset skip_clean_up;
	if( ${?force_clean_up} ) \
		unset force_clean_up;
	if( ${?confirmation} ) \
		unset confirmation;
	if( ${?index_count} ) \
		unset index_count;
	if( ${?max_indexes} ) \
		unset max_indexes;
	if( ${?pubDate_log} ) \
		unset pubDate_log;
	
	if( ${?old_owd} ) then
		cd "${owd}";
		set owd="${old_owd}";
		unset old_owd;
	endif
#goto finalize;


exit_script:
	set status=0;
	
	exit ${status};
#goto exit_script;


usage:
	printf "Usage:\n\t%s [--ouput=]\n" "`basename '${0}'`";
	set status=-1;
	goto exit_script;
#goto usage;


