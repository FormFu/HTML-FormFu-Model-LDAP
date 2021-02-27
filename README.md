# HTML::FormFu::Model::LDAP - Integrate FormFu and LDAP

`HTML::FormFu::Model::LDAP` is a module to integrate
[HTML::FormFu](https://metacpan.org/pod/HTML::FormFu) (a form creation and
validation framework) with the
[LDAP](https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol)
directory information services system.  By integrating these systems, it is
possible to set a form's default values from information gleaned from a
given LDAP system as well as to update values in LDAP from a submitted form.

## Installation

Currently, the best way to install this module is directly from its [GitHub
repository](https://github.com/FormFu/HTML-FormFu-Model-LDAP).

First, clone the repository:

```
$ git clone https://github.com/FormFu/HTML-FormFu-Model-LDAP.git
```

then change into the `HTML-FormFu-Model-LDAP/` directory, install the
dependencies and build the `Makefile`:

```
$ cd HTML-FormFu-Model-LDAP/
$ cpanm --installdeps .
$ perl Makefile.PL
```

If you wish, you can run the test suite like so:

```
$ make test
```

To install the distribution, simply run

```
$ make install
```

## Basic usage

Make sure you set the form's default model for `HTML::FormFu` to `LDAP`:

```
---
default_model: LDAP
```

To set a form's default values from LDAP, use the `default_values()` method:

```perl
$form->model->default_values($ldap_entry);
```

To update LDAP with values from a submitted form, simply call the `update()`
method:

```perl
if ($form->submitted_and_valid) {
    $form->model->update($ldap_entry);
}
```

See the
[HTML::FormFu::Model::DBIC documentation](https://metacpan.org/pod/HTML::FormFu::Model::DBIC)
for more usage information.
