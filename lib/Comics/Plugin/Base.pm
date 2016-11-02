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

our $VERSION = "0.05";

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

    # API 1.0 - change to new naming.
    $init->{pattern} = delete $init->{pat};
    $init->{patterns} = delete $init->{pats};

    # API 1.1 - fill %init with package variables.
    #### TODO: See code at __END__
    for ( qw( name tag path url pattern patterns disabled ) ) {
	no strict 'refs';
	next unless defined ${$pkg."::"}{$_};
	my $dst = $_;
	if ( $_ eq 'patterns' ) {
	    $init->{patterns} ||= [ @{${$pkg."::"}{$_}} ];
	}
	else {
	    $init->{$dst} ||= ${${$pkg."::"}{$_}};
	}
    }

    my $self = { %$init };
    bless $self, $pkg;
    $self->{tag} ||= $self->tag_from_package;

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

=head2 html

Generates a tag (identifier) from the name of the plugin.

=cut

sub tag_from_package {
    my $self = shift;
    my $tag = lc(ref($self) =~ s/^.*:://r);
    return $tag;
}

1;

__END__

    my %stash = do { no strict 'refs'; %{"${packageName}::"} };
    # Now %stash is the symbol table.
    # Iterate through the symbol table, which contains glob values
    # indexed by symbol names.
    while (my ($var, $glob) = each %stash) {
        print "$var ======= ", *{$glob}{NAME}, " ========= \n";
        if (defined ${*{$glob}{SCALAR}} ) {
            print "\t \$$var ", ${*{$glob}{SCALAR}}, " \n";
        }
        if ( defined *{$glob}{ARRAY} ) {
            print "\t \@$var ", @{*{$glob}{ARRAY}}, "\n";
        }
        if ( defined *{$glob}{HASH} ) {
	    local $, = " ";
            print "\t \%$var", %{*{$glob}{HASH}}, " \n";
        }
     }
