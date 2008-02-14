package HTML::FormFu::Model::LDAP;
use strict;
use warnings;

use Data::Dumper;
our $VERSION = '0.0100';
sub defaults_from_model {
    my ( $self, $base, $ldap_entry ) = @_;

    my $elements = $base->get_elements();
    foreach my $e (@$elements){
        my $name = $e->name();
        my $val = $ldap_entry->get_value($name);
        if ($name && $val){            
            $e->default($val);
        }
    }
}

sub save_to_model {
    my ( $self, $base, $ldap_entry, $ldap_server ) = @_;

    my $c = $base->form->stash->{context};
    
    my $elements = $base->get_elements();
    my %elm_hash = ();
    # Store all entries from form in a hash
    foreach my $e (@$elements){
        $elm_hash{ $e->name() } = $base->form->param_value( $e->name() );
    }
    # Run through all possible ldap attributes, and store those from form hash
    my @objectclasses = $ldap_entry->get_value('objectClass');
    foreach my $oc (@objectclasses){
        foreach my $attr ($ldap_server->schema->must($oc), 
                          $ldap_server->schema->may($oc)){
            if ( defined($elm_hash{$attr->{name}}) ){
                $ldap_entry->replace($attr->{name}, $elm_hash{$attr->{name}});
            }
        }
    }
    return $ldap_entry->update($ldap_server);
}

1;


=head1 NAME

HTML::FormFu::Model::LDAP - Integrat FormFu and LDAP


=head1 VERSION

This document describes HTML::FormFu::Model::LDAP version 0.0.1


=head1 SYNOPSIS

    # in your form-config:
    ---
    model_class: LDAP
    
    # $ldap_entry should inherit from Net::LDAP::Entry, or atleast
    # implement get_value() and 
    $form->defaults_from_model($ldap_entry)
    
    if ($form->submitted_and_valid) {
        $form->save_to_model($ldap_entry);
    }
  
=head1 DESCRIPTION

This module implements the model-interface of HTML::FormFu and provides
the glue between HTML::FormFu and an Net::LDAP based "model"

=head1 INTERFACE 

=head2 METHODS

=head3 defaults_from_model $ldap_entry

Fills out the fields in $form where it can find a matching attributes in ldap

=head3 save_to_model $ldap_entry, $ldap_server

Iterates trough the $ldap_entry, finding any may and must attributes
that has a coresponding field in the form, and updates the ldap-entry.

This also calles $ldap_entry->update($ldap_server) to commit its changes


=head1 DIAGNOSTICS

No known errors

=head1 CONFIGURATION AND ENVIRONMENT

you configure it trough the form-config:

---
model_class: LDAP


=head1 DEPENDENCIES

Net::LDAP


=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<bug-html-formfu-model-ldap@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head2 Missing methods

=head3 options_from_model

We have no options_from_model for now




=head1 AUTHOR

Andreas Marienborg  C<< <andreas@startsiden.no> >>
Andreas Dahl C<< <andread@never.no> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Andreas Marienborg C<< <andreas@startsiden.no> >>.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.