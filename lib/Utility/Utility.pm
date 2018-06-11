package Utility;
use strict;
use warnings;
use DateTime;
use JSON;
use Term::ANSIColor qw(:constants);
local $Term::ANSIColor::AUTORESET = 1;

#** @method public systemcall ($command, $expected_return_code)
# @brief execute and return the system call stdout
# @brief if the $exp_return value applied, print the error message is return code is not match
# @return $output - system call stdout
#*
sub systemcall {
    my ($command, $exp_return) = @_;
    my $output = `$command`;
    my $return_code = $?;
    if (defined $exp_return && !($exp_return == $return_code)) {
        error("System Call [$command] return value is [$return_code] != [$exp_return]");
		return $return_code;
    }
    return $output;
}

#** @method public hash_to_array (%hash)
# @brief return the array value of an input hash
# @return @array
#*
sub hash_to_array {
    my $array = shift;
    my @array = values %{$array};
    return @array;
}

#** @method public read_json ($json_string)
# @brief return the perl object from input json string
# @return JSON
#*
sub get_json {
	my $input = shift @_;
	return decode_json($input);
}

################### Printing Methods ###################
# Printing methods for logging
########################################################
sub logging {
    my $string = shift @_;
    my $date = DateTime->now;
    print "[$date][LOG] $string\n";
}

sub warning {
    my $string = shift @_;
    my $date = DateTime->now;
    my ($package, $filename, $line) = caller;
    print BOLD YELLOW "[$date][WARNING] $string at $package:$filename:$line\n";
}

sub error {
    my $string = shift @_;
    my $date = DateTime->now;
    my ($package, $filename, $line) = caller;
    print BOLD RED "[$date][ERROR] $string at $package:$filename:$line\n";
}

sub debug {
    my $string = shift @_;
    my $date = DateTime->now;
    my ($package, $filename, $line) = caller;
    print BOLD BLUE "[$date][DEBUG] $string at $package:$filename:$line\n";
}
#########################################################
1;
#__END
