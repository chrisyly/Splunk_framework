package MovieAPI;
use strict;
use warnings;
use Utility::Utility;
use REST::Client;
local $Term::ANSIColor::AUTORESET = 1;

################# Constants #################
# @brief REST Client initialize
my $RESTClient = REST::Client->new({
	host => 'https://splunk.mocklab.io',
	timeout => 10,
});
#############################################

#** @method public getMovie ($q, $count)
# @brief $q - the string name of the movie
# @brief $count - the total count of the movies getting from REST API
#*
sub getMovie {
	my ($q, $count) = @_;
	my $query = 'movies?';
	Utility::logging("Splunk Movies REST API GET request initialized...");
	if (not defined $q) {
		Utility::error('	Movie name is a must!');
		## return "TODO: Error code\n"; ## comment out for negative test
	} else {
		$query .= "q=$q";
		Utility::logging("	Movie name: [$q]");
	}
	if (not defined $count) {
		Utility::logging('	Number of count is not defined, using REST API default.');
	} else {
		$query .= "&count=$count";
		Utility::logging("	Movies shown in list: [$count]")
	}
	Utility::logging("Sending Splunk movie GET request: [https://splunk.mocklab.io/$query]");
	$RESTClient->GET($query, {'Accept' => 'application/json'});
}

#** @method public postMovie ($payload)
# @brief $payload - the content of the post request, example:{"name":"<string>superman", "description":"<string>ABC"}
#*
sub postMovie {
	my $payload = shift @_;
	my $query = 'movies';
	Utility::logging("Splunk Movies REST API POST request initialized...");
	if (not defined $payload) {
		Utility::error("	Payload content is a must!");
		## return "TODO: Error code\n"; ## comment out for negative test
	} else {
		Utility::logging("	Movie name and description:\n	[$payload]");
	}
	Utility::logging("Sending Splunk movie POST request: [https://splunk.mocklab.io/$query]");
	$RESTClient->POST($query, $payload, {'Content-Type' => 'application/json'});
}

#** @method public getResponseCode()
# @return $RESTClient->responseCode() - return the response code of the last request
#*
sub getResponseCode() {
	my $code = $RESTClient->responseCode();
	Utility::logging("	Return Code: [$code]");
	return $code;
}

#** @method public getResponseContent()
# @return $RESTClient->responseContent() - return the response content of the last request
#*
sub getResponseContent() {
	my $content = $RESTClient->responseContent();
	Utility::logging("	Return Content:\n	[$content]");
	return $content;
}

sub checkCode {
	my $code = shift @_;
	my $responseCode = $RESTClient->responseCode();
	if (defined $code && ($code eq $responseCode)) {
		Utility::debug("	Return Code [$responseCode] is equal to $code");
		return 1;
	} else {
		Utility::debug("	Return Code [$responseCode] is not equal to $code");
		return 0;
	}
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
