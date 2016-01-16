unit module AttrX::PrivateAccessor:ver<v0.0.1>:auth<github:pierre-vigier>;

role ProvidePrivateAccessor { }

role ProvidePrivateAccessorContainer {
    method BUILDALL(|) {
        for self.^attributes.grep( * ~~ ProvidePrivateAccessor ) -> $attr {
            #check if a pricate method has the same name
            my $name = $attr.name.substr(2);
            say $name;
            if $name ~~ self.^private_method_table {
                die "A private method '$name' already exists, can't create private accessor '$name' for attribute '\$!$name'.";
            } else {
                self.^add_private_method($name, method (Mu:D: ) {
                    $attr.get_value( self );
                });
            }
        }
        callsame;
    }
}

multi sub trait_mod:<is>(Attribute $attr, :$providing-private-accessor!) is export {
    $attr does ProvidePrivateAccessor;
    #$attr.package.^add_role( ProvidePrivateAccessorContainer ) unless $attr.package.^roles_to_compose.grep( ProvidePrivateAccessorContainer );
    $*PACKAGE.^add_role(ProvidePrivateAccessorContainer) unless $*PACKAGE.^roles_to_compose.first(ProvidePrivateAccessorContainer) !=== Nil;
}

=begin pod
=head1 NAME

AttrX::PrivateAccessor

=head1 SYNOPSIS

Provide private accessor for private attribute

=head1 DESCRIPTION

This module provides trait providing-private-accessor, which will create a private accessor for a private attribute
It allows from within a class to access another instance of the same class' private attributes

    use AttrX::PrivateAccessor;

    class Sampl
        has $!attribute is providing-private-accessor;
    }

is equivalent to

    class Sampl
        has $!attribute;

        !method attribute() {
            return $!attribute;
        }
    }

=head1 MISC

To test the meta data of the modules, set environement variable PERL6_TEST_META to 1

=end pod
