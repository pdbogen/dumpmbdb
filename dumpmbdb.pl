#!/usr/bin/env perl

use warnings;
use strict;

use Digest::SHA qw( sha1_hex );

die( $0." <file.mbdb> (expected one argument, received ".scalar @ARGV.")" ) unless scalar @ARGV == 1;

my $FH;
open( $FH, "<", $ARGV[0] ) or die( "Failed to open $ARGV[0] for reading." );
binmode $FH;

my $magic;
my $c = read( $FH, $magic, 6 );
if( $c != 6 ) {
	die( "Failed to read 6 bytes of magic number. Could only read $c bytes." );
}

unless( $magic eq "mbdb\x05\x00" ) { die( "magic number doesn't match; this might not be an MBDB file." ); }

while(1) {
	my $domain = readString( $FH );
	my $path = readString( $FH );
	my $lt = readString( $FH );
	
	print(  "Domain:     $domain\n" );
	print(  "\tPath:       $path\n" );
	if( $lt eq "" ) {
		print(  "\tBackupHash: ".sha1_hex( $domain."-".$path ), "\n" );
	} else {
		print(  "\tBackupHash: None (node is a link)\n" );
	}
	print(  "\tLinkTarget: $lt\n" );
	print(  "\tDataHash:   ".printHex( readString( $FH ) ), "\n" );
	print(  "\tUnk:        ".readString( $FH ), "\n" );
	printf( "\tMode:       %o\n", readUint16( $FH ) );
	print(  "\tUnk:        ".readUint32( $FH ), "\n" );
	print(  "\tUnk:        ".readUint32( $FH ), "\n" );
	print(  "\tUID:        ".readUint32( $FH ), "\n" );
	print(  "\tGID:        ".readUint32( $FH ), "\n" );
	print(  "\tTime1:      ".localtime readUint32( $FH ), "\n" );
	print(  "\tTime2:      ".localtime readUint32( $FH ), "\n" );
	print(  "\tTime3:      ".localtime readUint32( $FH ), "\n" );
	print(  "\tFileSize:   ".readUint64( $FH ), "\n" );
	print(  "\tLink/Dir:   ".readUint8( $FH ), "\n" );
	my $propCount = readUint8( $FH );
	print(  "\tPropCnt:    $propCount\n" );
	for( my $i = 0; $i < $propCount; $i++ ) {
		print( "\t".readString( $FH )." => ".readString( $FH ), "\n" );
	}
}

sub printHex {
	my $string = shift;
	my $r = "";
	for( my $i = 0; $i < length $string; $i++ ) {
		$r .= sprintf( "%02x", ord(substr( $string, $i, 1 )) );
	}
	return $r;
}

sub readUint64 {
	my $FH = shift;
	my( $high, $low ) = ( readUint32( $FH ), readUint32( $FH ) );
	return ($high<<32) + $low;
}

sub readUint32 {
	my $FH = shift;
	my( $high, $low ) = ( readUint16( $FH ), readUint16( $FH ) );
	return ($high<<16) + $low;
}

sub readUint16 {
	my $FH = shift;
	my( $high, $low ) = ( readUint8( $FH ), readUint8( $FH ) );
	return ($high<<8) + $low;
}

sub readUint8 {
	my $FH = shift;
	my $byte;
	my $count = read( $FH, $byte, 1 );
	if( $count == 0 ) {
		die( "EOF" );
	}
	return ord( $byte );
}

sub readString {
	my $FH = shift;
	my $c;
	my $r = "";
	my $len = readUint16( $FH );
	if( $len == 65535 ) {
		return "";
	}
	for( my $i = 0; $i < $len; $i++ ) {
		my $count = read( $FH, $c, 1 );
		if( $count == 0 ) {
			die( "EOF" );
		}
		$r .= $c;
	}
	return $r;
}
