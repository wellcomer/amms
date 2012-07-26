# AMMS client module (C) 2012

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

use lib "/usr/lib/amms";
use AMMS::Lib qw(:json);

use HTTP::Lite;

my $VERSION = 0.2;

my ($http, $uri, $err_desc);

sub new { 

    my $self = {};
    bless $self;
    return $self;
}

sub connect {
    
    my ($self, $uri) = @_;

    $self->{uri} = $uri;
    $self->{http} = new HTTP::Lite;

    my $req = $self->{http}->request ($uri);

    return 1 if ($req == 200);
    return undef;
}

sub exe {
    
    my ($self, $function, $req) = @_;

    $req->{f} = $function;
    $req = enc ($req);

    $self->{http}->reset;
    $self->{http}->prepare_post ({q=>$req});

    my $res = $self->{http}->request ($self->{uri});

    if ($res != 200){
        $self->{err_desc} = $self->{http}->status_message || "Connection timeout";
        return undef;
    }

    $res = $self->{http}->body;
    $res = dec ($res) if ($res);

    return $res;
}

1;

