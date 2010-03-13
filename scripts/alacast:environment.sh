#!/bin/sh
if test `echo "${0}" | sed -r 's/^[^\.]*(sh)$/\1/'` != "sh"; then
	owd=`pwd`;
	cd `dirname "${0}"`;
	cwd=`pwd`;
	source=`basename "${0}"`;
	printf "%s sets up alacast's environmental settings\n%s should be sourced and not run directly.\nUsage:\n\tsource %s\n" "${source}" "${source}" "${cwd}/${source}";
	cd "${owd}"
	unset source owd cwd;
else
	if ! test -z ${TCSH_RC_DEBUG}; then
		printf "Setting up Alacast v1's and v2's environment @ %s\n" `date "+%I:%M:%S%P"`;
	fi
	
	if test -e "${HOME}/.alacast/alacast.ini"; then
		set alacast_ini="${HOME}/.alacast/alacast.ini";
	elif test -e "${HOME}/.alacast/profiles/${USER}/alacast.ini"; then
		set alacast_ini="${HOME}/.alacast/profiles/${USER}/alacast.ini";
	elif test -e "`dirname '${0}'`../data/profiles/${USER}/alacast.ini"; then
		set alacast_ini="`dirname '${0}'`../data/profiles/${USER}/alacast.ini";
	elif test -e "`dirname '${0}'`../data/profiles/default/alacast.ini"; then
		set alacast_ini="`dirname '${0}'`../data/profiles/default/alacast.ini";
	fi
	
	if test ! -z "${alacast_ini}" && test -e "${alacast_ini}"; then
		export ALACAST_INI="${alacast_ini}";
	fi
	
	export ALACASTS_CLI_PATH="/projects/cli/alacast";
	export PATH="${PATH}:${ALACASTS_CLI_PATH}/bin:${ALACASTS_CLI_PATH}/scripts:${ALACASTS_CLI_PATH}/helpers/gpodder-0.11.3-hacked/bin:${ALACASTS_CLI_PATH}/helpers/gpodder-0.11.3-hacked/helper-scripts";
	export ALACASTS_GTK_PATH="/projects/gtk/alacast";
	export PATH="${PATH}:${ALACASTS_GTK_PATH}/bin:${ALACASTS_GTK_PATH}/scripts";
	
	export ALACASTS_OPTIONS='--logging --titles-reformat-numerical --titles-append-pubdate --playlist=m3u --strip-characters=#;!';
	
	# when no option are given alacast:cli uses the environmental variable: $ALACAST_OPTIONS.
	alias "alacast:php:cli:sync"="${ALACASTS_CLI_PATH}/bin/alacast.php --with-defaults=sync";
	# --with-defaults prepends $ALACAST_OPTIONS
	alias "alacast:php:cli:update"="${ALACASTS_CLI_PATH}/bin/alacast.php --with-defaults=update";
fi
