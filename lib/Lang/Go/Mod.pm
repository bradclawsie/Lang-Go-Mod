package Lang::Go::Mod;
use warnings;
use strict;
use Carp qw(croak);
use English qw(-no_match_vars);
use Path::Tiny qw(path);

# ABSTRACT: Parse and model go.mod files

our $VERSION   = '0.001';
our $AUTHORITY = 'cpan:bclawsie';

sub read_go_mod_sum {
    my $go_mod_path = shift || croak 'missing: path to go.mod';
    my $go_sum_path = shift || croak 'missing: path to go.sum';

    my $go_mod_content = path($go_mod_path)->slurp_utf8 || croak "$ERRNO";
    my $go_sum_content = path($go_sum_path)->slurp_utf8 || croak "$ERRNO";

    my $m = {};

    return $m;
}

1;

__END__

=head1 NAME

Lang::Go::Mod

=head1 SYNOPSIS

Parse and model go.mod files.

=head1 DESCRIPTION

Parse and model go.mod files.

=head1 LICENSE 

Lang::Go::Mod is licensed under the same terms as Perl itself.

https://opensource.org/licenses/artistic-license-2.0

=cut
