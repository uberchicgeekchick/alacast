#!/bin/tcsh -f

alias ex 'ex -E -n -X --noplugin';
if( -e "${HOME}/.config/gpodder/gpodder.conf" ) then
	set download_dir = "`grep 'download_dir' '${HOME}/.config/gpodder/gpodder.conf' | cut -d= -f2 | cut -d' ' -f2`"
	if( "${download_dir}" != "" && -d "${download_dir}" ) then
		if( "${download_dir}" != "${cwd}" ) then
			set old_owd="${cwd}";
			cd "${download_dir}";
		endif
	endif
endif

while("${1}" !="")
	set dashes="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?/\1/'`";
	set option="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?/\2/'`";
	set equals="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?/\3/'`";
	set value="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/([\-]{1,2})([^\=]+)(=?)['\''"\""]?(.*)['\''"\""]?/\4/'`";
	if( "${value}" == "" && "${equals}" == "" && "${2}" != "" )	\
		set value="${2}";
	
	switch("${option}")
		case "output":
			set pubDate_log="${value}";
			breaksw
		default:
			printf "%s is an unsupported option" "${1}";
			goto usage:
			breaksw
	endsw
	shift;
end

if(! ${?pubDate_log} ) set pubDate_log="${cwd}/pubDate.log";
printf "Podcast pubDates will be saved to: %s\n" "${pubDate_log}";

if( -e "${pubDate_log}" ) rm "${pubDate_log}";
touch "${pubDate_log}";

set escaped_cwd="`echo '${cwd}' | sed -r 's/([/.])/\\\1/g'`";
#echo "${escaped_cwd}";
#exit;
foreach index(*/index.xml)
	cp "${index}" ./index.swp;
	set escaped_index="`echo "\""${index}"\"" | sed -r 's/([/.])/\\\1/g'`";
	ex '+1,$s/\v\r\n?\_$//' '+1,$s/\n//g' '+wq' index.swp > /dev/null;
	ex "+1,"\$"s/\v.*\<channel\>\<title\>([^<]+)\<\/title\>.*\<item\>\<title\>([^<]+)\<\/title\>.*\<url\>(.*)(\.[^<\.?]+)([\.?]?[^<]*)\<\/url\>.*\<pubDate\>([^<]+)\<\/pubDate\>.*/${escaped_cwd}\/${escaped_index} \-\- <\1>'s episode: <\2>, released on: \6\4/g" '+wq!' index.swp > /dev/null;
	cat index.swp \
		#| sed -r "s/.*\<title\>([^<]+)\<\/title\>.*\<url\>(.*)\.([^<\.?]+)([\.?]?[^<]*)\<\/url\>.*\<pubDate\>([^<]+)\<\/pubDate\>.*/\<\1\>'s episode: \<\2\>, released on: \5\4 -- ${escaped_cwd}\/${escaped_index}/g" \
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
	unset escaped_index index;
end

	sort "${pubDate_log}" \
		| sed -r 's/(.*)\ \:\ (.*)\ \-\-\ (.*)/\1 \:\ \3\ \<file\:\/\/\2\>/' \
		#| sed -r 's/(.*)\ \:\ (.*)/\2/' \
		#| sed -r 's/(.*)\ \-\-\ (.*)/\2/' \
	>! "${pubDate_log}.swp";
	
mv -f "${pubDate_log}.swp" "${pubDate_log}";


if( ${?old_owd} ) then
	cd "${owd}";
	set owd="${old_owd}";
	unset old_owd;
endif

set status=0;

exit_script:
	exit ${status}

usage:
	printf "Usage:\n\t%s [--ouput=]\n" "`basename '${0}'`";
	set status=-1;
	goto exit_script;

