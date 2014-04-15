#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

my $hex;
my $decimal;

GetOptions(
    "hex"     => \$hex,
    "decimal" => \$decimal,
    "help"    => sub { HELP(0); },
) or HELP(1);

(! ($hex || $decimal)) and warn "--hex or --decimal" and HELP(1);
($hex && $decimal) and warn "--hex or --decimal" and HELP(1);

my $home = "\033[2J\033[1;1H";

use Term::ReadKey;

ReadMode 4;

my $key_bindings = join(' ', map { " $_ " } (1..4, 7..9, 0));
my $powers_of_16 = join('', map { "        $_\t" . ($_ * 16) . "\n" } (1..15));

my $instructions = "Set the bits to from the target number";

OUTER: while (1) {
    my $target = int(rand(256));
    my $target_hex = sprintf("0x%02x", $target);
    my @pressed = (0) x 8;

    my $key = '?';
    my $guess = 0;

    do {
        if ($key =~ /\d/ && ! ($key == 5 || $key == 6)) {
            my $value = $key;
            if ($value > 6) {
                $value -= 2;
            } elsif ($value == 0) {
                $value = 8;
            }

            $pressed[$value - 1] = $pressed[$value -1] ? 0 : 1;
        } elsif (lc($key) eq 'q') {
            ReadMode 0;
            exit 0;
        }

        my $keys = join(' ', map { "[$_]" } @pressed);
        $guess = 0;
        for (my $i = 0; $i < 8; $i++) {
            my $po2 = 7 - $i;

            $guess += $pressed[$i] << $po2;
        }

        my $guess_hex = sprintf("0x%02x", $guess);

        my ($target_display, $guess_display, $remainder_display);

        if ($hex) {
            $target_display = $target_hex;
            $guess_display = $guess_hex;
        } else {
            $target_display = $target;
            $guess_display = $guess;
        }

        print <<OUT ;
$home${instructions}

        Target: $target_display

$keys
$key_bindings

        Current Guess: $guess_display

$powers_of_16

OUT

        if ($target == $guess) {
            next OUTER;
        }

    $key = ReadKey(0);

    } while (1);
}

sub HELP {
    my $exit = shift;
    
    my $msg = <<MSG ;
USAGE $0 - OPTIONS

Play around with bit patterns in hex or decimal (practicing < 256)

OPTIONS

    --hex       play in hex
    --decimal   play in decimal

    --help      This help message
MSG

    if ($exit) {
        warn $msg;
    } else {
        print $msg;
    }

    exit($exit);
}
