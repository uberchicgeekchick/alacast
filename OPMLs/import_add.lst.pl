#!/usr/bin/perl
use strict;

open(CATALOG, "<add.lst");
while(read(CATALOG, $_)){
	print("gpodder --add=$_");
}

