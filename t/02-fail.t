package main;
use File::Spec;
use Test2::V0;
use Test2::Tools::Exception;
use Lang::Go::Mod qw(parse_go_mod);

my $go_version = 'go 1.16';
my $module     = 'module github.com/user/example';

my $missing_module = <<"MISSING_MODULE";
$go_version
MISSING_MODULE
ok(
    dies {
        parse_go_mod($missing_module);
    }
) or note($@);

my $missing_go = <<"MISSING_GO";
$module
MISSING_GO
ok(
    dies {
        parse_go_mod($missing_go);
    }
) or note($@);

my $minimal = <<"MINIMAL";
$module
$go_version
MINIMAL
ok(
    lives {
        parse_go_mod($minimal);
    }
) or note($@);

done_testing;

1;
