#!/bin/tcsh -f

main:
	set total=72; # How many times to send the interupt signal.
	set timeout=24; # How long to wait between sending each interupt signal.
	set gPodderCmd="./gpodder-0.11.3-hacked";

	set status=0;

	goto parse_argv;
	#parse_argv will either call [usage:], which calls [main_quit:], or returns to/goes to/calls: [kill_progie:].
#main

kill_progie:
	printf "Sending gPodder's PIDs the interupt signal.\nI'll be sending %s interupts and waiting %s seconds each time:\n" $total $timeout;
	foreach pid( `/bin/ps -A -c -F | /bin/grep --perl-regexp "^[0-9]+[\t\ ]+([0-9]+).*[0-9]{2}:[0-9]{2}:[0-9]{2}\ python ${gPodderCmd}" | sed -r 's/^[0-9]+[\\ ]+([0-9]+).*[\r\n]*/\1/'` )
		@ killed=0;
		printf "Interupting %s's PID: %s " $gPodderCmd $pid;
		while( $killed < $total && `/bin/ps -A -c -F | /bin/grep --perl-regexp "^[0-9]+[\t\ ]+([0-9]+).*[0-9]{2}:[0-9]{2}:[0-9]{2}\ python ${gPodderCmd}" | sed -r "s/^[0-9]+[\\ ]+.*(${pid}).*[\r\n]*/\1/"` == $pid )
			kill -INT $pid;
			printf ".";
			sleep $timeout;
			@ killed++;
		end
		printf "[done]\n";
	end
	goto main_quit;
#kill_progie
	
main_quit:
	exit ${status};
#main_quit

usage:
	printf "gPodder:Continue.tcsh - Sends interupt signal to all running instances of gPodder a given amount of times.\n\tOptions:\n\t--send-interupt=#\t# for how many times to send gPodder the interupt signal.\n\t--timeout=#\tHow many seconds to wait between sending each interupt.  This number must be greater than 4.\n";
	goto main_quit;
#usage

parse_argv:
	while( "${1}" != "" )
		set argument="`echo '${1}' | sed -r 's/[\-]{1,2}([^=]+)(=?)(.*)"\$"/\1/'`";
		set equals="`echo '${1}' | sed -r 's/[\-]{1,2}([^=]+)(=?)(.*)"\$"/\2/'`";
		set value="`echo '${1}' | sed -r 's/[\-]{1,2}([^=]+)(=?)(.*)"\$"/\3/'`";
		if( "${value}" == "" && "${equals}" == "" && "${2}" != "" )	\
			set value="${2}";
		
		switch( "${argument}" )
			case "help":
				goto usage;
				breaksw;
	
			case "send-interupt":
				if( $value > 0 ) set total=$value;
				breaksw;
			case "timeout":
				if( $value > 4 ) set timeout=$value;
				breaksw;
			case "enable":
				if( "$value" == "debug" ) set debug;
				breaksw;
		endsw
		shift;
	end
	goto kill_progie;
#parse_argv

