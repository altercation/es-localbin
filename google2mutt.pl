#!/usr/bin/perl

use strict;
use warnings;
use IO::File;

my $aliases = {};
my $fh = IO::File->new('google contacts list name,email .* |');

while(my $line = <$fh>) {
  chomp $line;
  my ($name, $addresses) = split(',', $line);
  if($addresses eq 'N/A') {
    next;
  } else {
    my @addresses = split(';\s*', $addresses);
    foreach my $address (@addresses) {
      my $context = "";
      if($address =~ /\s/) {
        ($context, $address) = split(/\s/, $address);
      }
      push @{$aliases->{$name}{$context}}, $address;
    }
  }
}

close($fh);

foreach my $name (sort keys %$aliases) {
  print_aliases($name, $aliases->{$name});
}

sub print_aliases {
  my $name = shift;
  my $aliases = shift;

  for my $context (keys %$aliases) {
    my $alias = $name;
    $alias = lc($alias);
    $alias =~ s/\s+/_/g;
    if($context ne '') {
      $alias = "$alias" . "_" . $context;
    }
    for my $i (0..$#{$aliases->{$context}}) {
      $alias = $alias . ($i+1);
      $alias =~ s/1$//;
      print "alias $alias <$aliases->{$context}[$i]> ($name)\n";
    }
  }
}
