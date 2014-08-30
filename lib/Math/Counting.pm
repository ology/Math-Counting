package Math::Counting;
# ABSTRACT: Combinatorial counting operations

our $VERSION = '0.1304';

use strict;
use warnings;

# Export either "student" or "engineering" methods.
use parent qw(Exporter);
our %EXPORT_TAGS = (
    student => [qw( factorial permutation combination )],
    big     => [qw( bfact bperm bcomb bderange )],
);
our @EXPORT_OK = qw(
    factorial permutation combination
    bfact     bperm       bcomb
              bderange
);
our @EXPORT = ();

# Try to use a math processor.
use Math::BigFloat try => 'GMP,Pari'; # Used for derangement computation only.
use Math::BigInt try => 'GMP,Pari';

=head1 SYNOPSIS

Academic

  use Math::Counting ':student';
  printf "Given n=%d, k=%d:\nF=%d\nP=%d\nC=%d\n",
    $n, $k, factorial($n), permutation($n, $k), combination($n, $k);

Engineering

  use Math::Counting ':big';
  printf "Given n=%d, k=%d, r=%d:\nF=%d\nP=%d\nD=%d\nC=%d\n",
    $n, $k, $r, bfact($n), bperm($n, $k, $r), bderange($n), bcomb($n, $k, $r);

=head1 DESCRIPTION

Compute the factorial, number of permutations and number of combinations.

The C<:big> functions are wrappers around L<Math::BigInt/bfac> with a bit of
arithmetic between.  Also the C<bperm> function accepts an additional boolean to
indicate repetition.

The student versions exist to illustrate the computation "in the raw" as it were.
To see these computations in action, Use The Source, Luke.

=head1 FUNCTIONS

=head2 factorial

  $f = factorial($n);

Return the number of arrangements of B<n>, notated as C<n!>.

This function employs the algorithmically elegant "student" version using real
arithmetic.

=cut

sub factorial {
    my $n = shift;
    return unless defined $n && $n =~ /^\d+$/;
    my $product = 1;
    while( $n > 0 ) {
        $product *= $n--;
    }
    return $product;
}

=head2 bfact

  $f = bfact($n);

Return the value of the function L<Math::BigInt/bfac>, which is the
"Right Way To Do It."

=cut

sub bfact {
    my $n = shift;
    $n = Math::BigInt->new($n);
    return $n->bfac;
}

=head2 permutation

  $p = permutation($n, $k);

Return the number of arrangements, without repetition, of B<k> elements drawn
from a set of B<n> elements, using the "student" version.

=cut

sub permutation {
    my( $n, $k ) = @_;
    return unless defined $n && $n =~ /^\d+$/ && defined $k && $k =~ /^\d+$/;
    my $product = 1;
    while( $k > 0 ) {
        $product *= $n--;
        $k--;
    }
    return $product;
}

=head2 bperm

  $p = bperm($n, $k, $r);

Return the computations:

  n^k           # with repetition
  n! / (n-k)!   # without repetition

=cut

sub bperm {
    my( $n, $k, $r ) = @_;
    $n = Math::BigInt->new($n);
    $k = Math::BigInt->new($k);
    # With repetitions?
    if ($r) {
        return $n->bpow($k);
    }
    else {
        $k = $n - $k;
        return $n->bfac / $k->bfac;
    }
}

=head2 bderange()

"A derangement is a permutation in which none of the objects appear in their
"natural" (i.e., ordered) place." -- wolfram under L</"SEE ALSO">

Return the computation:

  !n = n! * ( sum (-1)^k/k! for k=0 to n )

=cut

sub bderange {
    my $n = shift;
    my $mone = Math::BigFloat->bone('-'); # -1
    my $s = Math::BigFloat->bzero;
    for ( 0 .. $n ) {
        my $i = Math::BigFloat->new($_);
        my $m = $mone->copy;
        my $j = $m->bpow($i);
        my $x = $i->copy;
        my $f = $x->bfac;
        $s += $j / $f;
    }
    $n = Math::BigFloat->new($n);
    return $n->bfac * $s;
}

=head2 combination

  $c = combination($n, $k);

Return the number of ways to choose B<k> elements from a set of B<n>
elements, without repetition.

This is algorithm expresses the "student" version.

=cut

sub combination {
    my( $n, $k ) = @_;
    return unless defined $n && $n =~ /^\d+$/ && defined $k && $k =~ /^\d+$/;
    my $product = 1;
    while( $k > 0 ) {
        $product *= $n--;
        $product /= $k--;
    }
    return $product;
}

=head2 bcomb

  $c = bcomb($n, $k, $r);

Return the combination computations:

  (n+k-1)! / k!(n-1)!   # with repetition
  n! / k!(n-k)!         # without repetition

=cut

sub bcomb {
    my( $n, $k, $r ) = @_;
    $n = Math::BigInt->new($n);
    $k = Math::BigInt->new($k);
    # With repetitions?
    if ($r) {
        my $c1 = $n + $k - 1;
        my $c2 = $n - 1;
        return $c1->bfac / ($k->bfac * $c2->bfac);
    }
    else {
        my $c1 = $n - $k;
        return $n->bfac / ($k->bfac * $c1->bfac);
    }
}

1;
__END__

=head1 TO DO

Allow specification of the math processor to use.

Provide the gamma function for the factorial of non-integer numbers?

=head1 SEE ALSO

L<Math::BigInt/bfac>

B<Higher Order Perl> by Mark Jason Dominus
(L<http://hop.perl.plover.com>).

B<Mastering Algorithms with Perl> by Orwant, Hietaniemi & Macdonald
(L<http://www.oreilly.com/catalog/maperl>).

L<http://en.wikipedia.org/wiki/Factorial>, 
L<http://en.wikipedia.org/wiki/Permutation> &
L<http://en.wikipedia.org/wiki/Combination>

L<http://www.mathsisfun.com/combinatorics/combinations-permutations-calculator.html>

L<http://mathworld.wolfram.com/Derangement.html>

Naturally, there are a plethora of combinatorics packages available,
take your pick:

L<Algorithm::Combinatorics>,
L<Algorithm::Loops>,
L<Algorithm::Permute>,
L<CM::Group::Sym>,
L<CM::Permutation>,
L<Games::Word>,
L<List::Permutor>,
L<Math::Combinatorics>,
L<Math::GSL::Permutation>,
L<Math::Permute::List>,
L<String::Glob::Permute>,
L<String::OrderedCombination>

=head1 CREDITS

Special thanks to:

* Paul Evans

* Mike Pomraning

* Petar Kaleychev

* Dana Jacobsen

=cut

