#!/usr/bin/perl

use strict;
use warnings;
use Term::ANSIColor qw(:constants);
local $Term::ANSIColor::AUTORESET = 1;

use lib "../../lib";
use SAuto::SAuto;
use SAuto::Devices;
use Splunk::MovieAPI;

###################### Constants #######################

#################### Test Execution ######################
#** @brief execute the test!!!!!!!!
exit(&pretest & &test & &posttest);

###################### Test Body ########################
#** @method public pretest
# @brief set up environment before test
#*
sub pretest {
	#** remove/create the logs if necessary
	#** set up environment or loading necessary data
	SAuto::logging("Test Case: $0");
	return 0;
}

############################################################
#** @method public test
# @brief execute the test
#*
sub test {
	SAuto::debug("=============== Test Start ==================");
	MovieAPI::getMovie('batman');
	SAuto::checkPass(MovieAPI::checkCode(200), 1, "Splunk Movie Get response code:[".MovieAPI::getResponseCode()."] expecting [200]");
	## SAuto::logging("	Return content:\n".MovieAPI::getResponseContent());
	SAuto::checkPass(MovieAPI::SPL_001(), 0, "[SPL_001] No two movies should have the same image.");
	SAuto::checkPass(MovieAPI::SPL_002(), 0, "[SPL_002] All poster_path links must be valid. poster_path link of null is also acceptable.");
	SAuto::checkPass(MovieAPI::SPL_003(), 0, "[SPL_003] Checking the response is meeting sorting Rule #1/#2 requirements.");
	SAuto::checkPass(MovieAPI::SPL_004(), 0, "[SPL_004] The number of movies whose sum of \"genre_ids\" > 400 is no more than 7!");
	SAuto::checkPass(MovieAPI::SPL_005(), 0, "[SPL_005] There is at least one movie in the database whose title has a palindrome in it.");
	SAuto::checkPass(MovieAPI::SPL_006(), 0, "[SPL_006] There are at least two movies in the database whose title contain the title of another movie.");
	SAuto::debug("=============== Test Finished ================");
	return 0;
}

############################################################
#** @method public posttest
# @brief teardown the test environment
#*
sub posttest {
	my $result = SAuto::getSummary();
	SAuto::debug("======================= End of Test ======================");
	return $result;
}
