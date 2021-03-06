# scotty-rel - Scotty RELOADED Network Management Tool
#
# Authors:
#   Thomas Liske <thomas@fiasko-nw.net>
#
# Copyright Holder:
#   2012 - 2013 (C) Thomas Liske [https://fiasko-nw.net/~thomas/tag/scotty]
#   2014        (C) IBH IT-Service GmbH [http://www.ibh.de/OSS/Scotty]
#
# License:
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this package; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
#

package Scotty::IDMapper;

use strict;
use warnings;

sub new {
    my ($class) = @_;

    my $self = {
	idmap => { },
	nextid => 0,
    };

    bless $self, $class;
    return $self;
}

sub getID {
    my ($self, $name) = @_;

    unless(exists($self->{idmap}->{$name})) {
	$self->{idmap}->{$name} = hex($self->{nextid});
	$self->{nextid}++;
    }

    return $self->{idmap}->{$name};
}

sub getMap {
    my ($self) = @_;

    return $self->{idmap};
}

1;
