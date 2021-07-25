# Lang::Go::Mod

[![License:Artistic](https://img.shields.io/badge/License-Artistic-yellow.svg)](https://opensource.org/licenses/artistic-license-2.0)
![ci](https://github.com/bradclawsie/Lang-Go-Mod/workflows/ci/badge.svg)

```
NAME

Lang::Go::Mod - parse and model go.mod files

SYNOPSIS

   # $ cat go.mod
   # module github.com/example/my-project
   # go 1.16
   # exclude (
   #    example.com/whatmodule v1.4.0
   # )
   # replace (
   #    github.com/example/my-project/pkg/app = ./pkg/app
   # )
   # require (
   #    golang.org/x/sys v0.0.0-20210510120138-977fb7262007 // indirect
   # )

   use Lang::Go::Mod qw(read_go_mod parse_go_mod);

   my $go_mod_path = '/path/to/go.mod';

   # read and parse the go.mod file
   # all errors croak, so wrap this in your favorite variant of try/catch
   # to gracefully manage errors
   my $m = read_go_mod($go_mod_path);
   # use parse_go_mod to parse the go.mod content if it is already in a scalar

   print $m-{module}; # github.com/example/my-project
   print $m-{go}; # 1.16
   print $m-{exclude}-{'example.com/whatmodule'}; # [v1.4.0]
   print $m-{replace}-{'github.com/example/my-project/pkg/app'}; # ./pkg/app
   print $m-{'require'}-{'golang.org/x/sys'}; # v0.0.0-20210510120138-977fb7262007

DESCRIPTION

This module creates a hash representation of a go.mod file.
Both single line and multiline exclude, replace, and require
sections are supported. For a full reference of the go.mod format, see 

https://golang.org/doc/modules/gomod-ref

EXPORTED METHODS

read_go_mod

Given a full filepath for a go.mod file, read it, parse it and
return the hash representation of the contents. All errors croak.

parse_go_mod

Given a scalar of the contents of a go.mod file, parse it and 
return the hash representation of the contents. All errors croak.

LICENSE 

Lang::Go::Mod is licensed under the same terms as Perl itself.

https://opensource.org/licenses/artistic-license-2.0
```
