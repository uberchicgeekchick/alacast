#!/bin/tcsh -f
if(! ${?0} ) then
	printf "Cannot source.\n";
	exit -1;
endif

onintr exit_script;
@ arg=0;
@ argc=${#argv};

while( $arg < $argc )
	@ arg++;
	if(!( "$argv[$arg]" != "--help" &&  "$argv[$arg]" != "-h" && -e "$argv[$arg]" )) then
		goto usage;
	endif

	if(! ${?ffprobefile_list} ) \
		set ffprobefile_list="`mktemp --tmpdir .filenames.for.ffprobe.XXXXXXXX`";
	set value="$argv[$arg]";
	if( `printf "%s" "${value}" | sed -r 's/^(\/).*$/\1/'` != "/" ) \
		set value="${cwd}/${value}";
	set value_file="`mktemp --tmpdir .escaped.relative.filename.value.XXXXXXXX`";
	printf "%s" "${value}" >! "${value_file}";
	ex -s '+s/\v([\"\!\$\`])/\"\\\1\"/g' '+wq!' "${value_file}";
	set escaped_value="`cat "\""${value_file}"\""`";
	rm -f "${value_file}";
	unset value_file;
	set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/(\/)(\/)/\1/g' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	while( "`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^(.*)(\/\.\/)(.*)"\$"/\2/'`" == "/./" )
		set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/(\/\.\/)/\//' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	end
	while( "`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/^(.*)(\/\.\.\/)(.*)"\$"/\2/'`" == "/../" )
		set escaped_value="`printf "\""%s"\"" "\""${escaped_value}"\"" | sed -r 's/(.*)(\/[^.]{2}[^/]+)(\/\.\.\/)(.*)"\$"/\1\/\4/' | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`";
	end
	set value="`printf "\""%s"\"" "\""${escaped_value}"\""`";
	unset escaped_value;
	if( ${?debug} ) \
		printf "Adding <%s> to <%s>\n" "${value}" "${ffprobefile_list}";
	printf "%s\n" "${value}" >> "${ffprobefile_list}";
end
if(! ${?ffprobefile_list} ) then
	goto usage;
else if(! -e "${ffprobefile_list}" ) then
	goto usage;
else if(!( `wc -l "${ffprobefile_list}" | sed -r 's/^([0-9]+).*$/\1/'` > 0 )) then
	goto usage;
endif

set seconds;
set minutes;
set hours;
foreach original_filename("`cat "\""${ffprobefile_list}"\"" | sed -r 's/(["\"\$\!\`"])/"\""\\\1"\""/g'`")
	ex -s '+1d' '+wq!' "${ffprobefile_list}";
	set extension="`printf "\""%s"\"" "\""${original_filename}"\"" | sed -r 's/^(.*)\.([^.]+)"\$"/\2/g'`";
	set filename="`printf "\""%s"\"" "\""${original_filename}"\"" | sed -r 's/^(.*)\.([^.]+)"\$"/\1/g'`";
	
	if(! -e "${filename}.${extension}" ) then
		printf "\t**Skipping:** <file://%s.%s>.  It no longer exists.\n" "${filename}" "${extension}";
		continue;
	endif
	
	if( ${?debug} ) \
		printf "\t**Looking for:** <file://%s.%s>.\n" "${filename}" "${extension}";
	set ffprobe_info_file="`mktemp --tmpdir "\"".escaped.ffprobe.info.XXXXXX"\""`";
	ffprobe "${filename}.${extension}" >&! "${ffprobe_info_file}";
	set duration="`egrep 'Duration:' "\""${ffprobe_info_file}"\""`";
	
	if( "${duration}" == "" ) then
		printf "\t**Skipping:** <file://%s.%s>.  Its duration could not be determind.\n\tffprobe returned: %s\n" "${filename}" "${extension}" "`tail -1 "\""${ffprobe_info_file}"\""`";
		rm -f "${ffprobe_info_file}";
		unset ffprobe_info_file duration these_minutes these_seconds these_hours duration;
		continue;
	endif
	rm -f "${ffprobe_info_file}";
	unset ffprobe_info_file;
	
	set these_hours="`printf "\""%s"\"" "\""${duration}"\"" | sed -r 's/.*Duration: ([0-9]{2}):([0-9]{2}):([0-9]{2}).*"\$"/\1/'`";
	set these_minutes="`printf "\""%s"\"" "\""${duration}"\"" | sed -r 's/.*Duration: ([0-9]{2}):([0-9]{2}):([0-9]{2}).*"\$"/\2/'`";
	set these_seconds="`printf "\""%s"\"" "\""${duration}"\"" | sed -r 's/.*Duration: ([0-9]{2}):([0-9]{2}):([0-9]{2}).*"\$"/\3/'`";
	
	if( ${?debug} || ${?debug_length} ) \
		printf "Length of %s\n\t%s\n" "${original_filename}" "${duration}";
	
	if( "${seconds}" != "" ) \
		set seconds="${seconds}+";
	set seconds="${seconds}${these_seconds}";
	
	if( "${minutes}" != "" ) \
		set minutes="${minutes}+";
	set minutes="${minutes}${these_minutes}";
	
	if( "${hours}" != "" ) \
		set hours="${hours}+";
	set hours="${hours}${these_hours}";
	
	unset these_minutes these_seconds these_hours duration;
end

set extra_minutes=`printf "(${seconds})/60\n" | bc`;
set seconds=`printf "(${seconds})%%60\n" | bc`;
set hours=`printf "${hours}+((${extra_minutes}+${minutes})/60)\n" | bc`;
set minutes=`printf "(${extra_minutes}+${minutes})%%60\n" | bc`;

if( $seconds < 10 ) \
	set seconds="0${seconds}";

if( $minutes < 10 ) \
	set minutes="0${minutes}";

if( $hours < 10 ) \
	set hours="0${hours}";

printf "hours: %s; minutes: %s; seconds: %s\n" "${hours}" "${minutes}" "${seconds}";

exit_script:
	if( ${?ffprobefile_list} ) then
		if( -e "${ffprobefile_list}" ) then
			rm -f "${ffprobefile_list}";
		endif
	endif
	if( ${?ffprobe_file} ) then
		if( -e "${ffprobe_file}" ) then
			rm -f "${ffprobe_file}";
		endif
	endif
	exit 0;
#goto exit_script;

usage:
	printf "Usage: %s ffprobefiles..." "`basename "\""${0}"\""`";
	goto exit_script;
#goto usage:
