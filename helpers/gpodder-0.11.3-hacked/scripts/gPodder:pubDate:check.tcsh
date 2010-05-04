#!/bin/tcsh -f
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

set escaped_cwd="`echo '${cwd}' | sed -r 's/([\/\.])/\\\1/g'`";
#echo "${escaped_cwd}";
#exit;
foreach p(*)
	if(!( -d "${p}" && -e "${p}/index.xml" )) continue;
	cp "${p}/index.xml" ./index.swp;
	ex -E -n -X --noplugin '+1,$s/\v\r\n?\_$//' '+1,$s/\n//g' '+wq' index.swp >> /dev/null;
	cat index.swp | sed -r "s/.*<title>([^<]+)<\/title>.*<title>([^<]+)<\/title>.*<pubDate>([^<]+)<\/pubDate>.*/released on \3: <\1>'s episode: <\2> -- ${escaped_cwd}\/${p}/g" >> "${pubDate_log}";
end
if( -e ./index.swp ) rm ./index.swp;

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

