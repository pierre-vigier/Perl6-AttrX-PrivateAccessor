use v6;
use Test;
use AttrX::PrivateAccessor;

plan 4;

class Teenager {
    has $!diary is private-accessible;

    method init( $value ) {
        $!diary = $value;
    }

    method inspect(Teenager:D: Teenager $other) {
        return $other!diary;
    }
}

my $bob = Teenager.new();
$bob.init( "bob's diary" );
my $steve = Teenager.new();
$steve.init( "steve's diary" );

dies-ok { $bob.diary }, "No public method";
is $steve.inspect( $bob ), "bob's diary", "Can access other instance's private attributes";

eval-dies-ok q[
    use AttrX::PrivateAccessor;
    class Duplicate {
        has $!private is private-accessible;

        method !private() {
            "Just need a private method";
        }
    }
], "Collide as a private method with the same name already exists";

eval-lives-ok q[
    use AttrX::PrivateAccessor;
    class NoCollision {
        has $!private is private-accessible;

        method private() {
            "Just need a public method";
        }
    }
], "Does not collide with public method";
