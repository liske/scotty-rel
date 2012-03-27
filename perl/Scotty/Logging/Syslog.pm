# scotty-rel - Scotty RELOADED Network Management Tool
#
# Authors:
#   Thomas Liske <thomas@fiasko-nw.net>
#
# Copyright Holder:
#   2012 (C) Thomas Liske [http://fiasko-nw.net/~thomas/]
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

use Scotty::Logging;
package Scotty::Logging::Syslog;
use strict;
use warnings;
use Sys::Syslog;
our @ISA = qw(Scotty::Logging);

sub new {
    my ($class) = @_;
    my $self = Scotty::Logging->new($class);

    bless $self, $class;

	openlog('scotty-rel', 'pid', Sys::Syslog::LOG_DAEMON);

    return $self;
}

sub info {
    my ($self, $m) = @_;
	
	syslog(Sys::Syslog::LOG_INFO, "<" . caller() . "> $m");
}

sub warning {
    my ($self, $m) = @_;
	
	syslog(Sys::Syslog::LOG_WARNING, "<" . caller() . "> $m");
}

sub error {
    my ($self, $m) = @_;
	
	syslog(Sys::Syslog::LOG_ERR, "<" . caller() . "> $m");
}

1;
