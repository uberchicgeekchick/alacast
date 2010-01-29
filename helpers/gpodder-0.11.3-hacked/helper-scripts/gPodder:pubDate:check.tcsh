#!/bin/tcsh -f
if( -e "${HOME}/.config/gpodder/gpodder.conf" ) then
	set download_dir = "`grep 'download_dir' '${HOME}/.config/gpodder/gpodder.conf' | cut -d= -f2 | cut -d' ' -f2`"
	if( "${download_dir}" != "" && -d "${download_dir}" ) then
		if( "${download_dir}" != "${cwd}" ) set starting_dir="${cwd}";
		cd "${download_dir}";
	endif
endif

while("${1}" !="")
	set option="`printf "\""${1}"\"" | sed -r 's/[\-]{1,2}([^\=]+)=?['\''"\""]?(.*)['\''"\""]?/\1/'`";
	set value="`printf "\""${1}"\"" | sed -r 's/[\-]{1,2}([^\=]+)=?['\''"\""]?(.*)['\''"\""]?/\2/'`";
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
	ex -E -n -X --noplugin '+1,$s/[\r\n]\+//' '+wq' index.swp >> /dev/null;
	cat index.swp | sed -r "s/.*<title>([^<]+)<\/title>.*<title>([^<]+)<\/title>.*<pubDate>([^<]+)<\/pubDate>.*/released on \3: <\1>'s episode: <\2> -- ${escaped_cwd}\/${p}/g" >> "${pubDate_log}";
end
if( -e ./index.swp ) rm ./index.swp;

if( ${?starting_dir} ) then
	cd "${starting_dir}";
endif

set status=0;

exit_script:
	exit ${status}

usage:
	printf "Usage:\n\t%s [--ouput=]\n" "`basename '${0}'`";
	set status=-1;
	goto exit_script;

