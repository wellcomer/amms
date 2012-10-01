package AMMS::Lib;

use Exporter::Tidy
    all  => [ qw(conf locate locate_pid kmg fdate ts runas enc dec encf decf xb xs) ],
    json => [ qw(enc dec encf decf xb xs) ];

use strict;
#use utf8;

use Carp;
use Fcntl qw(LOCK_EX LOCK_UN SEEK_SET);
use File::Spec::Functions;
use Config::General;
use User::pwent;
use JSON::XS;

my %conf;

sub conf {

    my $file = shift;
    $file ||= "/etc/amms/amms.conf";

    unless (exists $conf {$file}){
        %{$conf{$file}} = Config::General::ParseConfig (-ConfigFile => $file, -InterPolateVars => 1, -AutoTrue => 1);
    }
    return $conf {$file};
}

sub locate {

    my $conf = conf ();
    return catfile ($conf->{amms_dat}, @_);
}

sub locate_pid {

    my $conf = conf ();
    return catfile ($conf->{pid_base}, @_);
}

sub kmg { # human readable values
    
    my $bytes = shift;
    my $value = $bytes;
            
    my $g = 1073741824;
    my $m = 1048576;
    my $k = 1024;
                        
    if ($bytes >= $g){
        $value = sprintf ("%.2f%s", $bytes / $g, "G");
    }
    elsif ($bytes >= $m){
        $value = sprintf ("%.1f%s", $bytes / $m, "M");
    }
    elsif ($bytes >= $k){
        $value = sprintf ("%.1f%s", $bytes / $k, "K");
    }
    
    $value =~ s/\.0+\s/ /g;
    
    return $value;
}

sub fdate { # format input date for grep

    my $input = shift;

    my ($date, $time);

    if ($input =~ /to*d*a*y*/i){
        $input = substr (ts (time), 0, 8); # date only
    }
    elsif ($input =~ /(y+)e*s*t*e*r*d*a*y*/i){ # yyyyesterday 
        my $days_before = length ($1);
        $input = substr (ts (time - $days_before * 86400), 0, 8);
    }

    ($date, $time) = split (/\s+/, $input, 2);

    $date = substr ($date, 0, 8);
    $time = substr ($time, 0, 6);

    $date .= "." x (8 - length ($date));
    $time .= "." x (6 - length ($time));

    return "\"$date $time\"";
}

sub ts { # now timestamp

    my $time = shift;

    my ($sec,$min,$hour,$mday,$mon,$year) = localtime ($time);
    
    $year += 1900; $mon += 1;

    my $ts = sprintf ("%04d%02d%02d %02d%02d%02d", $year, $mon, $mday, $hour, $min, $sec);

    return $ts;
}

sub runas {

    my $user = shift;

    my $pwn = getpwnam ($user) || carp "Unknown user $user";
    my %res;

    if (POSIX::setgid ($pwn->gid)){
        $res {gid} = $pwn->gid;
    }
    if (POSIX::setuid ($pwn->uid)){
        $res {uid} = $pwn->uid;
    }
    return %res;
}

sub enc {
    return JSON::XS->new->pretty(1)->ascii(1)->encode ($_[0]);
}

sub dec {
    return JSON::XS->new->utf8(1)->decode ($_[0]);
}

sub encf {
    
    my ($fh, $data) = @_;

    return unless ($data);
    return unless (flock ($fh, LOCK_EX));
    return unless (truncate ($fh, 0));
    return unless (seek ($fh, 0, SEEK_SET));

    print $fh enc ($data);
    flock ($fh, LOCK_UN);
}

sub decf {
    my $fh = shift;
    my $data = do { local $/; <$fh> };
    $data = dec ($data) if ($data);
    $data ||= {};
    return $data;
}

sub xb { # extract response body
    my $res = shift;
    return $res->{b};
}

sub xs { # extract response status
    my $res = shift;
    return $res->{s};
}

1;
