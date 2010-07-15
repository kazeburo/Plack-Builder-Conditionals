package Plack::Builder::Conditionals;

use strict;
use warnings;
use Net::CIDR::Lite;
use List::MoreUtils qw//;
use Plack::Util;
use Plack::Middleware::Conditional;

our $VERSION = '0.01';

sub import {
    my $class = shift;
    my $caller = caller;
    my %args = @_;

    my @EXPORT = qw/match_if addr path method header any all/;

    no strict 'refs';
    my $i=0;
    for my $sub (@EXPORT) {
        my $sub_name = $args{'-prefix'} ? $args{'-prefix'} . '_' . $sub : $sub;
        *{"$caller\::$sub_name"} = \&$sub;
    }
}

sub match_if {
    my $condition = shift;
    my ( $mw, @args ) = @_;
    
    if (ref $mw ne 'CODE') {
        my $mw_class = Plack::Util::load_class($mw, 'Plack::Middleware');
        $mw = sub { $mw_class->wrap($_[0], @args) };
    }

    return sub {
        Plack::Middleware::Conditional->wrap(
            $_[0],
            condition => $condition,
            builder => $mw
        );
    }
}

sub addr {
    my $not;
    my $ip;
    if ( @_ == 1 ) {
        $ip = $_[0];
    }
    else {
        $not = $_[0];
        $ip = $_[1];
    }

    my @ip = ref $ip ? @$ip : ($ip);
    my $cidr = Net::CIDR::Lite->new();
    $cidr->add_any( $_ ) for @ip;

    return sub {
        my $env = shift;
        my $ret = $cidr->find($env->{REMOTE_ADDR});
        return (defined $not && $not eq '!')  ? !$ret : $ret;
    };
}

sub _match {
    my $key = shift;
    my $not;
    my $val;
    if ( @_ == 1 ) {
        $val = $_[0];
    }
    else {
        $not = $_[0];
        $val = $_[1];
    }

    return sub {
        my $env = shift;
        my $ret;
        if ( ref $val && ref $val eq 'Regexp' ) {
            $ret = exists $env->{$key} && $env->{$key} =~ m!$val!;
        }
        elsif ( defined $val ) {
            $ret = exists $env->{$key} && $env->{$key} eq $val;
        }
        else {
            $ret = exists $env->{$key};
        }
        return ( defined $not && $not eq '!' ) ? !$ret : $ret;
    };
}

sub path {
    _match( 'PATH_INFO', @_ );
}

sub method {
    my $not;
    my $method;
    if ( @_ == 1 ) {
        $method = $_[0];
    }
    else {
        $not = $_[0];
        $method = $_[1];
    }

    if ( ref $method && ref $method eq 'Regexp' ) {
        my $re = "$method";
        $re =~ s/\?([^-]*)(\-[^i]*)i([^:]*?:)/?i$1$2$3/;
        $method = qr/$re/i;
    }
    elsif ( defined $method )  {
        $method = uc $method;
    }
    _match( 'REQUEST_METHOD', ( @_ == 1 ) ? ($method) : ($not, $method) );
}

sub header {
    my $header = shift;
    $header =~ s/-/_/g;
    $header = 'HTTP_' . uc($header);
    _match( $header, @_ );
}

sub any {
    my @match = @_;
    return sub {
        my $env = shift;
        List::MoreUtils::any { $_->($env) } @match;
    };
}

sub all {
    my @match = @_;
    return sub {
        my $env = shift;
        List::MoreUtils::all { $_->($env) } @match;
    };
}


1;
__END__

=head1 NAME

Plack::Builder::Conditionals - Plack::Builder extension

=head1 SYNOPSIS

  use Plack::Builder;
  use Plack::Builder::Conditionals;
  # exports "match_if, addr, path, method, header, any, all"

  builder {
      enable match_if addr(['192.168.0.0/24','127.0.0.1']),
          "Plack::Middleware::ReverseProxy";

      enable match_if all( path(qr!^/private!), addr( '!', [qw!127.0.0.1!] ) ),
          "Plack::Middleware::Auth::Basic", authenticator => \&authen_cb;

      enable match_if sub { my $env = shift; $env->{HTTP_X_ENABLE_FRAMEWORK} },
          "Plack::Middleware::XFramework", framework => 'Test';

      $app;
  };

  use Plack::Builder::Conditionals -prefx => 'c';
  # exports "c_match_if, c_addr, c_path, c_method, c_header, c_any, c_all"


=head1 DESCRIPTION

Plack::Builder::Conditionals is..

=head1 AUTHOR

Masahiro Nagano E<lt>kazeburo {at} gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
