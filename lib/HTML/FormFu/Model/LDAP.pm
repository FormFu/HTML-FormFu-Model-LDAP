package HTML::FormFu::Model::LDAP;

use strict;
use warnings;
use base 'HTML::FormFu::Model';

use Data::Dumper;
our $VERSION = '0.0103';
use Encode;

sub default_values {
    my ( $self, $ldap_entry ) = @_;

    my $base = $self->form;
    my $cfg  = $base->model_config || {};

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
            #warn $attr->{name} . ": " . ($value ? $value : "undef");
            if ( defined $value ) {
                $ldap_entry->replace( $attr->{name}, $value );
            } elsif ($nested_name) {
                # This exists in the form, so we should remove it?
                $ldap_entry->delete( $attr->{name}) if $ldap_entry->exists( $attr->{name} );
            }
        }
    }
    return $ldap_entry->update($ldap_server);
}

1;

=head1 NAME

HTML::FormFu::Model::LDAP - Integrate FormFu and LDAP

=head1 SYNOPSIS

Set the form's L<HTML::FormFu/default_model>.

    ---
    default_model: LDAP

Example usage:

    # $ldap_entry should inherit from Net::LDAP::Entry, or atleast
    # implement get_value(), replace() and update()

    # set form's default values from LDAP

    $form->model->default_values($ldap_entry);

    # update LDAP with values from submitted form

    if ($form->submitted_and_valid) {
        $form->model->update($ldap_entry);
    }

=head1 DESCRIPTION

This module implements the model-interface of HTML::FormFu and provides
the glue between HTML::FormFu and an Net::LDAP based "model"

See L<HTML::FormFu::Model::DBIC> for further documentation on usage.

=head2 METHODS

=head3 default_values

Arguments: $ldap_entry

Fills out the fields in $form where it can find a matching attributes in ldap

=head3 update

Arguments: $ldap_entry, [\%config]

Iterates through the $ldap_entry, finding any may and must attributes
that has a coresponding field in the form, and updates the ldap-entry.

This also calles $ldap_entry->update($ldap_server) to commit its changes

=head1 SUPPORT

Please report any bugs or feature requests to
C<bug-html-formfu-model-ldap@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head2 NOT IMPLEMENTED

The following L<HTML::FormFu::Model> methods are not implemented:

=over

=item create

=item options_from_model

=back

=head1 AUTHOR

Andreas Marienborg  C<< <andreas@startsiden.no> >>

Andreas Dahl C<< <andread@never.no> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Andreas Marienborg C<< <andreas@startsiden.no> >>.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
