package Lang::Go::Mod;
use warnings;
use strict;
use Carp qw(croak);
use English qw(-no_match_vars);
use Exporter qw(import);
use Path::Tiny qw(path);

# ABSTRACT: Parse and model go.mod files

our $VERSION   = '0.001';
our $AUTHORITY = 'cpan:bclawsie';

our @EXPORT_OK = qw(read_go_mod_sum parse_go_mod_sum);

sub read_go_mod_sum {
    my $use_msg     = 'use: read_go_mod_sum(go_mod_path, go_sum_path)';
    my $go_mod_path = shift || croak $use_msg;
    my $go_sum_path = shift || croak $use_msg;

    my $go_mod_content = path($go_mod_path)->slurp_utf8 || croak "$ERRNO";
    my $go_sum_content = path($go_sum_path)->slurp_utf8 || croak "$ERRNO";

    return parse_go_mod_sum( $go_mod_content, $go_sum_content );
}

sub parse_go_mod_sum {
    my $use_msg = 'use: parse_go_mod_sum(go_mod_content, go_sum_content)';
    my $go_mod_content = shift || croak $use_msg;
    my $go_sum_content = shift || croak $use_msg;

    my $m = {};

    # module ...
    if ( $go_mod_content =~ /^module\s+(\S+)$/msx ) {
        $m->{module} = $1;
    }
    else {
        croak 'no "module ..." found in go.mod';
    }

    # go ...
    if ( $go_mod_content =~ /^go\s+(\S+)$/msx ) {
        $m->{go} = $1;
    }
    else {
        croak 'no "go ..." found in go.mod';
    }

    # optional require ( ... )
    if ( $go_mod_content =~ /^require\s+[(]([^)]+)[)]$/msx ) {
        $m->{'require'} = {};
        for my $line ( split /\n/msx, $1 ) {
            next unless ( $line =~ /\S/msx );
            if ( $line =~ /\s*(\S+)\s+(\S+)/msx ) {
                $m->{'require'}->{$1} = { version => $2 };
            }
            else {
                croak "line $line malformed require syntax";
            }
        }
    }

    # optional replace ( ... )
    if ( $go_mod_content =~ /^replace\s+[(]([^)]+)[)]$/msx ) {
        $m->{replace} = {};
        for my $line ( split /\n/msx, $1 ) {
            next unless ( $line =~ /\S/msx );
            if ( $line =~ /\s*(\S+)\s+[=][>]\s+(\S+)/msx ) {
                $m->{replace}->{$1} = $2;
            }
            else {
                croak "line $line malformed replace syntax";
            }
        }
    }

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
