#! /usr/bin/perl
use strict;
use warnings;
use JSON;
use Time::Local 'timelocal';


=head1 NAME

invent-sampl.pl - emit bogus bus usage statistics as NDJSON

=head1 DESCRIPTION

Produce a sample of bus stats for use as input to analysis programs
(which can then come into existence), without leaking real statistics
(which must be kept secret).

Written for Hinxton RT #501712.

=head1 FIELDS

Description of the supplied fields, with information about the known
ambiguities.

=over 4

=item label

The "number" of the bus.  Some are not labelled, or have letters.
Labels are not unique.

=item name

The name of the route.  This should identify the journey, but there
may be several names for a particular route used in different places.

=item direction

am = to campus, pm = from campus

=item capacity

Nominal capacity of the route in seats.  For various reasons, the
actual passenger count can be more than this.

Sometimes the capacity is carried by more than one vehicle - in these
cases, the single "time" field will apply to one of them and there may
be no record of which.

=item count

Number of people carried.  Whether this includes children sitting on
laps may depend on the driver.

=item provenance

Tell something about where the data came from.

Currently likely sources are this program, and the spreadsheet
maintained by Security (for which there is as yet no parser).

=item split

Some routes require a separate count of passengers by Institute, for
funding reasons.  This field carries that, and the total should match
C<count>.

=item taxi_txt

Human-readable description of taxi or other vehicles used to
supplement the bus(es) on a route.  Probably records only those payed
for by Campus, and probably in addition to C<count>.

=item time

An ISO8601 datetime or date telling when the bus arrives on (am) or
departs from (pm) the Campus.  Where the time was not recorded, this
will be a plain date.

Time precision may be to the second, but recent (2015) data most
likely is to the minute.  Where this is known, the seconds field is
omitted.

=item id

An identifier for the route travelled which is sufficiently unique to
identify the stops which should have been visited.

B<This field is not provided>.  The record of what the route was, for
a C<(name, direction, time)> tuple could probably be extracted from
the historic record of bus timetables on Helix if those HTML tables
could be reliably parsed.

=back

=cut

sub main {
  srand(12345);
  my @route =
    ({ label => "1", name => "Cambridge - 08:00", capacity => 53,
       _days => '12345',
       _avg => 53, _noise => -2, _droop => 0,
       _time => '08:28', direction => 'am' },
     { label => "SW", name => "Saffron Walden 08:30", capacity => 38,
       _days => '12345',
       _avg => 25, _noise => 3, _droop => 2,
       _time => '08:48', direction => 'am' },
     { label => "SW", name => "Saffron Walden 09:00", capacity => 38,
       _days => '12345',
       _avg => 17, _noise => 7, _droop => 8,
       _time => '09:17', direction => 'am' },
     { label => "1", name => "Cambridge Centre - 17:30", capacity => 79,
       _days => '12345',
       _avg => 73, _noise => 6, _droop => 15,
       _time => '17:30', direction => 'pm'},
     { label => "-", name => "Weekend Service - 10am arrival", capacity => 16,
       _days => "06",
       _avg => 7, _noise => 4, _droop => 3 });

  foreach my $day (qw( 2015-06-29 2015-06-30 2015-07-01 2015-07-02 2015-07-03 2015-07-04 2015-07-05 )) {
    foreach my $R (@route) {
      show($day, $R);
    }
  }

  foreach my $day (qw( 2015-07-06 2015-07-07 2015-07-08 2015-07-09 2015-07-10 2015-07-11 2015-07-12 )) {
    foreach my $R (@route) {
      show($day, $R);
    }
  }

  return 0;
}

exit main();


sub show {
  my ($day, $R_template) = @_;
  my %R =
    (%$R_template, provenance => 'invent-sample.pl');
  my %hint = map {($_ => delete $R{$_})}
    grep { /^_/ } keys %R;

  my ($Y, $M, $D) = $day =~ m{^(\d{4})-(\d{2})-(\d{2})$} or die "day=$day ?";
  my $wkday = (localtime(timelocal(0, 0,12,  $D, $M-1, $Y-1900)))[6];
  return unless $hint{_days} =~ /$wkday/;

  my $droop_day = $wkday =~ /[12345]/ ? $wkday - 1 : !$wkday;
  my $droop = $droop_day * $hint{_droop} / (length($hint{_days})-1);
  my $noise = $hint{_noise} > 0 ? rand($hint{_noise} * 2) - $hint{_noise} : -rand($hint{_noise});
  $R{count} = int($hint{_avg} - $droop - $noise + 0.5);
  if ($wkday =~ /[06]/) {
    my $s = 0.25 + rand(1) * 0.75;
    $R{split} = { sanger => int($R{count} * $s + 0.5),
		  ebi    => int($R{count} * (1-$s) + 0.5) };
  }

  if (defined $hint{_time}) {
    my $t = $hint{_time};
    $t =~ s{:(\d+)}{sprintf(":%02d", int($1 + rand(6)))}e;
    $R{time} = "$day $t";
  } else {
    $R{time} = $day;
  }

  $R{taxi_txt} = "staffname: taxi for why, N people, £cost"
    if rand(1) < 0.03;

  # jsonlines / ndjson
  my $J = JSON->new->utf8->pretty(0);
  print $J->encode(\%R);
#  print map {"$_\n"} keys %R;
  print "\n";

  return;
}
