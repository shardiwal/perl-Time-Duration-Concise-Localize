package Time::Duration::Concise;

use 5.006;
use strict;
use warnings FATAL => 'all';

use Time::Seconds;
use POSIX qw(floor ceil);
use Moo;
use Carp;

=head1 NAME

Time::Duration::Concise

=head1 DESCRIPTION

Time::Duration::Concise is an improved approach to convert concise time duration to string representation.

=head1 VERSION

Version 0.08

=cut

our $VERSION = '0.08';

our %LENGTH_TO_PERIOD = (
    86400 => 'day',
    3600  => 'hour',
    60    => 'minute',
    1     => 'second',
);

our %PERIOD_SIZES =
  map { substr( $LENGTH_TO_PERIOD{$_}, 0, 1 ) => $_ } keys %LENGTH_TO_PERIOD;

=head1 SYNOPSIS

    use Time::Duration::Concise;

    my $duration = Time::Duration::Concise->new(
        interval => '1h20m'
    );

    # Intervals can have decimal values
    1.5h etc

    my $duration = Time::Duration::Concise->new(
        interval => '1.5h'
    );

=head1 FIELDS

=head2 interval (REQUIRED)

=head2 Concise Format

The format is an integer followed immediatley by its duration
identifier.  White-space will be ignored.

The following table explains the format.

  identifier   duration
  ----------   --------
           d   day
           h   hour
           m   minute
           s   second

# Intervals can have decimal values
Example : 1.5h

=cut

has 'interval' => (
    is       => 'rw',
    required => 1
);

has 'seconds' => (
    is      => 'lazy',
    builder => '_build_in_seconds'
);

sub _build_in_seconds {
    my ($self) = @_;

    my $interval = $self->interval;

    if ( defined $interval ) {
        Carp::croak( "Invalid time interval" ) if $interval eq '';
    }

    my $known_units = $self->_known_units;

    my %seen;

    # Try our best to make it parseable.
    $interval =~ s/\s//g;
    $interval = lc $interval;

    # All numbers implies a number of seconds.
    if ( $interval !~ /[A-Za-z]/ ) {
        $interval .= 's';
        $self->interval($interval);
    }

    my $in_seconds = 0;

    # These should be integers, but we might need to have 0.5m
    while ( $interval =~ s/([+-]?\d*\.?\d+)([$known_units])// ) {
        my $amount = $1;
        my $units  = $2;

        if ( exists $seen{$units} ) {
            Carp::croak( "Bad format supplied ["
                  . $self->interval
                  . "]: duplicate key." );
        }

        $seen{$units} = undef;
        $in_seconds += $amount * $PERIOD_SIZES{$units};
    }

    if ( $interval ne '' ) {

 # We had something which didn't match the above, which renders this unparseable
        Carp::croak(
            "Bad format supplied [" . $self->interval . "]: unknown key." );
    }
    return int $in_seconds;
}

has 'duration' => (
    is      => 'lazy',
    default => sub {
        my ($self) = @_;
        my $time_ = Time::Seconds->new( $self->seconds );
        return {
            'pretty'  => $time_->pretty,
            'years'   => $time_->years,
            'months'  => $time_->months,
            'weeks'   => $time_->weeks,
            'days'    => $time_->days,
            'hours'   => $time_->hours,
            'minutes' => $time_->minutes,
            'seconds' => $time_->seconds
        };
    }
);

=head1 METHODS

=head2 seconds

The number of seconds represented by this time interval.

=head2 minutes

The number of minutes represented by this time interval.

=cut

sub minutes {
    my ($self) = @_;
    return $self->duration->{'minutes'};
}

=head2 hours

The number of hours represented by this time interval.

=cut

sub hours {
    my ($self) = @_;
    return $self->duration->{'hours'};
}

=head2 days

The number of days represented by this time interval.

=cut

sub days {
    my ($self) = @_;
    return $self->duration->{'days'};
}

=head2 weeks

The number of week represented by this time interval.

=cut

sub weeks {
    my ($self) = @_;
    return $self->duration->{'weeks'};
}

=head2 months

The number of months represented by this time interval.

=cut

sub months {
    my ($self) = @_;
    return $self->duration->{'months'};
}

