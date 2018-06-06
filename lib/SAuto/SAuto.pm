package SAuto;
use strict;
use warnings;
use DateTime;
use JSON;
use Term::ANSIColor qw(:constants);
local $Term::ANSIColor::AUTORESET = 1;

#** @method public systemcall ($command, $expected_return_code)
# @brief execute and return the system call stdout
# @brief if the $exp_return value applied, print and exit with 406 code if return code is not match (TEMP disabled)
# @return $output - system call stdout
#*
sub systemcall {
	my ($command, $exp_return) = @_;
	my $output = `$command`;
	my $return_code = $?;
	if (defined $exp_return && !($exp_return == $return_code)) {
		error("System Call return value is [$return_code] != [$exp_return]");
		# exit 406;
	}
	return $output;
}

################### Printing Methods ###################
# the same copy from Utility
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
