package Koha::Plugin::Fi::NatLibFi::Biblios::Biblios;

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# This program comes with ABSOLUTELY NO WARRANTY;

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use C4::Biblio;
use Koha::Biblios;

=head1 Koha::Plugin::Fi::NatLibFi::Biblios::Biblios

=head2 Methods

=head3 add

Add a new Biblio object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $marcflavour = C4::Context->preference('marcflavour');
        my $marcxml = $c->req->body;
        my $record = MARC::Record::new_from_xml( $marcxml, 'UTF-8', $marcflavour );
        my ($biblionumber, $biblioitemnumber) = C4::Biblio::AddBiblio( $record, '' );

        if (defined $biblionumber) {
            return $c->render(
                status  => 201,
                openapi => { biblio_id => $biblionumber }
            );
        } else {
            return $c->render(
                status  => 500,
                openapi => {}
            );
        }
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 update

Update Biblio object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $marcflavour = C4::Context->preference('marcflavour');
        my $marcxml = $c->req->body;
        my $record = MARC::Record::new_from_xml( $marcxml, 'UTF-8', $marcflavour );
        my $biblionumber = $c->validation->param('biblio_id');
        my $biblio = Koha::Biblios->find($biblionumber);

        unless ( $biblio ) {
            return $c->render(
                status  => 404,
                openapi => {}
            );
        }

        my $no_error = C4::Biblio::ModBiblio( $record, $biblio->biblionumber, $biblio->frameworkcode );

        if ( $no_error ) {
            return $c->render(
                status  => 204,
                openapi => {}
            );
         } else {
            return $c->render(
                status  => 500,
                openapi => {}
            );
         }
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
