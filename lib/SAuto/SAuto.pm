package SAuto;
use strict;
use warnings;
use DateTime;
use JSON;
use Utility::Utility;
use Term::ANSIColor qw(:constants);
local $Term::ANSIColor::AUTORESET = 1;

#################### Constents ###################
our $pass = 0; #** @brief the pass count for the test
our $fail = 0; #** @brief the failure count for the test

#** @method public systemcall ($command, $expected_return_code)
# @brief execute and return the system call stdout
# @brief if the $exp_return value applied, print and exit with 406 code if return code is not match (TEMP disabled)
# @return $output - system call stdout
# NOTE: This is a stand alone systemcall, its the same systemcall in Utility:systemcall
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

################### Printing Methods ###################
# the same copy from Utility
########################################################
sub logging {
    my $string = shift @_;
    Utility::logging($string);
}

sub warning {
    my $string = shift @_;
	Utility::warning($string);
}

sub error {
    my $string = shift @_;
	Utility::error($string);
}

sub debug {
    my $string = shift @_;
	Utility::debug($string);
}
#########################################################

#** @method pass ($message)
# @brief increment pass count, if $message is provided print out the pass info
#*
sub pass {
	my $message = shift @_;
	$pass++;
	if (defined $message) {
		my $date = DateTime->now;
		my ($package, $filename, $line) = caller;
		print BOLD GREEN "[$date][PASS] 	$message\n";
	}
}

#** @method fail ($message)
# @brief increment fail count, if $message is provided print out the fail info
#*
sub fail {
	my $message = shift @_;
	$fail++;
	if (defined $message) {
		my $date = DateTime->now;
		my ($package, $filename, $line) = caller;
		print BOLD RED "[$date][FAIL] 	$message\n";
	}
}

#** @method checkPass ($flag, $exp_flag, $message)
# @brief check if the $flag(bool) is equal to $exp_flag(bool), increment pass or fail count
#*
sub checkPass {
	my ($flag, $exp_flag, $message) = @_;
	if ($flag == $exp_flag) {
		pass($message);
	} else {
		fail($message);
	}
}

#** @method getTotalCount
# @brief return the total $pass + $fail count
#*
sub getTotalCount {
	return ($pass + $fail);
}

#** @method getPassCount
# @brief return the $pass count
#*
sub getPassCount {
	return $pass;
}

#** @method getFailCount
# @brief return the $fail count
#*
sub getFailCount {
	return $fail;
}

#** @method getSummary
# @brief print pass/fail/total test counter to the stdout
# @return false if there is any test failed
#*
sub getSummary {
	logging("=================== Summary session =======================");
	logging("Total check points: ".getTotalCount());
	logging("Pass Count: $pass");
	logging("Failure Count: $fail");
	logging("===========================================================");
	if ($fail) {
		return 1;
	}
}

1;
#__END
