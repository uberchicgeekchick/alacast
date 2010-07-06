#!/bin/tcsh -f
init:
	if(! -o /dev/$tty ) then
		set stdout=/dev/null;
		set stderr=/dev/null;
	else
		set stdout=/dev/stdout;
		set stderr=/dev/stdout;
	endif
#goto init;
	
dependencies_check:
	set scripts_basename="alacast:catalogs:load.tcsh";
	set dependencies=("${scripts_basename}");# "${scripts_alias}");
	@ dependencies_index=0;
	
	while( $dependencies_index < ${#dependencies} )
		@ dependencies_index++;
		
		set dependency=$dependencies[$dependencies_index];
		
		foreach program("`where "\""${dependency}"\""`")
			if( -x "${program}" ) \
				break;
			unset program;
		end
		
		if(! ${?program} ) then
			printf "One or more of [%s] dependencies couldn't be found.\n\t%s requires: [%s] and [%s] couldn't be found." "${scripts_basename}" "${dependencies}" "${scripts_basename}" "${dependency}" > ${stderr};
			@ errno=-501;
			goto exit_script;
		endif
	end
	
	unset dependency dependencies dependencies_index;
#goto dependencies_check;


load_catalogs:
	cd "`dirname "\""${program}"\""`/../data/xml/opml";
	set catalogs=( "ip.tv" "vodcasts" "library" "podcasts" "radiocasts" "music" );
#goto load_catalogs;


exit_script:
	if( ${?program} ) \
		unset program;
	unset scripts_basename dependency dependencies dependencies_index;
	if( ${?errno} ) \
		@ errno=0;
	set status=$errno;
	exit $errno;
#goto exit_script;
