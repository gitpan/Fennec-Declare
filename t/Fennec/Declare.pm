package TEST::Fennec::Declare;
use strict;
use warnings;
use Fennec;
use Fennec::Declare;

tests simple {
    ok( $self, "Magically got self" );
    $self->isa_ok( 'TEST::Fennec::Declare' );
    $self->isa_ok( 'Fennec::TestFile' );
    ok( 1, "In declared tests!" );
}

tests 'complicated name' {
    ok( $self, "Magically got self" );
    $self->isa_ok( 'TEST::Fennec::Declare' );
    $self->isa_ok( 'Fennec::TestFile' );
    ok( 1, "Complicated name!" );
}

tests old => sub {
    ok( 1, "old style still works" );
};

tests old_deep => (
    method => sub { ok( 1, "old with depth" )},
);

tests add_specs ( todo => 'not really todo' ) {
    ok( $self, "Magically got self" );
    $self->isa_ok( 'TEST::Fennec::Declare' );
    $self->isa_ok( 'Fennec::TestFile' );
    TODO {
        ok( 0, "This should be todo" );
    } "Todo from Fennec bug #58";
}

cases some_cases {
    ok( $self, "Magically got self" );
    $self->isa_ok( 'TEST::Fennec::Declare' );
    $self->isa_ok( 'Fennec::TestFile' );

    my $x = 0;
    case case_a { $x = 10 }
    case case_b { $x = 100 }
    case case_c {
        ok( !$self, "Cases are not methods" );
        $x = 1000
    }

    tests divisible_by_ten { ok( !($x % 10), "$x/10" )}
    tests positive { ok( $x, $x )}
}

describe a_describe {
    ok( $self, "Magically got self" );
    $self->isa_ok( 'TEST::Fennec::Declare' );
    $self->isa_ok( 'Fennec::TestFile' );

    my $x = 0;
    before_each { $x = 10 };
    after_each { $x = 0 };
    it is_ten { is( $x, 10, "x is 10" ); $x = 100 }
    it is_not_100 { isnt( $x, 100, "x is not 100" ); $x = 100 }
}

tests errors {
    eval 'tests { 1 }';
    my $msg = $@;
    is( $msg, <<EOT, "No Name Message" );
===================
syntax error, could not parse name from: 'tests { 1 };' at (eval) line 1

Syntax is: tests name (%options) { ... }
       Or: tests 'long name' (%options) { ... }
       Or: tests name { ... }
       Or: tests 'long name' { ... }

EOT
}

1;
