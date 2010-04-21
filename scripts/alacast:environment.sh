#!/bin/sh
if test `echo "${0}" | sed -r 's/^[^\.]*(sh)$/\1/'` != "sh"; then
	owd=`pwd`;
	cd `dirname "${0}`;
	cwd=`pwd`;
	source=`basename "${0}`;
	printf "%s sets up alacast's environmental settings\n%s should be sourced and not run directly.\nUsage:\n\t%ssource %s%s" "${source}" "${scripts_name}" '`' "${cwd}/${scripts_name}" '`';
	cd "${owd}"
	unset source owd cwd;
else
	if test -z ${TCSH_RC_DEBUG} && test "${1}" == "--debug"; then
		export TCSH_RC_DEBUG="TRUE";
	fi
	
	if ! test -z ${TCSH_RC_DEBUG}; then
		printf "Setting up Alacast v1's and v2's environment @ %s\n" `date "+%I:%M:%S%P"`;
	fi
	
	export PATH=`printf "%s" "${PATH}" | sed -r 's/\/projects\/(cli|gtk)\/alacast(\/[^\:]*\:)?//g'`;
	
	if test ${alacasts_path}; then
		unset alacasts_path;
	fi
	
	#the PERLLIB environment variable
	#export PERLLIB=/path/to/my/dir
	
	#the PERL5LIB environment variable
	#export PERL5LIB=/path/to/my/dir
	
	export ALACAST_GTK_PATH="/projects/gtk/alacast";
	
	alacast_gtk_paths="bin scripts";
	for alacast_gtk_path in ${alacast_gtk_paths}; do
		if test -z ${TCSH_RC_DEBUG}; then
			printf "Attempting to add: [file://%s] to your PATH:\t\t" "${alacast_gtk_path}";
		fi
		alacast_gtk_path="${ALACAST_GTK_PATH}/${alacast_gtk_path}";
		echo $alacast_gtk_path;
		escaped_alacast_gtk_path=`printf "%s" "${alacast_gtk_path}" | sed -r 's/\//\\\//g'`;
		echo $escaped_alacast_gtk_path;
		if test `printf "${PATH}" | sed -r 's/.*\:(${escaped_alacast_gtk_path}).*/\1/g'` == "${alacast_gtk_path}"; then
			continue;
		fi
		
		if ! test -z ${TCSH_RC_DEBUG}; then
			printf "[added]\n";
		fi
		
		if ! test ${alacasts_path}; then
			alacasts_path="${alacast_gtk_path}";
		else
			alacasts_path="${alacasts_path}:${alacast_gtk_path}";
		fi
	done
	unset alacast_gtk_path alacast_gtk_paths;
	
	if test ! -z "${alacast_ini}" && test -e "${alacast_ini}"; then
		export ALACAST_INI="${alacast_ini}";
	fi
	unset alacast_ini;
	
	
	export ALACASTS_CLI_PATH="/projects/cli/alacast";
	alacast_cli_paths="bin scripts helpers/gpodder-0.11.3-hacked/bin helpers/gpodder-0.11.3-hacked/scripts";
	for alacast_cli_path in ${alacast_cli_paths}; do
		if test -z ${TCSH_RC_DEBUG}; then
			printf "Attempting to add: [file://%s] to your PATH:\t\t" "${alacast_cli_path}";
		fi
		alacast_cli_path="${ALACAST_CLI_PATH}/${alacast_cli_path}";
		escaped_alacast_cli_path=`printf "%s" "${alacast_cli_path}" | sed -r 's/\//\\\//g'`;
		if test `printf "%s" "${PATH}" | sed -r 's/.*\:(${escaped_alacast_cli_path}).*/\1/g'` == "${alacast_cli_path}"; then
			continue;
		fi
		
		if ! test -z ${TCSH_RC_DEBUG}; then
			printf "[added]\n";
		fi
		
		if ! test ${alacasts_path}; then
			alacasts_path="${alacast_cli_path}";
		else
			alacasts_path="${alacasts_path}:${alacast_cli_path}";
		fi
	done
	unset alacast_cli_path alacast_cli_paths;
	
	
	alias "alacast:feed:fetch-all:enclosures.tcsh"="${ALACASTS_GTK_PATH}alacast:feed:fetch-all:enclosures.tcsh --disable=logging"
	
	export ALACASTS_OPTIONS='--logging --titles-reformat-numerical --titles-append-pubdate --playlist=m3u --strip-characters=#;!';
	
	# when no option are given alacast:cli uses the environmental variable: $ALACAST_OPTIONS.
	alias "alacast:php:cli:sync"="${ALACASTS_CLI_PATH}/bin/alacast.php --with-defaults=sync";
	# --with-defaults prepends $ALACAST_OPTIONS
	alias "alacast:php:cli:update"="${ALACASTS_CLI_PATH}/bin/alacast.php --with-defaults=update";
	
	if test -e "${HOME}/.alacast/alacast.ini"; then
		alacast_ini="${HOME}/.alacast/alacast.ini";
	elif test -e "${HOME}/.alacast/profiles/${USER}/alacast.ini"; then
		alacast_ini="${HOME}/.alacast/profiles/${USER}/alacast.ini";
	elif test -e "${ALACAST_GTK_PATH}/data/profiles/${USER}/alacast.ini"; then
		alacast_ini="${ALACAST_GTK_PATH}/data/profiles/${USER}/alacast.ini";
	elif test -e "${ALACAST_GTK_PATH}/data/profiles/default/alacast.ini"; then
		alacast_ini="${ALACAST_GTK_PATH}/data/profiles/default/alacast.ini";
	elif test -e "${ALACAST_CLI_PATH}/data/profiles/${USER}/alacast.ini"; then
		alacast_ini="${ALACAST_CLI_PATH}/data/profiles/${USER}/alacast.ini";
	elif test -e "${ALACAST_CLI_PATH}/data/profiles/default/alacast.ini"; then
		alacast_ini="${ALACAST_CLI_PATH}/data/profiles/default/alacast.ini";
	fi
fi
