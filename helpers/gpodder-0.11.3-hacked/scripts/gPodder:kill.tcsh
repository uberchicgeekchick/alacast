#!/bin/tcsh -f
set signal=-9;
set total=18;
set timeout=46;# How long to wait between sending each interupt signal.
set gPodderCmd="./gpodder-0.11.3-hacked";

set status=0;

goto parse_argv;

kill_progie:
	printf "Sending gPodder's PIDs the interupt signal.\nI'll be sending %s interupts and waiting %s seconds each time:\n" $total $timeout;
	foreach pid( `/bin/ps -A -c -F | /bin/grep --perl-regexp "^[0-9]+[\t\ ]+([0-9]+).*[0-9]{2}:[0-9]{2}:[0-9]{2}\ python ${gPodderCmd}" | sed -r 's/^[0-9]+[\\ ]+([0-9]+).*[\r\n]*/\1/'` )
		@ killed=0;
		printf "Sending %s's PID: %s signal: %s" $gPodderCmd $pid $signal;
		while( $killed < $total && `/bin/ps -A -c -F | /bin/grep --perl-regexp "^[0-9]+[\t\ ]+([0-9]+).*[0-9]{2}:[0-9]{2}:[0-9]{2}\ python ${gPodderCmd}" | sed -r "s/^[0-9]+[\\ ]+.*(${pid}).*[\r\n]*/\1/"` == $pid )
			kill -$signal $pid;
			printf ".";
			if( $killed > 0 ) sleep $timeout;
			@ killed++;
		end
		printf "[done]\n";
	end

end_script:
	exit ${status};

usage:
	printf "gPodder:kill.tcsh - Sends a specified signal, defaults to -9, to all running instances of gPodder a given amount of times.\n\tOptions:\n\t--signal=[Signal]\tSIGNAL may be any number between 0-15.\n\t\tOr any constant supported by kill.  E.G.: INT or HUP.\n\t--send-interupt=#\t# for how many times to send gPodder the interupt signal.\n\t--timeout=#\tHow many seconds to wait between sending each interupt.  This number must be greater than 4.\n";
	goto exit_script;
#usage

parse_argv:
	while( "${1}" != "" )
		set argument="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/\-\-([^=]+)(=?)(.*)"\$"/\1/'`";
		set equals="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/\-\-([^=]+)(=?)(.*)"\$"/\2/'`";
		set value="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/\-\-([^=]+)(=?)(.*)"\$"/\3/'`";
		if( "${value}" == "" && "${equals}" == "" && "${2}" != "" )	\
			set value="${2}";
		
		switch( "${argument}" )
			case "help":
				goto usage;
				breaksw;
			
			case "signal":
				set signal=$value;
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

