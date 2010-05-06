# AMMS client module (C) 2009

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

use LWP::UserAgent;
use URI::Escape;

my $VERSION = 0.1;

my $http;
my $base_uri;
my $err_desc;

sub new { 

    my $self = {};
    $http = LWP::UserAgent->new;
    $http->agent (__PACKAGE__ . "/$VERSION");

    bless $self;
    return $self;
}

sub connect {
    
    my ($self, $uri) = @_;

    $base_uri = $uri;
    my $res = $http->get ($uri);

    return $res->is_success;
}

sub exe {
    
    my $self = shift;
    my $cmd  = join (' ', @_);

    $cmd = uri_escape ($cmd);
    my $res = $http->get ("$base_uri?q=$cmd");

    unless ($res->is_success) {
        $self->{err_desc} = $res->status_line;
        return undef;
    }

    my (@res, $line);

    @res = split (/\n/, $res->content);

    if ($res [0] =~ /^ERR/){
        $res [0] =~ s/^ERR //o;
        $self->{err_desc} = $res [0];
        return undef;
    }
    return wantarray ? @res : $res[0];
}

1;

