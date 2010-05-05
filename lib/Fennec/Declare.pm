package Fennec::Declare;
use strict;
use warnings;
use Devel::Declare;
use B::Compiling;
use B::Hooks::EndOfScope;

our $VERSION = 0.001;
our @DECLARATORS = qw/ tests it describe cases case /;

sub import {
    my $class = shift;
    my $caller = caller;
    my @add_declarators = @_;

    die( "Fennec::Declare can only be used in a Fennec test file" )
        unless $caller->isa( 'Fennec::TestFile' );

    Devel::Declare->setup_for(
        $caller,
        { map {
            my $dec = $_;
            $dec => { const => sub { parser( $dec )}}
        } ( @DECLARATORS, @add_declarators )}
    );
}

sub parser {
    my ($dec) = @_;
    my $line = Devel::Declare::get_linestr();
    return if $line =~ m/^\s*$dec .*(,|=>).*\(/;
    return if $line =~ m/^\s*$dec .*(,|=>)\s+sub(\(.*\))?\s?{/;

    $line =~ m/^(\s*)$dec \s+ ('[^']*'|"[^"]*"|\w+) \s+ (.*) {(.*)?$/x;
    my ( $indent, $name, $extra, $end ) = ( $1, $2, $3, $4 );
    $indent ||= "";

    my $proto;
    if ( $extra ) {
        $extra =~ s/(\(.*\))//g;
        $proto = $1;
        $proto =~ s/(^\s+|\s+$)//g if $proto;
        $extra =~ s/(^\s+|\s+$)//g if $extra;
    }

    my @errors;
    push @errors => "syntax error near: '$extra'" if $extra;
    push @errors => "syntax error, could not parse name from: '$line'" unless $name;
    $_ =~ s/\n//smg for @errors;
    my $file = PL_compiling->file;
    $file = '(eval)' if $file =~ m/\(\s*eval\s*\d+\)/;
    die(
        "===================\n"
        . join( "\n", @errors )
        . " at " . $file
        . " line " . PL_compiling->line
        . "\n\n"
        . "Syntax is: $dec name (%options) { ... }\n"
        . "       Or: $dec 'long name' (%options) { ... }\n"
        . "       Or: $dec name { ... }\n"
        . "       Or: $dec 'long name' { ... }\n\n"
    ) if( @errors );

    $name =~ s/(^\s+|\s+$)//g;
    $proto =~ s/^\s*\((.*)\)\s*$/$1/ if $proto;

    my $newline = "$indent$dec $name => ( "
                . ( $proto ? "$proto, " : "" )
                . "method => sub { BEGIN { Fennec::Declare::inject_scope }; $end\n";

    Devel::Declare::set_linestr($newline);
}

sub inject_scope {
    on_scope_end {
        my $linestr = Devel::Declare::get_linestr;
        my $offset = Devel::Declare::get_linestr_offset;
        substr($linestr, $offset, 0) = ');';
        Devel::Declare::set_linestr($linestr);
    };
}

1;

__END__

=pod

=head1 NAME

Fennec::Declare - Nice syntax for Fennec via Devel::Declare

=head1 DESCRIPTION

Fennec is useful, but its syntax is not as nice as it could be. Leaving
Devel::Declare out of core is a feature, but that does nto mean it shouldn't
exist at all. This module provides Devel::Declare syntax enhancements to
Fennec.

=head1 WARNING: EXPERIMENTAL

L<Devel::Declare> is better than a source filter, but still magic in all kinds
of possible bad ways. It adds new parsing capabilities to perl, but using it
often still requires code to parse perl. Only perl can parse perl, as such
there are likely many edge cases that have not been accounted for.

=head1 SYNOPSIS

    package My::Test
    use strict;
    use warnings;
    use Fennec;
    use Fennec::Declare;

    tests simple {
        ok( 1, "In declared tests!" );
    }

    tests 'complicated name' {
        ok( 1, "Complicated name!" );
    }

    tests old => sub {
        ok( 1, "old style still works" );
    };

    tests old_deep => (
        method => sub { ok( 1, "old with depth" )},
    );

    # Currently this does not work because of Fennec bug #58
    # http://github.com/exodist/Fennec/issues#issue/58
    # The syntax enhancement does as it should.
    tests add_specs ( todo => 'not really todo' ) {
        ok( 0, "This should be todo" );
    }

    cases some_cases {
        my $x = 0;
        case case_a { $x = 10 }
        case case_b { $x = 100 }
        case case_c { $x = 1000 }

        tests divisible_by_ten { ok( !($x % 10), "$x/10" )}
        tests positive { ok( $x, $x )}
    }

    describe a_describe {
        my $x = 0;

        # Note, SPEC before/after blocks are not enhanced
        before_each { $x = 10 };
        after_each { $x = 0 };
        it is_ten { is( $x, 10, "x is 10" ); $x = 100 }
        it is_not_100 { isnt( $x, 100, "x is not 100" ); $x = 100 }
    }

    1;

=head1 AUTOMATICALLY ENHANCED

Using Fennec::Declare automatically provides enhancements to the following:

=over 4

=item tests

=item cases

=item case

=item describe

=item it

=back

=head1 ENHANCING SYNTAX FOR OTHERS

    use Fennec::Declare @names_of_subs_to_enahnce;

So long as a sub takes for the form of:

    subname item_name => ( method => sub { ... });

Fennec::Declare can enhance it. Simply provide the subs name to the use
statement. before_XXX and after_XXX do not take this form, and thusly have not
been enhanced.

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2010 Chad Granum

Fennec-Declare is free software; Standard perl licence.

Fennec-Declare is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the license for more details.
