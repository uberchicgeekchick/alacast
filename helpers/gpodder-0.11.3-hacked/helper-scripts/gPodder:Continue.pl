#!/usr/bin/perl -w
use strict;
my $debug=0;
my $total=18;
my $timeout=46;# How long to wait between sending each interupt signal.
my $gPodder_PID_Search_Cmd="/bin/ps -A -c -F | /bin/grep --perl-regexp '^[0-9]+[\t\ ]+([0-9]+).*[0-9]{2}:[0-9]{2}:[0-9]{2}\ python ./gpodder-0.11.3-hacked' | sed -r 's/^[0-9]+[\\ ]+([0-9]+).*/\1/'";

sub display_usage{
	printf("gPodder:Continue.pl - Sends interupt signal to all running instances of gPodder a given amount of times.\n\tOptions:\n\t--send-interupt=#\t# for how many times to send gPodder the interupt signal.\n\t--timeout=#\tHow many seconds to wait between sending each interupt.  This number must be greater than 4.\n");
	exit(-1);
}#display_usage

sub parse_argument{
	if($_=~/^\-\-help$/ || $_=~/^\-h$/){ display_usage(); }
	
	my $argument=$_;
	$argument=~s/\-\-([^=]+)=?(.*)$/$1/;
	
	my $value=$_;
	$value=~s/\-\-([^=]+)=?(.*)$/$2/;
	
	if( "$argument" eq "" || $value < 1 ){return;}
	if("$argument" eq "send-interupt"){
		if($value>0){ $total=$value; }
	} elsif("$argument" eq "timeout"){
		if($value>4){ $timeout=$value; }
	} elsif("$argument" eq "enable"){
		if("$value" eq "debug"){ $debug=1; }
	}
}#parse_argument

sub parse_arguments{
	foreach(@ARGV){parse_argument($_);}
}#parse_argument

sub still_running{
	my $pid=$_;
	#foreach(`$gPodder_PID_Search_Cmd`){
	#	if( (chomp($_))==$pid ){debug("Comparing $_ against $pid.\n");return 0;}
	#}
	return 1;
}#still_running

sub interupt_pid{
	my $pid=$_;
	printf("Interupting %s ", $pid);
	for(my $i=0; $i<$total; $i++){
		if ($i){sleep($timeout);}
		`kill -INT $pid`;
		printf(".");
		if(still_running($pid)!=1){$i=$total;}
	}#for($i<$total)
	printf(" [done]\n");
}#interupt_pid

sub interupt_gpodder{
	printf("Sending gPodder's PIDs the interupt signal.\nI'll be sending %s interupts and waiting %s seconds each time:\n", $total, $timeout);
	#foreach(`/bin/ps -A -c -F | /bin/grep --perl-regexp --color '^[0-9]+[\t\ ]+([0-9]+).*[0-9]{2}:[0-9]{2}:[0-9]{2}\ python ./gpodder-0.11.3-hacked' | sed -r 's/^[0-9]+[\\ ]+([0-9]+).*/\1/'`){
	foreach(`$gPodder_PID_Search_Cmd`){
		interupt_pid((chomp($_)));
	}
}#interupt_gpodder

parse_arguments();
interupt_gpodder();

