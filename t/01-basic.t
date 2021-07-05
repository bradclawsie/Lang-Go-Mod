package main;
use File::Spec;
use Test2::V0;
use Test2::Tools::Exception;
use Lang::Go::Mod qw(read_go_mod_sum);

my $samples_path = File::Spec->catfile(File::Spec->curdir(), 't', 'samples'); 
my $go_mod_path = File::Spec->catfile($samples_path, '1', 'go.mod');
my $go_sum_path = File::Spec->catfile($samples_path, '1', 'go.sum');
my $m;
ok(
    lives {
        $m = read_go_mod_sum($go_mod_path, $go_sum_path);
    }
) or note($@);

done_testing;

1;
