#!/usr/bin/perl

use strict;
#use warnings;

use LWP::UserAgent;
use HTTP::Cookies;
use JSON;


my $host = $ARGV[0];
my $username = $ARGV[1];
my $password = $ARGV[2];
my $value1 = $ARGV[3];
my $value2 = $ARGV[4];
my $value3 = $ARGV[5];

my $cookie_jar = HTTP::Cookies->new();
my $browser  = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0},);
my $response = '';
my $json = JSON->new();
my $directory = '';




$browser->cookie_jar($cookie_jar);

$response = $browser->get(
  "https://${host}/login.cgi"
);

$response = $browser->post(
  "https://${host}/login.cgi",
  Content_Type => 'form-data',
  Content => [
    username => $username,
    password => $password,
  ],
);


$response = $browser->get("https://${host}/index.cgi");


if ($response->content =~ m/<link rel="shortcut icon" href="\/.*\/favicon.ico".*>/) 
{
  $directory = $&;
  $directory =~ s/<link.*href="\/(.*)\/.*".*>/$1/;
  $response = $browser->get( "https://${host}/${directory}/ifstats.cgi" );

  my $main_hash = decode_json($response->content);
  #print $main_hash."\r\n";
  #print $value1."\r\n";
  if( ($value1 eq "interfaces") && ($main_hash->{"interfaces"} ne "") ) 
  {
    # Array will be returned
	my $interfaces = $main_hash->{"interfaces"};
#		print "Intefaces: ".$interfaces."\r\n";
#	    print "$key: $main_hash->{$key}\r\n"
		for my $element (@$interfaces) 	# Each element is an interface eth0 ar0 wlan0
		{
			#print "element: $element ".$element->{"stats"}."\r\n";
			my $ifname = $element->{"ifname"};
			my $stats_hash = $element->{"stats"};
			if(($value2 eq "list") || ($value2 eq "" )) 
			{
				print "ifname: $ifname\r\n";
			}
			if( $value2 eq $ifname) {
				if($value3 eq "rx_bytes") 
				{
					print $stats_hash->{"rx_bytes"}.":OK";
					exit;
				}
				if($value3 eq "tx_bytes") 
				{
					print $stats_hash->{"tx_bytes"}.":OK";
					exit;
				}
			}
			
		}		
	}
  #}

#    for my $interface_records ($main_record->{"interfaces"}) 
#    {
#		print $interface_records;
#		exit;
 #   }
	print "-1:Error";
}
