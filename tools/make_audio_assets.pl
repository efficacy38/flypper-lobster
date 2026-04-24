#!/usr/bin/env perl
use strict;
use warnings;
use Math::Trig qw(pi);

my $sample_rate = 44100;

sub write_wav {
    my ($path, $duration, $generator) = @_;
    open my $fh, '>:raw', $path or die "cannot open $path: $!";
    my $samples = int($sample_rate * $duration);
    my $data_size = $samples * 2;
    print {$fh} "RIFF";
    print {$fh} pack("V", 36 + $data_size);
    print {$fh} "WAVEfmt ";
    print {$fh} pack("VvvVVvv", 16, 1, 1, $sample_rate, $sample_rate * 2, 2, 16);
    print {$fh} "data";
    print {$fh} pack("V", $data_size);
    for my $i (0 .. $samples - 1) {
        my $t = $i / $sample_rate;
        my $amp = $generator->($t, $duration);
        $amp = 1.0 if $amp > 1.0;
        $amp = -1.0 if $amp < -1.0;
        print {$fh} pack("s<", int($amp * 32767));
    }
    close $fh;
}

sub env {
    my ($t, $duration) = @_;
    my $attack = 0.015;
    my $release = 0.09;
    return $t / $attack if $t < $attack;
    return ($duration - $t) / $release if $t > $duration - $release;
    return 1.0;
}

write_wav("assets/audio/flap.wav", 0.16, sub {
    my ($t, $duration) = @_;
    my $freq = 740.0 + 260.0 * (1.0 - $t / $duration);
    return sin(2.0 * pi * $freq * $t) * env($t, $duration) * 0.35;
});

write_wav("assets/audio/score.wav", 0.22, sub {
    my ($t, $duration) = @_;
    my $freq = $t < 0.11 ? 880.0 : 1320.0;
    return sin(2.0 * pi * $freq * $t) * env($t, $duration) * 0.30;
});

write_wav("assets/audio/hit.wav", 0.28, sub {
    my ($t, $duration) = @_;
    my $freq = 180.0 - 70.0 * ($t / $duration);
    my $tone = sin(2.0 * pi * $freq * $t);
    my $noise = ((int($t * 13000) * 1103515245 + 12345) & 1023) / 512.0 - 1.0;
    return ($tone * 0.55 + $noise * 0.25) * env($t, $duration) * 0.40;
});
