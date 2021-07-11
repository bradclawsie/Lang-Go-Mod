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

our @EXPORT_OK = qw(read_go_mod parse_go_mod parse_by_line);

sub read_go_mod {
    my $use_msg     = 'use: read_go_mod(go_mod_path)';
    my $go_mod_path = shift || croak $use_msg;

    my $go_mod_content = path($go_mod_path)->slurp_utf8 || croak "$ERRNO";

    return parse_go_mod($go_mod_content);
}

sub parse_go_mod {
    my $use_msg        = 'use: parse_go_mod(go_mod_content)';
    my $go_mod_content = shift || croak $use_msg;

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

    $m->{exclude}   = _exclude($go_mod_content);
    $m->{replace}   = _replace($go_mod_content);
    $m->{'require'} = _require($go_mod_content);

    return $m;
}

sub _exclude {
    my $go_mod_content = shift || croak 'use: _exclude(go_mod_content)';

    my $m = {};

    # optional exclude ( ... )
    if ( $go_mod_content =~ /^exclude\s+[(]([^)]+)[)]$/msx ) {
        my $exclude_lines = $1;
        for my $line ( split /\n/msx, $exclude_lines ) {
            next unless ( $line =~ /\S/msx );
            if ( $line =~ /\s*(\S+)\s+(\S+)/msx ) {
                $m->{$1} = [] unless ( defined $m->{$1} );
                push @{ $m->{$1} }, $2;
            }
            else {
                croak "line $line malformed exclude syntax";
            }
        }
    }

    # exclude per-line
    for
      my $exclude ( $go_mod_content =~ /^(?:exclude\s+([^(]\S+\s+\S+))\s*$/gmx )
    {
        my ( $module, $version ) = split /\s+/msx, $exclude;
        $m->{$module} = [] unless ( defined $m->{$module} );
        push @{ $m->{$module} }, $version;
    }

    return $m;
}

sub _replace {
    my $go_mod_content = shift || croak 'use: _replace(go_mod_content)';

    my $m = {};

    # optional replace ( ... )
    if ( $go_mod_content =~ /^replace\s+[(]([^)]+)[)]$/msx ) {
        my $replace_lines = $1;
        for my $line ( split /\n/msx, $replace_lines ) {
            next unless ( $line =~ /\S/msx );
            if ( $line =~ /^\s*(\S+)\s+=>\s+(\S+)\s*$/msx ) {
                croak "duplicate replace for $1"
                  if ( defined $m->{$1} );
                $m->{$1} = $2;
            }
            else {
                croak "line $line malformed replace syntax";
            }
        }
    }

    # replace per-line
    for my $replace (
        $go_mod_content =~ /^(?:replace\s+([^(]\S+\s+=>\s+\S+))\s*$/gmx )
    {
        my ( $source, $replacement ) = split /\s+=>\s+/msx, $replace;
        croak "duplicate replace for $source"
          if ( defined $m->{$source} );
        $m->{$source} = $replacement;
    }

    return $m;
}

sub _require {
    my $go_mod_content = shift || croak 'use: _require(go_mod_content)';

    my $m = {};

    # optional require ( ... )
    if ( $go_mod_content =~ /^require\s+[(]([^)]+)[)]$/msx ) {
        my $require_lines = $1;
        for my $line ( split /\n/msx, $require_lines ) {
            next unless ( $line =~ /\S/msx );
            if ( $line =~ /^\s*(\S+)\s+(\S+).*$/msx ) {
                croak "duplicate require for $1"
                  if ( defined $m->{$1} );
                $m->{$1} = $2;
            }
            else {
                croak "line $line malformed require syntax";
            }
        }
    }

    # require per-line
    for
      my $require ( $go_mod_content =~ /^(?:require\s+([^(]\S+\s+\S+)).*$/gmx )
    {
        my ( $module, $version ) = split /\s+/msx, $require;
        croak "duplicate require for $module"
          if ( defined $m->{$module} );
        $m->{$module} = $version;
    }

    return $m;
}

sub parse_by_line {
    my $go_mod_content = shift || croak 'use: parse_by_line(go_mod_content)';

    my ( $m_exclude, $m_replace, $m_require, $m ) = ( {}, {}, {}, {} );
    my ( $excludes, $replaces, $requires ) = ( 0, 0, 0 );
  LINE: for my $line ( split /\n/msx, $go_mod_content ) {
        next LINE if ( $line =~ /^\s*$/msx );
        if ($excludes) {
            if ( $line =~ /^\s*[)]\s*$/msx ) {
                $excludes = 0;
            }
            elsif ( $line =~ /\s*(\S+)\s+(\S+)/msx ) {
                $m_exclude->{$1} = [] unless ( defined $m_exclude->{$1} );
                push @{ $m_exclude->{$1} }, $2;
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
                  if ( defined $m_replace->{$1} );
                $m_replace->{$1} = $2;
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
                  if ( defined $m_require->{$1} );
                $m_require->{$1} = $2;
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
        elsif ( $line =~ /^(?:exclude\s+(\S+\s+\S+))\s*$/msx ) {

            # single exclude
            $m_exclude->{$1} = [] unless ( defined $m_exclude->{$1} );
            push @{ $m_exclude->{$1} }, $2;
        }
        elsif ( $line =~ /^(?:replace\s+(\S+\s+=>\s+\S+))\s*$/msx ) {

            # single replace
            croak "duplicate replace for $1"
              if ( defined $m_replace->{$1} );
            $m_replace->{$1} = $2;
        }
        elsif ( $line =~ /^(?:require\s+(\S+\s+\S+)).*$/msx ) {

            # single require
            croak "duplicate require for $1"
              if ( defined $m_require->{$1} );
            $m_require->{$1} = $2;
        }
        else {
            croak "unknown line content: $line";
        }
        next LINE;
    }

    # check that module and go were set
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
