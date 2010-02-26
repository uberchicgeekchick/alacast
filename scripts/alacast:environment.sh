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
	export ALACASTS_CLI_PATH="/projects/cli/alacast";
	export PATH="${PATH}:${ALACASTS_CLI_PATH}/bin:${ALACASTS_CLI_PATH}/scripts:${ALACASTS_CLI_PATH}/helpers/gpodder-0.11.3-hacked/bin:${ALACASTS_CLI_PATH}/helpers/gpodder-0.11.3-hacked/helper-scripts";
	export ALACASTS_GTK_PATH="/projects/gtk/alacast";
	export PATH="${PATH}:${ALACASTS_GTK_PATH}/bin:${ALACASTS_GTK_PATH}/scripts";


	# $ALACAST_OPTIONS acts like arguments to alacast.php when no command line arguments are given:
	export ALACASTS_OPTIONS='--logging --titles-append-pubdate --playlist=m3u --strip-characters=#;!';

	# when no option are given alacast:cli uses the environmental variable: $ALACAST_OPTIONS.
	alias "alacast:php:cli:sync"="${ALACASTS_CLI_PATH}/bin/alacast.php --with-defaults=sync";
	# --with-defaults prepends $ALACAST_OPTIONS
	alias "alacast:php:cli:update"="${ALACASTS_CLI_PATH}/bin/alacast.php --with-defaults=update";
fi
