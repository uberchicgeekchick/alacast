#!/bin/tcsh -f
set total=18;
set timeout=46;# How long to wait between sending each interupt signal.
set gPodderCmd="./gpodder-0.11.3-hacked";

set status=0;

goto parse_argv;

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

end_script:
	exit ${status};

usage:
	printf "gPodder:Continue.tcsh - Sends interupt signal to all running instances of gPodder a given amount of times.\n\tOptions:\n\t--send-interupt=#\t# for how many times to send gPodder the interupt signal.\n\t--timeout=#\tHow many seconds to wait between sending each interupt.  This number must be greater than 4.\n";
	goto exit_script;
#usage

parse_argv:
	if(! ${?eol} ) setenv eol '$';
	while( "${1}" != "" )
		set argument="`echo '${1}' | sed -r 's/\-\-([^=]+)=?(.*)${eol}/\1/'`";
		set value="`echo '${1}' | sed -r 's/\-\-([^=]+)=?(.*)${eol}/\2/'`";
		
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

