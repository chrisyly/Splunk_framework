package MovieAPI;
use strict;
use warnings;
use Utility::Utility;
use REST::Client;
local $Term::ANSIColor::AUTORESET = 1;

################# Constants #################
my $RESTClient = REST::Client->new({
	host => 'https://splunk.mocklab.io',
	timeout => 10,
});
$RESTClient->addHeader('Accept', 'application/json');
#############################################

sub getMovie {
	my ($q, $count) = @_;
	my $query = 'movies?';
	if (not defined $q) {
		Utility::error('Movie name is a must!');
		return 'TODO: Error code';
	} else {
		$query .= "q=$q";
	}
	if (not defined $count) {
		Utility::logging('Number of count is not defined, using REST API default.');
	} else {
		$query .= "&count=$count";
	}

	Utility::logging("Sending Splunk movie GET request: https://splunk.mocklab.io/$query");
	$RESTClient->GET($query);
	return $RESTClient->responseContent();
}

#** @method public report_generator ($input_result_line)
# @brief return the double array for generating the report
# @return @report double arrary
#*

sub report_generator {
    my $line = shift @_;
    my $regex_string = shift @_;
    my @report;
    my @matches = ($line =~ /$regex_string/);
    my $j = 0;
    for (my $i = 0; $i < @matches; $i = ($i+2)) {
        $report[0][$j] = $matches[$i];
        $report[1][$j] = $matches[$i+1];
        $j++;
    }
    return @report;
}

1;
