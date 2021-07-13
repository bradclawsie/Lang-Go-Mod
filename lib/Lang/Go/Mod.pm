package Lang::Go::Mod;
use warnings;
use strict;
use Carp qw(croak);
use English qw(-no_match_vars);
use Exporter qw(import);
use Path::Tiny qw(path);
use experimental qw(switch);

# ABSTRACT: Parse and model go.mod files

our $VERSION   = '0.001';
our $AUTHORITY = 'cpan:bclawsie';

our @EXPORT_OK = qw(read_go_mod parse_go_mod);

sub read_go_mod {
    my $use_msg     = 'use: read_go_mod(go_mod_path)';
    my $go_mod_path = shift || croak $use_msg;

    my $go_mod_content = path($go_mod_path)->slurp_utf8 || croak "$ERRNO";

    return parse_go_mod($go_mod_content);
}

sub parse_go_mod {
    my $go_mod_content = shift || croak 'use: parse_go_mod(go_mod_content)';

    my $m = {};
    $m->{exclude}   = {};
    $m->{replace}   = {};
    $m->{'require'} = {};
    my ( $excludes, $replaces, $requires ) = ( 0, 0, 0 );

  LINE: for my $line ( split /\n/msx, $go_mod_content ) {
        next LINE if ( $line =~ /^\s*$/msx );
        if ($excludes) {
            if ( $line =~ /^\s*[)]\s*$/msx ) {
                $excludes = 0;
            }
            elsif ( $line =~ /\s*(\S+)\s+(\S+)/msx ) {
                $m->{exclude}->{$1} = [] unless ( defined $m->{exclude}->{$1} );
                push @{ $m->{exclude}->{$1} }, $2;
            }
            else {
                croak "malformed exclude line $line";
            }
            next LINE;
        }
        if ($replaces) {
            if ( $line =~ /^\s*[)]\s*$/msx ) {
                $replaces = 0;
            }
            elsif ( $line =~ /^\s*(\S+)\s+=>\s+(\S+)\s*$/msx ) {
                croak "duplicate replace for $1"
                  if ( defined $m->{replace}->{$1} );
                $m->{replace}->{$1} = $2;
            }
            else {
                croak "malformed replace line $line";
            }
            next LINE;
        }
        if ($requires) {
            if ( $line =~ /^\s*[)]\s*$/msx ) {
                $requires = 0;
            }
            elsif ( $line =~ /^\s*(\S+)\s+(\S+).*$/msx ) {
                croak "duplicate require for $1"
                  if ( defined $m->{'require'}->{$1} );
                $m->{'require'}->{$1} = $2;
            }
            else {
                croak "malformed require line $line";
            }
            next LINE;
        }

        if ( $line =~ /^module\s+(\S+)$/msx ) {
            $m->{module} = $1;
        }
        elsif ( $line =~ /^go\s+(\S+)$/msx ) {
            $m->{go} = $1;
        }
        elsif ( $line =~ /^exclude\s+[(]\s*$/msx ) {

            # beginning of exclude block
            $excludes = 1;
        }
        elsif ( $line =~ /^replace\s+[(]\s*$/msx ) {

            # beginning of replace block
            $replaces = 1;
        }
        elsif ( $line =~ /^require\s+[(]\s*$/msx ) {

            # beginning of require block
            $requires = 1;
        }
        elsif ( $line =~ /^exclude\s+(\S+)\s+(\S+)\s*$/msx ) {

            # single exclude
            $m->{$1} = [] unless ( defined $m->{exclude}->{$1} );
            push @{ $m->{exclude}->{$1} }, $2;
        }
        elsif ( $line =~ /^replace\s+(\S+)\s+=>\s+(\S+)\s*$/msx ) {

            # single replace
            croak "duplicate replace for $1"
              if ( defined $m->{replace}->{$1} );
            $m->{replace}->{$1} = $2;
        }
        elsif ( $line =~ /^require\s+(\S+)+\s+(\S+).*$/msx ) {

            # single require
            croak "duplicate require for $1"
              if ( defined $m->{'require'}->{$1} );
            $m->{'require'}->{$1} = $2;
        }
        else {
            croak "unknown line content: $line";
        }
        next LINE;
    }

    croak 'missing module line' unless ( defined $m->{module} );
    croak 'missing go line'     unless ( defined $m->{go} );

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

=head1 REFERENCE

https://golang.org/doc/modules/gomod-ref

=head1 LICENSE 

Lang::Go::Mod is licensed under the same terms as Perl itself.

https://opensource.org/licenses/artistic-license-2.0

=cut
