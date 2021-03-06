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

package Scotty::Sensor::snmp;

use Scotty::Sensor;
use strict;
use warnings;
use Data::Dumper;
use SNMP;
our @ISA = qw(Scotty::Sensor);

sub new {
    my ($class, $service, $config) = @_;
    my $self = Scotty::Sensor->new($class, $service);

    get_config($self, $config);

    bless $self, $class;
    return $self;
}

sub get_config($$) {
    my ($self, $config) = @_;

    foreach my $node ($config->get_nodelist()) {
	my %config = (
	    oid => undef,
	    label => undef,
	    color => 'black',
	    unit => '',
	    min => 0,
	    max => undef,
	    monitor => undef,
	);

	foreach my $key (keys %config) {
	    my $value = $node->findvalue($key);
	    $config{$key} = $value if(defined($value));
	
	    push(@{$self->{query}->{$key}}, (defined($value) ? $value : $config{$key}));
	}

	die "Config value 'oid' not defined!\n"
	    unless(defined($config{oid}));

    }
}

sub register {
    my ($self, $idmap, $series, $host, $params) = @_;
    $self->{idmap} = $idmap;
    my $href = $self->{hosts}->{$host};

    # create SNMP session
    $href->{session} = new SNMP::Session(
	DestHost => $host,
	Community => 'public',
	Version => '2c',
	UseSprintValue => 0,
	UseNumeric => 1,
    ) unless(defined($href->{session}));

    my $id = $self->{idmap}->getID("${host}_$self->{service}_".join('_', @{$params}));
    my @oids;
    foreach my $o (@{$self->{query}->{oid}}) {
	my $oid = $o;
	while($oid =~ /%(\d+)(|([^%]+))?%/) {
	    my ($i, $alt) = ($1, $3);
	    my $val = ($i - 1 <= $#{$params} ? $params->[$i - 1] : $alt);
	    die "Parameter #$i of '${host}_$self->{service}_".join('_', @{$params})."' is undefined!\n"
		unless(defined($val));
	    $oid =~ s/%$i(|[^%]+)?%/$val/;
	    unless($oid =~ /^[\d.]+$/) {
		my $noid = &SNMP::translateObj($oid) ;
		die "Failed translating SNMP OID: $oid\n"
		    unless(defined($noid));
		$oid = $noid;
	    }
	}
	push(@oids, [$oid]);
	$href->{oids}->{$oid}++;
    }
    $href->{oidmap}->{$id} = \@oids;

    $self->{hosts}->{$host} = $href unless(defined($self->{hosts}->{$host}));

    $series->{$id} = {
	label => $self->{query}->{label},
	interval => 5,
	unit => $self->{query}->{unit},
	color => $self->{query}->{color},
	min => $self->{query}->{min},
	max => $self->{query}->{max},
    };

    $main::logger->info("Service $self->{service} registers: $host (".join(', ', @{$params}).')');
}

sub targets {
    my ($self) = @_;

    return keys %{$self->{idmap}};
}

sub worker {
    my ($self) = @_;

    my $wh = $self->SUPER::worker();
    if(defined($wh)) {
	$main::logger->info("Service alive: $self->{service}");

	foreach my $host (keys %{$self->{hosts}}) {
	    my $href = $self->{hosts}->{$host};
	    $href->{vlobj} = new SNMP::VarList(
		map { [$_] } keys %{$href->{oids}}
	    );
	}

	my %cntrs;
	my %sesserrs;
	while(1) {
	    my %res;
	    foreach my $host (keys %{$self->{hosts}}) {
		my $href = $self->{hosts}->{$host};
		my @ret = $href->{session}->get( $href->{vlobj} );

		if ($href->{session}->{ErrorStr}) {
		    if(!defined($sesserrs{$host}) || ($sesserrs{$host} ne $href->{session}->{ErrorStr})) {
			$main::logger->warning("SNMP failed ($host): $href->{session}->{ErrorStr}");
			$sesserrs{$host} = $href->{session}->{ErrorStr};
		    }
		    next;
		}
		delete($sesserrs{$host});

		foreach my $id (keys %{ $href->{oidmap} }) {
		    my @res;
		    foreach my $oid (@{ $href->{oidmap}->{$id} }) {
			push(@res, map {
			    my $v = (${$_}[2] =~ /^-?\d+$/ ? ${$_}[2] : undef);

			    if(defined($v)) {
				if(${$_}[3] =~ /^(COUNTER|GAUGE|INTEGER)/) {
				    $v += 0;

				    if(${$_}[3] =~ /^(INTEGER)/) {
					my $e = SNMP::mapEnum($_->[0], $_->[2]);
					$v = ($e eq 'unknown' ? "$e($v)" : $e)
					    if(defined($e));
                                    }
				    elsif(${$_}[3] =~ /^COUNTER/) {
					my $k = $id.${$oid}[0];
					if(exists($cntrs{$k})) {
					    my $w = $cntrs{$k};
					    $cntrs{$k} = $v;
					    $v -= $w;
					}
					else {
					    $cntrs{$k} = $v;
					    $v = undef;
					}
				    }
				}
			    }

			    $v;
			} grep { "${$_}[0].${$_}[1]" eq ${$oid}[0] } @{$href->{vlobj}});
		    }
		    $res{$id} = \@res;
		}
	    }
	    $self->push_hashref($wh, \%res);
	    sleep(5);
	}
    }
}

1;
