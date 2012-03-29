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

package Scotty::Sensor;

use strict;
use warnings;

my %services;
my %pipes;

sub new {
    my ($class, $oclass) = @_;

    my $self = {
	_class => $oclass,
    };

    bless $self, $class;
    return $self;
}

sub add {
    my $service = shift(@_);

    unless(exists($services{$service})) {
	eval("require Scotty::Sensor::$service;");
	die($@) if $@;

	eval("\$services{\$service} = Scotty::Sensor::${service}->new();");
	die($@) if $@;
    }

    $services{$service}->register(@_);
}

sub start_worker() {
    $main::logger->info("Forking working processes...");
    foreach my $service (keys %services) {
	$services{$service}->worker();
    }
}


sub register {
    my ($self) = @_;

    die(${$self}{_class} . " did not override register method!\n");
}

sub series() {
    my ($self) = @_;

    die(${$self}{_class} . " did not override series method!\n");
}

sub targets() {
    my ($self) = @_;

    die(${$self}{_class} . " did not override targets method!\n");
}

sub worker() {
    my ($self) = @_;

    pipe RH, WH;
    my $pid = fork();
    die "Cannot fork!\n" unless(defined($pid));
    if($pid == 0) {
	close(RH);
	return *WH;
    }
    close(WH);

    return undef;
}

1;
