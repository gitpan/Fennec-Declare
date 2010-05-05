#!/usr/bin/perl
use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    module_name => 'Fennec::Declare',
    license     => 'perl',
    dist_author => 'Chad Granum <exodist7@gmail.com>',
    create_readme => 1,
    requires => {
        'Fennec' => 0.018,
        'Devel::Declare' => 0.006000,
        'B::Compiling' => 0.02,
        'B::Hooks::EndOfScope' => 0.08,
    },
    meta_merge => {
        resources => {
            repository  => 'http://github.com/exodist/Fennec-Declare',
            bugtracker  => 'http://github.com/exodist/Fennec-Declare/issues',
        },
    }
);

$build->create_build_script;
