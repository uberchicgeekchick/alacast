#!/bin/tcsh -f
# This is TRUE if this script is called via `source`
if( "`printf '%s' '${0}' | sed -r 's/^[^\.]*(tcsh)/\1/'`" == "tcsh" ) exit;

set script_name="`basename '${0}'`";
set search_script="`dirname '${0}'`/gPodder:Search:index.rss.tcsh";

if( "${1}" == "" || "${1}" == "--help" ) then
	printf "%s uses %s to find what episodes to redownload.\n\tIt supports all of its options in addition to:\n\t\t-s,--silent\tCause curl's ouptput to be surpressed.\t\n\t\n\tIn addition %s' options are:\n\t" `${script_name}` ${search_script} ${search_script};
	${search_script} --help
	exit -1;
endif

set silent="";
if( "${1}" == "--silent" || "${1}" == "-s" ) then
	set silent=" --silent";
	shift;
endif

if( "${1}" == "--verbose" || "${1}" == "--debug" ) then
	set debug_enabled;
	shift;
endif

set mp3_player_folder="`grep 'mp3_player_folder' '${HOME}/.config/gpodder/gpodder.conf' | cut -d= -f2 | cut -d' ' -f2`";

cd "${mp3_player_folder}";

if( ${?GREP_OPTIONS} ) then
	set grep_options="${GREP_OPTIONS}";
	unsetenv GREP_OPTIONS;
endif

if(! ${?eol} ) setenv eol='$';

set search_attribute="`echo "\""${1}"\"" | sed 's/^\-\-\([^=]\+\)=\(.*\)${eol}/\1/'`";
set search_value="`echo "\""${1}"\"" | sed 's/^\-\-\([^=]\+\)=\(.*\)${eol}/\2/'`";

if( "${2}" == "-k" ) set keep_script;

if( ${?debug_enabled} ) echo "Search for podcasts who <${search_attribute}> matches: ${search_value}\n\tUsing:\n\t${search_script} --${search_attribute}="\""${search_value}"\"" | sed 's/^[^\:]\+:\(.*\)${eol}/\1/g' | sed 's/\\!//'"
foreach podcast_match( "`${search_script} --${search_attribute}="\""${search_value}"\"" | sed 's/^[^\:]\+:\(.*\)${eol}/\1/g'`" )
	if( ${?debug_enabled} ) echo "${search_value}\n";
	set podcast_match="`printf "\""${podcast_match}"\"" | sed 's/\([-!\(\)]\)/\\\1/g'`";
	if( ${?debug_enabled} ) echo "${podcast_match}\n";
	set refetch_script="${mp3_player_folder}/gPodder:Refetch:`date '+%s'`.tcsh";
	if( ${?debug_enabled} ) echo "${refetch_script}\n";
	
	if( ${?debug_enabled} ) echo ${search_script} --verbose --${search_attribute}=\"${search_value}\" \>\! \"${refetch_script}.tmp\""\n";
	${search_script} --verbose --${search_attribute}="${search_value}" >! "${refetch_script}.tmp";
	
	#ex --noplugin -E -n -X '+1,$s/[\r\n]\+//g' '+s/\(<\/item>\)/\1\n/g' '+s/#//g' '+1,$s/.*<title>\([^>]\+\)<\/title>.*<title>\([^<]\+\)<\/title>.*<url>\(.*\)\.\([^<\.]\+\)<\/url>.*<pubDate>\([^<]\+\)<\/pubDate>.*/if( -d "\1" ) then\relse\r\tmkdir "\1";\rendif\rcurl'${silent}' -C `/bin/ls -s "\1\/\2, released on: \5\.\4" | sed -r "s/^([0-9]+).*/\1/"` --fail --show-error --output "\1\/\2, released on: \5\.\4" '\''\3\.\4'\''/g' '+1,$s/\!//g' '+w' '+visual' "${refetch_script}.tmp";
	ex --noplugin -E -n -X '+1,$s/[\r\n]\+//g' '+s/\(<\/item>\)/\1\n/g' '+s/#//g' '+1,$s/.*<title>\([^>]\+\)<\/title>.*<title>\([^<]\+\)<\/title>.*<url>\(.*\)\.\([^<\.]\+\)<\/url>.*<pubDate>\([^<]\+\)<\/pubDate>.*/if( -d "\1" ) then\relse\r\tset new_dir;\r\tmkdir "\1";\rendif\rcurl'${silent}' --location --fail --show-error --output "\1\/\2, released on: \5\.\4" '\''\3\.\4'\'';\rif( -e "\1\/\2, released on: \5\.\4" ) then\relse\r\tprintf "\\n**error:** <%s> could not be downloaded.\\n\\n" '\''\3\.\4'\'';\r\tif( ${?new_dir} ) rmdir "\1";\rendif\rif( ${?new_dir} ) unset new_dir;/g' '+1,$s/\!//g' '+wq!' "${refetch_script}.tmp" > /dev/null;
	
	#while ( `/usr/bin/grep --perl-regexp '("[^\/]+)\/(.*)"' "${refetch_script}.tmp"` != "" )
	#	ex --noplugin -E -n -X '+1,$s/\("[^\/]\+\)\/\(.*"\)/\1\-\2/g' '+wq!' "${refetch_script}.tmp" >& /dev/null;
	#end
	
	set podcast_dir=`head -3 "${refetch_script}.tmp" | tail -1 | sed 's/.*mkdir "\([^"]\+\)"/\1/' | sed 's/\([()]\)/\\\1/g' | sed 's/'\''/\\'\''/g'`;
	ex --noplugin -E -n -X '+4,$s/\('"${podcast_dir}"'\)\-/\1\//g' '+wq!' "${refetch_script}.tmp" > /dev/null;
	
	if( `wc -l "${refetch_script}.tmp" | sed 's/^\([0-9]\+\)\ .*/\1/g'` > 0 ) then
		printf '#\!/bin/tcsh -f\n' >! "${refetch_script}";
		cat "${refetch_script}.tmp" >> "${refetch_script}";
		chmod +x "${refetch_script}";
		"${refetch_script}";
		if(! ${?keep_script} ) rm -fv "${refetch_script}";
	endif
	if(! ${?keep_script} ) rm -fv "${refetch_script}.tmp";
end

if( ${?grep_options} ) then
	setenv GREP_OPTIONS "${grep_options}";
	unset grep_options;
endif

if( ${?keep_script} ) unset keep_script;
if( ${?debug_enabled} ) unset debug_enabled;
