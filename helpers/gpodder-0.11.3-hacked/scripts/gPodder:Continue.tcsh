#!/bin/tcsh -f

main:
	set signal="-INT"; # What signal to send.
	set repeat=72; # How many times to send the signal.
	set sleep=24; # How long to wait between sending each signal.
	set gPodderCmd="./gpodder-0.11.3-hacked";

	set status=0;

	goto parse_argv;
	#parse_argv will either call [usage:], which calls [main_quit:], or returns to/goes to/calls: [kill_progie:].
#main

kill_progie:
	printf "Sending gPodder's PIDs the %s signal.\nI'll be sending %s interupts and waiting %s seconds each time:\n" $signal $repeat $sleep;
	foreach pid( `/bin/ps -A -c -F | /bin/grep --perl-regexp "^[0-9]+[\t\ ]+([0-9]+).*[0-9]{2}:[0-9]{2}:[0-9]{2}\ python ${gPodderCmd}" | sed -r 's/^[0-9]+[\\ ]+([0-9]+).*[\r\n]*/\1/'` )
		@ killed=0;
		printf "Interupting %s's PID: %s " $gPodderCmd $pid;
		while( $killed < $repeat && `/bin/ps -A -c -F | /bin/grep --perl-regexp "^[0-9]+[\t\ ]+([0-9]+).*[0-9]{2}:[0-9]{2}:[0-9]{2}\ python ${gPodderCmd}" | sed -r "s/^[0-9]+[\\ ]+.*(${pid}).*[\r\n]*/\1/"` == $pid )
			kill $signal $pid;
			if( $repeat == 1 ) \
				break;
			printf ".";
			sleep $sleep;
			@ killed++;
		end
		printf "[finished]\n";
	end
	goto main_quit;
#kill_progie
	
main_quit:
	exit ${status};
#main_quit

usage:
	printf "gPodder:Continue.tcsh - Sends [signal] to all running instances of gPodder a given amount of times.\n\tOptions:\n\t--send-interupt=#\t# for how many times to send gPodder the signal.\n\t--timeout=#\tHow many seconds to wait between sending each signal.  This number must be greater than 4.\n";
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
			
			case "signal":
			case "interupt":
			case "send-signal":
			case "send-interupt":
				if( `printf "${value}" | sed -r 's/^-?(HUP|INT|QUIT|ILL|TRAP|ABRT|BUS|FPE|KILL|USR1|SEGV|USR2|PIPE|ALRM|TERM|STKFLT|CHLD|CONT|STOP|TSTP|TTIN|TTOU|URG|XCPU|XFSZ|VTALRM|PROF|WINCH|POLL|PWR|SYS|RTMIN|RTMIN\+1|RTMIN\+2|RTMIN\+3|RTMAX\-3|RTMAX\-2|RTMAX\-1|RTMAX)$//` == "" ) then
					if( `printf "${value}" | sed -r 's/^(-).*/\1/'` != "-" ) then
						set signal="-${value}";
					else
						set signal="${value}";
					endif
				else if( `printf "${value}" | sed -r 's/^([0-9\-]+)$//'` == "" ) then
					set signal=$value;
				endif
				breaksw;
			
			case "loop":
			case "repeat":
				if( `printf "${value}" | sed -r 's/^([0-9]+)$//'` == "" ) \
					set repeat=$value;
				breaksw;
			
			case "delay":
			case "sleep":
				if( `printf "${value}" | sed -r 's/^([0-9]+)$//'` == "" ) \
					set sleep=$value;
				breaksw;
			
			case "debug":
				if(! ${?debug} ) \
					set debug;
				breaksw;
			
			case "enable":
				switch("$value")
					case "debug":
						if(! ${?debug} ) \
							set debug;
					breaksw;
				endsw
				breaksw;
		endsw
		shift;
	end
	goto kill_progie;
#parse_argv

