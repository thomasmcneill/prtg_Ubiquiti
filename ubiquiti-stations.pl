#!/usr/bin/perl

use strict;
#use warnings;

use LWP::UserAgent;
use HTTP::Cookies;
use JSON;


my $host = $ARGV[0];
my $username = $ARGV[1];
my $password = $ARGV[2];
my $station = $ARGV[3];
my $value1 = $ARGV[4];
my $value2 = $ARGV[5];

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
  $response = $browser->get( "https://${host}/${directory}/sta.cgi" );

  my $records = decode_json($response->content);
  for my $record (@$records) 
  {
    for my $key(keys(%$record)) 
    {
      my $val = $record->{$key};
      #print "$key: $val\r";
    }

    #print $station." ".$record->{"name"}." ".$record->{"mac"}."\r";
    if($station eq $record->{"name"} || $station eq $record->{"mac"} )   
    {
      if($value1 eq "stats") 
      {
        for my $stat_records ($record->{"stats"}) 
        {
			print $stat_records->{$value2}.":OK\r";
			exit;
	  #for my $stat_key(keys(%$stat_records)) 
          #{
	    #my $stat_val = $stat_records->{$stat_key};
	    #print "$stat_key: $stat_val\r";
	  #}
        }
      } 
      if($value1 eq "airmax") 
      {
        for my $stat_records ($record->{"stats"}) 
        {
			print $stat_records->{$value2}.":OK\r";
			exit;

	  #for my $stat_key(keys(%$stat_records)) 
          #{
	    #my $stat_val = $stat_records->{$stat_key};
	    #print "$stat_key: $stat_val\r";
	  #}
        }
      } 
      if($value1 ne "airmax" && $value1 ne "stats")
      {
		if  ($record->{$value1} ne "") {
			print $record->{$value1}.":OK\r";
			exit;
		}
      }
    }
  }
}
print "-1:ERROR\r"
