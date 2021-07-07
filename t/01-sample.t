package main;
use File::Spec;
use Test2::V0;
use Test2::Tools::Exception;
use Lang::Go::Mod qw(read_go_mod_sum);

my $samples_path = File::Spec->catfile( File::Spec->curdir(), 't',  'samples' );
my $go_mod_path  = File::Spec->catfile( $samples_path,        '01', 'go.mod' );
my $go_sum_path  = File::Spec->catfile( $samples_path,        '01', 'go.sum' );
my $m;
ok(
    lives {
        $m = read_go_mod_sum( $go_mod_path, $go_sum_path );
    }
) or note($@);

is( ref($m),      'HASH',                          'returned ref is hash' );
is( $m->{module}, 'github.com/example/my-project', 'module label' );
is( $m->{go},     '1.16',                          'go version label' );
is( $m->{'require'}->{'github.com/google/uuid'}->{version},
    'v1.2.0', 'require' );
is( $m->{replace}->{'github.com/example/my-project/pkg/env'},
    './pkg/env', 'replace' );

done_testing;

1;
