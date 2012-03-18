
# aus - Agentless Universal Shutdown
#
# $Id: XenE5.pm 18 2009-09-23 17:53:33Z liske $
#
# Authors:
#   Thomas Liske <liske@ibh.de>
#
# Copyright Holder:
#   2009 (C) IBH IT-Service GmbH [http://www.ibh.de/]
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

=pod

=head1 NAME

AUS::Client::XenE5 - Perl AUS extension for host shutdowns using XenServer 5 API.

=head1 SYNOPSIS

  use AUS::Client::XenE5;

=head1 DESCRIPTION

AUS::Client::XenE5 provides an L<AUS::Client::Generic> implementation
using the XenServer 5 API (RPC::XML).

=head1 METHODS

=over 4

=cut

package AUS::Client::XenE5;

use RPC::XML;
use RPC::XML::Client;
use AUS::Client::Generic;
use strict;
use warnings;
our @ISA = qw(AUS::Client::Generic);

=pod

=back

=head1 SEE ALSO

L<AUS::Client::Generic>, L<RPC::XML>,
L<aus(1)>, L<ausd(1)>

=head1 AUTHOR

Thomas Liske <liske@ibh.de>

=head1 COPYRIGHT

Copyright 2009 by IBH IT-Service GmbH [http://www.ibh.de/]

=cut

1;