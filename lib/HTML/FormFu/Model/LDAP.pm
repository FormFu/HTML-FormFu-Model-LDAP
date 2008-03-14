package HTML::FormFu::Model::LDAP;

use strict;
use warnings;
use base 'HTML::FormFu::Model';

use Data::Dumper;
our $VERSION = '0.0100';
use Encode;

sub default_values {
    my ( $self, $ldap_entry ) = @_;

    my $base = $self->form;
    my $cfg  = $base->model_config;
    $cfg = ( ref($cfg) ? $cfg->{LDAP} : {} );
    my $elements = $base->get_all_elements();
    foreach my $e (@$elements) {
        my $name = $e->name();
        my $val  = $ldap_entry->get_value($name);
        $val = decode_utf8($val) if $cfg->{decode};
        if ( $name && $val ) {
            $e->default($val);
        }
    }
}

sub update {
    my ( $self, $ldap_entry, $attrs ) = @_;

    $attrs ||= {};

    my $form = $self->form;
    my $base = defined $attrs->{base} ? delete $attrs->{base} : $form;

    $base = $form->get_all_element( { nested_name => $attrs->{nested_base} } )
      if defined $attrs->{nested_base}
          && ( !defined $base->nested_name
              || $base->nested_name ne $attrs->{nested_base} );

    my @valid = $form->valid;

    # Get ldap_server from attrs.
    my $ldap_server =
      defined $attrs->{ldap_server} ? delete $attrs->{ldap_server} : undef;

    # Run through all possible ldap attributes, and store those from form hash
    my @objectclasses = $ldap_entry->get_value('objectClass');
    foreach my $oc (@objectclasses) {
        foreach my $attr ( $ldap_server->schema->must($oc),
            $ldap_server->schema->may($oc) )
        {
            my $field = $base->get_field( { name => $attr->{name} } );
            my $nested_name = defined $field ? $field->nested_name : undef;
            my $value =
              defined $field
              ? $form->param_value( $field->nested_name )
              : (
                grep {
                        defined $attrs->{nested_base}
                      ? defined $nested_name
                          ? $nested_name eq $_
                          : 0
                      : $attr->{name} eq $_
                  } @valid
              )
              ? $form->param_value( $attr->{name} )
              : undef;

            if ( defined $value ) {
                $ldap_entry->replace( $attr->{name}, $value );
            }
        }
    }
    return $ldap_entry->update($ldap_server);
}

sub create {
    update(@_);
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
