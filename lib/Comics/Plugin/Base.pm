#! perl

use strict;
use warnings;

package Comics::Plugin::Base;

=head1 NAME

Comics::Plugin::Base -- Base class for Plugins.

=head1 SYNOPSIS

This base class is only used indirectly via the Fetchers.

=head1 DESCRIPTION

The Plugin Base class provides tools for Plugins.

=cut

our $VERSION = "0.03";

=head1 CONSTRUCTOR

=head2 register( { ... } )

Registers the plugin to the aggregator.

The method takes a hash ref with arguments. What arguments are
possible depends on the plugin's Fetcher type. See the documentation
of the Fetchers for more info.

Common arguments are:

=over 8

=item name

The full name of this comic, e.g. "Fokke en Sukke".

=item url

The url of this comic's home page.

=item tag

A short identifier for this comic. This will be automatically provided
if not specified.

The tag is used to generate file names for images and HTML fragments.

=back

=cut

sub register {
    my ( $pkg, $init ) = @_;
    my $self = { %$init };
    bless $self, $pkg;
    $self->{tag} ||= $self->tag_from_name;
    return $self;
}

=head1 METHODS

=head2 html

Generates an HTML fragment for a fetched image.

=cut

sub html {
    my ( $self ) = @_;
    my $state = $self->{state};

    my $w = $self->{c_width};
    my $h = $self->{c_height};
    if ( $h && $w ) {
	if ( $w > 1024 ) {
	    $w = 1024;
	    $h = int( $h * $w/$self->{c_width} );
	}
    }

    my $res =
	 qq{<table class="toontable" cellpadding="0" cellspacing="0">\n} .
	 qq{  <tr><td nowrap align="left" valign="top">} .
	 qq{<b>} . _html($self->{name}) . qq{</b><br>\n} .
	 qq{        <font size="-2">Last update: } .
	 localtime($state->{update}) .
	 qq{</font><br><br></td>\n} .
	 qq{  </tr>\n  <tr><td><a href="$self->{url}?$::uuid">} .
	 qq{<img border="0" };

    # Alt and title are extracted from HTML, so they should be
    # properly escaped.
    $res .= qq{alt="} . $self->{c_alt} . qq{" }
      if $self->{c_alt};
    $res .= qq{title="} . $self->{c_title} . qq{" }
      if $self->{c_title};
    $res .= qq{width="$w" height="$h" }
      if $w && $h;

    $res .= qq{src="$self->{c_img}"></a></td>\n  </tr>\n</table>\n};

    return $res;
}

sub _html {
    my ( $t ) = @_;

    $t =~ s/&/&amp;/g;
    $t =~ s/</&lt;/g;
    $t =~ s/>/&gt;/g;
    $t =~ s/"/&quote;/g;

    return $t;
}

1;
