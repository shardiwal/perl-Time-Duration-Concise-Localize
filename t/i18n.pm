package i18n;

use 5.006;
use strict;
use warnings FATAL => 'all';

use Moo;

has 'language' => (
    'is' => 'rw',
    'required' => 1
);

has 'translations' =>(
    'is'      => 'lazy',
    'default' => sub {
        return {
	        'hin-hin' => {
	    	    'days' 	  => 'दिन',
	    	    'day'  	  => 'दिन',
	    	    'hours'   => 'घंटे',
	    	    'hour'    => 'घंटे',
	    	    'minutes' => 'मिनट',
	    	    'minute'  => 'मिनट',
	    	    'seconds' => 'सेकंड्स',
	    	    'second'  => 'सेकंड्'
	        },
	        'ms-my' => {
	    	    'days' 	  => 'hari',
	    	    'day'  	  => 'hari',
	    	    'hours'   => 'jam',
	    	    'hour'    => 'jam',
	    	    'minutes' => 'minit',
	    	    'minute'  => 'minit',
	    	    'seconds' => 'saat',
	    	    'second'  => 'kedua'
	        }
        };
    }
);

has 'language_translation' => (
    'is' => 'lazy',
    'default' => sub {
        my ( $self ) = @_;
        return $self->translations->{
            $self->language
        };
    }
);

sub translate_time_duration {
    my ( $self, $value, $unit ) = @_;
    my $translations = $self->language_translation;

    if ( exists $translations->{$unit} ) {
        $unit = $translations->{$unit};
    }
    return "$value $unit";
}

1;
