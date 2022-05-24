package Koha::Plugin::Fi::NatLibFi::Biblios;

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

use base qw(Koha::Plugins::Base);

our $VERSION = "{VERSION}";

our $metadata = {
    name            => 'REST API plugin for Koha for modifying biblios',
    author          => 'The National Library of Finland and others',
    date_authored   => '2020-08-28',
    date_updated    => '1900-01-01',
    minimum_version => '21.12.00.000',
    maximum_version => undef,
    version         => $VERSION,
    description     => 'This plugin implements API endpoints required'
                     . ' for modifying biblio records'
};

sub new {
    my ( $class, $args ) = @_;

    ## We need to add our metadata here so our base class can access it
    $args->{'metadata'} = $metadata;
    $args->{'metadata'}->{'class'} = $class;

    ## Here, we call the 'new' method for our base class
    ## This runs some additional magic and checking
    ## and returns our actual $self
    my $self = $class->SUPER::new($args);

    return $self;
}

sub api_routes {
    my ( $self, $args ) = @_;

    my $spec_dir = $self->mbf_dir();

    my $schema = JSON::Validator::Schema::OpenAPIv2->new;
    my $spec = $schema->resolve($spec_dir . '/openapi.yaml');

    if( $schema->errors && @{$schema->errors} ) {
        die 'SCHEMA ERRORS: ' . join("\n", map { $_->message } @{$schema->errors}) . "\n";
    }

    return $self->_convert_refs_to_absolute($spec->data->{'paths'}, 'file://' . $spec_dir . '/');
}

sub api_namespace {
    my ( $self ) = @_;

    return 'natlibfi';
}

sub _convert_refs_to_absolute {
    my ( $self, $hashref, $path_prefix ) = @_;

    foreach my $key (keys %{ $hashref }) {
        if ($key eq '$ref') {
            if ($hashref->{$key} =~ /^(\.\/)?openapi/) {
                $hashref->{$key} = $path_prefix . $hashref->{$key};
            }
        } elsif (ref $hashref->{$key} eq 'HASH' ) {
            $hashref->{$key} = $self->_convert_refs_to_absolute($hashref->{$key}, $path_prefix);
        } elsif (ref($hashref->{$key}) eq 'ARRAY') {
            $hashref->{$key} = $self->_convert_array_refs_to_absolute($hashref->{$key}, $path_prefix);
        }
    }
    return $hashref;
}

sub _convert_array_refs_to_absolute {
    my ( $self, $arrayref, $path_prefix ) = @_;

    my @res;
    foreach my $item (@{ $arrayref }) {
        if (ref($item) eq 'HASH') {
            $item = $self->_convert_refs_to_absolute($item, $path_prefix);
        } elsif (ref($item) eq 'ARRAY') {
            $item = $self->_convert_array_refs_to_absolute($item, $path_prefix);
        }
        push @res, $item;
    }
    return \@res;
}

1;
