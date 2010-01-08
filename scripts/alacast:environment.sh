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
	export ALACAST_PATH="/projects/cli/alacast";
	export PATH="${PATH}:${ALACAST_PATH}/bin:${ALACAST_PATH}/scripts:${ALACAST_PATH}/helpers/gpodder-0.11.3-hacked/bin:${ALACAST_PATH}/helpers/gpodder-0.11.3-hacked/helper-scripts";


	# $ALACAST_OPTIONS acts like arguments to alacast.php when no command line arguments are given:
	export ALACAST_OPTIONS='--logging --titles-append-pubdate --strip-characters=#;!';

	# when no option are given alacast:cli uses the environmental variable: $ALACAST_OPTIONS.
	alias "alacast:php:cli:sync"="${ALACAST_PATH}/alacast.php --with-defaults=sync";
	# --with-defaults prepends $ALACAST_OPTIONS
	alias "alacast:php:cli:update"="${ALACAST_PATH}/alacast.php --with-defaults=update";
fi
