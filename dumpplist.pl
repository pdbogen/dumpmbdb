#!/usr/bin/env perl

use warnings;
use strict;

use Data::Plist;
use Data::Plist::BinaryReader;
use Data::Dumper;

die( "usage: $0 <file.plist>" ) unless( scalar @ARGV == 1 );
die( "can't open target: ".$ARGV[0] ) unless( -e $ARGV[0] );

my $contents="";
my $reader = Data::Plist::BinaryReader->new;

my $FH;
open( $FH, "<", $ARGV[0] ) or die( "couldn't open $ARGV[0]: $!" );

my $plist = $reader->open_fh( $FH );

print( Dumper( $plist->data ) );
