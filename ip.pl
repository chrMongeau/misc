#!/usr/bin/perl -w

use strict;
use CGI qw(:standard);
use lib qw(
  /home/bonsxanco/local/lib/perl/5.8 /home/bonsxanco/local/lib/perl/5.8.4 
  /home/bonsxanco/local/share/perl/5.8 /home/bonsxanco/local/share/perl/5.8.4 );
use Net::Whois::IANA;

my $url = 'http://ex.mongeau.net/';
my $date = localtime;
my $query = new CGI;
my $langpref = $query->cookie('lang');

if (referer() =~ /$url/) {
	print redirect($url . 'index.html');
} elsif (defined($langpref)) { # Cookie exists?
	if ($langpref eq 'it') {
		print redirect($url . 'it/');
	} elsif ($langpref eq 'en') {
		print redirect($url . 'en/');
	} elsif ($langpref eq 'fr') {
		print redirect($url . 'fr/');
	} elsif ($langpref eq 'it') {
		print redirect($url . 'it/');
	}
} else { # No cookie -> use IP
	my $ip = remote_host();
	my $iana = new Net::Whois::IANA;

	$iana->whois_query(-ip=>$ip);

	my $country = $iana->country();

	open(LOG, '>>/home/bonsxanco/ex.mongeau.net/iplogs.txt');
	printf LOG "IP: %15s ; COUNTRY: %s ; DATE: %s\n", $ip, $country, $date;
	close LOG;

	if ($country =~ /IT|SM|VA/) { # Italian
		my $cookie = $query->cookie(-name=>'lang', -value=>'it',);
		print redirect(-cookie=>$cookie, -location=>$url . 'it/');
	} elsif ($country =~ /FR|BE|FX|LU/) { # French
		my $cookie = $query->cookie(-name=>'lang', -value=>'fr',);
		print redirect(-cookie=>$cookie, -location=>$url . 'fr/');
	} elsif ($country =~ /US|GB|AU|IE|UK/) { # English
		my $cookie = $query->cookie(-name=>'lang', -value=>'en',);
		print redirect(-cookie=>$cookie, -location=>$url . 'en/');
	} elsif ($country =~ /ES|CO|AR|CL|EC|MX|VE|PE/) { # Spanish
		my $cookie = $query->cookie(-name=>'lang', -value=>'es',);
		print redirect(-cookie=>$cookie, -location=>$url . 'es/'
		);
	} elsif ($country =~ /BO|CR|DO|GT|PA|PY|SV|UY|PR|NI|CU/) { # again
		my $cookie = $query->cookie(-name=>'lang', -value=>'es',);
		print redirect(-cookie=>$cookie, -location=>$url . 'es/');
	} else {
		print redirect($url . 'index.html');
	}
}
