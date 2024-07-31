#!/usr/bin/perl -w
use strict;
use 5.010;
open my $SRC_FP,'<','PQCsignKAT_128.rsp' or die 'open PQCsignKAT_128.rsp failure!!!';
while(<$SRC_FP>){
	if(/sm = (?<sm>.*)$/){
		my $sm = $+{sm};
		open my $DES_FP,'>','sm.txt' or die 'open sm.txt failure!!!';
		while(length($sm) > 64){
			printf $DES_FP substr($sm,0,64)."\n";
			$sm = substr($sm,64);
		}
		printf $DES_FP "$sm\n";
		close $DES_FP;
	}
}
close $SRC_FP;
