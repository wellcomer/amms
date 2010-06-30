# AMMS client module (C) 2010

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
	    
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
			    
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;

package AMMS::Client;

use HTTP::Lite;
use URI::Escape;

my $VERSION = 0.1;

my $http;
my $base_uri;
my $err_desc;
my $c2c;

sub new { 

    my $self = {};
    bless $self;
    return $self;
}

sub connect {
    
    my ($self, $uri) = @_;

    $self->{base_uri} = $uri;
    $self->{http} = new HTTP::Lite;

    my $req = $self->{http}->request ($uri);

    return 1 if ($req == 200);
    return undef;
}

sub exe {
    
    my $self = shift;
    my $cmd  = join (' ', @_);

    $self->{http}->reset;

    $cmd = uri_escape ($cmd);
    my $res = $self->{http}->request ($self->{base_uri} . "?q=$cmd");

    unless (defined $res) {
        $self->{err_desc} = $self->{http}->status_message;
        return undef;
    }

    my (@res, $line);

    @res = split (/\n/, $self->{http}->body);

    unless ($self->{c2c}){

        if ($res [0] =~ /^ERR/){
            $res [0] =~ s/^ERR //o;
            $self->{err_desc} = $res [0];
            return undef;
        }
    }
    return wantarray ? @res : $res[0];
}

sub c2c {

    my ($self, $val) = @_;
    $self->{c2c} = $val;
}

1;

