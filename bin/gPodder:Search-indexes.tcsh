#!/bin/tcsh
if ( "${?1}" == "0" || "${1}" == "" ) then
	printf "Usage:\n\t%s [podcast_name]" $0
	exit -1
endif

search:
set gpodder_dl_dir = `grep "download_dir" ~/.config/gpodder/gpodder.conf | cut -d= -f2 | cut -d" " -f2`
foreach index ( `find "${gpodder_dl_dir}" -name index.xml` )
	/usr/bin/grep --color --perl-regexp --with-filename --line-number "${1}" "${index}"
end

shift
if ( "${?1}" != "0" && "${1}" != "" ) goto search