sub _known_units {
    my ($self) = @_;
    return join( '', keys %PERIOD_SIZES );
}

=head2 as_string

Concise time druation to string representation.

=cut

sub as_string {
    my ( $self, $precision ) = @_;
    my $time_frames = $self->_duration_array($precision);
    return join( ' ', @$time_frames );
}

=head2 as_concise_string

Concise time druation to conscise string representation.

=cut

sub as_concise_string {
    my ( $self, $precision ) = @_;
    my $time_frames         = $self->_duration_array($precision);
    my @concise_time_frames = map {
        $_ =~ s/\s+//ig;
        $_ =~ /([-|\+]?\d+[A-Za-z]{1})/ig;
        $1;
    } @$time_frames;
    return join( '', @concise_time_frames );
}

=head2 normalized_code

The largest division of Duration

=cut

sub normalized_code {
    my ($self) = @_;
    my @keys = sort { $b <=> $a } keys %LENGTH_TO_PERIOD;

    my $entry_code = '0s';
    while ( $entry_code eq '0s' and my $period_length = shift @keys ) {
        if ( not $self->seconds % $period_length ) {
            my $period_size = $self->seconds / $period_length;
            $entry_code =
              $period_size . substr( $LENGTH_TO_PERIOD{$period_length}, 0, 1 );
        }
    }
    return $entry_code;
}

=head2 duration_array

Concise time druation to array

[ { value => 1, unit => 'day' }, { value => 2, unit => 'hours' } ]

=cut

sub duration_array {
    my ( $self, $precision ) = @_;
    my $durations = $self->_duration_array($precision);
    my @duration_distribution;
    foreach my $d (@$durations) {
        my @d_value_unit = split( ' ', $d );
        push(
            @duration_distribution,
            {
                'value' => $d_value_unit[0],
                'unit'  => $d_value_unit[1]
            }
        );
    }
    return \@duration_distribution;
}

sub _duration_array {
    my ( $self, $precision ) = @_;

    $precision ||= 10;

    my $pretty_format = $self->duration->{'pretty'};

    $pretty_format=~s/minus /-/ig;

    my @time_frame;
    my $precision_counter = 1;
    foreach my $frame ( split( ',', $pretty_format ) ) {
        next if $precision_counter > $precision;
        chomp $frame;
        $frame =~ s/^\s+|\s+$//g;
        $frame =~ s/s$//ig;
        $frame =~ /^([-|\+]?\d+\s)/ig;

        # Make sure we gets the number
        # to avoid Use of uninitialized warning
        my $value = $1;
        if ( defined $value && $value ) {

            $value =~s/\s+//ig;

            $frame = ''   if $value == 0;
            $frame .= 's' if $value > 1;

            if ( $frame ) {
                push( @time_frame, $frame );
                $precision_counter++;
            }
        }
    }
    if ( !scalar @time_frame ) {
        push ( @time_frame, '0 second' );
    }
    return \@time_frame;
}

=head2 minimum_number_of

Returns the minimum number of the given period.

=cut

sub minimum_number_of {
    my ( $self, $unit ) = @_;
    my $orig_unit = $unit;
    $unit =~ s/s$// if ( length($unit) > 1 ); # Chop plurals, but not 's' itself
    $unit = substr( $unit, 0, 1 );
    $unit = 'mo' if $orig_unit =~ /months/ig;

    my %unit_maps = (
        'mo' => 'months',
        'w'  => 'weeks',
        'd'  => 'days',
        'h'  => 'hours',
        'm'  => 'minutes',
        's'  => 'seconds',
    );
    my $method = $unit_maps{$unit};
    confess "Cannot determine period for $orig_unit" unless ($method);

    return ceil( $self->$method );
}

=head1 AUTHOR

Binary.com, C<< <perl at binary.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-time-duration-concise-localize at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Time-Duration-Concise-Localize>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Time::Duration::Concise


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Time-Duration-Concise-Localize>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Time-Duration-Concise-Localize>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Time-Duration-Concise-Localize>

=item * Search CPAN

L<http://search.cpan.org/dist/Time-Duration-Concise-Localize/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Binary.com.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;    # End of Time::Duration::Concise
