#!/usr/bin/perl

use Device::BCM2835;
use Time::HiRes qw( sleep );

my $pipepath = "/webblinker/cmdpipe";
#
# Expected format for each line is:
#	<position>,<newstate>
#
# Examples:
#	3,1  (Turn LED #3 on)
#	4,0  (Turn LED #4 off)
#	*,0  (Turn all LEDs off)
#	0,1  (Turn LED #0 on)
#

use strict;
Device::BCM2835::init() || die "Could not init library";
Device::BCM2835::spi_end();

my $serial = &Device::BCM2835::RPI_GPIO_P1_15;
my $clock = &Device::BCM2835::RPI_GPIO_P1_16;
my $strobe = &Device::BCM2835::RPI_GPIO_P1_18;
my $outputenable = &Device::BCM2835::RPI_GPIO_P1_19;

# Go!
# High:
#   Device::BCM2835::gpio_set($pin)
#
# Low:
#	Device::BCM2835::gpio_clr($pin)
Device::BCM2835::gpio_fsel($strobe, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
Device::BCM2835::gpio_fsel($serial, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
Device::BCM2835::gpio_fsel($clock, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
Device::BCM2835::gpio_fsel($outputenable, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);

Device::BCM2835::gpio_set($outputenable);
Device::BCM2835::delayMicroseconds(1);

open(my $cmdpipe, '<', $pipepath);

my $currentstate = "0b1111111111111111";

while (my $cmd = <$cmdpipe>) {
	next unless ($cmd =~ /^[0-9*]+,[01]/);

	chomp($cmd);
	my ($pos, $state) = split(/,/, $cmd);
	if ($pos eq "*") {
		if ($state) { $currentstate = 0b1111111111111111; }
		else        { $currentstate = 0b0000000000000000; }
	}
	elsif ($pos >= 0) {
		if ($state) { $currentstate |= 1<<$pos; }
		else        { $currentstate &= ~(1<<$pos); }
	}

	&setRegister($currentstate);
}

&setRegister(0b00000000);
exit 0;


sub setRegister {
	my $sendbit = shift(@_);
	#printf "Sendbit is 0b%08B\n", $sendbit;

	for (my $x = 15; $x > -1; $x--) {
		if ($sendbit & (1<<$x)) { Device::BCM2835::gpio_set($serial); }
		else                    { Device::BCM2835::gpio_clr($serial); }
		Device::BCM2835::delayMicroseconds(1);

		Device::BCM2835::gpio_set($clock);
		Device::BCM2835::delayMicroseconds(1);
		Device::BCM2835::gpio_clr($clock);
		Device::BCM2835::delayMicroseconds(1);
	}

	Device::BCM2835::gpio_set($strobe);
	Device::BCM2835::delayMicroseconds(1);
	Device::BCM2835::gpio_clr($strobe);
	Device::BCM2835::delayMicroseconds(1);
}
