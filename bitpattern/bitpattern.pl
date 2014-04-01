#!/usr/bin/perl

use strict;
use warnings;

my $home = "\033[2J\033[1;1H";

use Term::ReadKey;

ReadMode 4;

my $key_bindings = join(' ', map { " $_ " } (1..4, 7..9, 0));

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

        print <<OUT ;
$home${instructions}

        Target: $target_hex

$keys
$key_bindings

        Current Guess: $guess_hex

OUT

        if ($target == $guess) {
            print ("You got it!\n");
            sleep 1;
            next OUTER;
        }

    $key = ReadKey(0);

    } while (1);
}
