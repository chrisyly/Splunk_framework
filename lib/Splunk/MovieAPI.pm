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
# @brief @param $q - the string name of the movie
# @brief @param $count - the total count of the movies getting from REST API
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
# @brief @param $payload - the content of the post request, example:{"name":"<string>superman", "description":"<string>ABC"}
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
sub getResponseCode {
	my $code = $RESTClient->responseCode();
	Utility::logging("	Return Code: [$code]");
	return $code;
}

#** @method public getResponseContent()
# @return $RESTClient->responseContent() - return the response content of the last request
#*
sub getResponseContent {
	my $content = $RESTClient->responseContent();
	Utility::logging("	Return Content:\n	[$content]");
	return $content;
}

#** @methoc public checkCode ($code)
# @brief check if the $RESTClient->responseCode() is equal to $code
# @return ture if is equal, otherwise false
#*
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

#** @method public SPL_001 ()
# @brief No two movies should have the same image (poster_path in response)
#*
sub SPL_001 {
	my $json = Utility::get_json($RESTClient->responseContent());
	my @lists = @{$json->{results}};
	my %count;
	Utility::logging("======= SPL_001 =======");
	foreach my $movie (@lists) {
		# check if poster_path duplicate
		if ($count{$movie->{poster_path}}++) {
			Utility::warning("	Movie id:[$movie->{id}] name:[$movie->{title}] with the same image url:[$movie->{poster_path}] detected!");
			return 1;
		}
	}
	Utility::logging("	Movies do not have the same image!");
	return 0;
}

#** @method public SPL_002 ()
# @brief All poster_path links must be valid. poster_path link of null is also acceptable
# *
sub SPL_002 {
	my $json = Utility::get_json($RESTClient->responseContent());
	my @lists = @{$json->{results}};
	Utility::logging("======= SPL_002 =======");
	foreach my $movie (@lists) {
		# check if poster_path is valid
		if (defined $movie->{poster_path}) {
			if (Utility::systemcall("curl --output /dev/null --head --silent --fail \"$movie->{poster_path}\"", 0)) {
				Utility::warning("	Movie id:[$movie->{id}] name:[$movie->{title}] has a invalid non null image url:[$movie->{poster_path}]");
				return 1;
			}
		}
	}
	return 0;
}

#** @method public SPL_003 ()
# @brief Sorting requirement:
# @brief Rule #1 Movies with genre_ids == null should be first in response.
# @brief Rule #2, if multiple movies have genre_ids == null, then sort by id (ascending). For movies that have non-null genre_ids, results should be sorted by id (ascending)
#*

## NOTE: is this required to sort the response or checking the response is sorted?
sub SPL_003 {
	my $json = Utility::get_json($RESTClient->responseContent());
	my @lists = @{$json->{results}};
	my $isNull = 1;
	my $id = -1;
	Utility::logging("======= SPL_003 =======");
	## check the response is sorted correctly
	foreach my $movie (@lists) {
		if (!@{$movie->{genre_ids}} && $isNull) {
			if ($movie->{genre_ids} > $id) {
				$id = $movie->{id};
			} else {
				Utility::warning("	Movie [$movie->{title}] has null genre_ids but id:[$movie->{title}] is less than previous id:[$id]! Breaking Rule #2");
				return 1;
			}
		} elsif (!@{$movie->{genre_ids}} && !$isNull) {
			Utility::warning("	Movie [$movie->{title}] has null genre_ids but previous genre_ids is not null! Breaking Rule #1");
			return 1;
		} elsif (@{$movie->{genre_ids}} && $isNull) {
			$isNull = 0;
			$id = $movie->{id};
		} elsif (@{$movie->{genre_ids}} && !$isNull) {
			if($movie->{id} > $id) {
				$id = $movie->{id};
			} else {
				Utility::warning("  Movie [$movie->{title}] has non null genre_ids but id:[$movie->{title}] is less than id:[$id]! Breaking Rule #2");
				return 1;
			}
		}
	}
	return 0;
}

#** @method public SPL_004 ()
# @brief The number of movies whose sum of "genre_ids" > 400 should be no more than 7.
#*
sub SPL_004 {
	my $json = Utility::get_json($RESTClient->responseContent());
	my @lists = @{$json->{results}};
	my $count = 0;
	Utility::logging("======= SPL_004 =======");
	foreach my $movie (@lists) {
		my $sum = 0;
		foreach my $genre_ids (@{$movie->{genre_ids}}) {
			$sum += $genre_ids;
		}
		if ($sum > 400) {
			Utility::logging("	Movie:[$movie->{title}] Id:[$movie->{id}] - Genre_ids:[$sum]");
			$count++;
		}
		if ($count > 7) {
			Utility::warning("	The number of movies whose sum of \"genre_ids\" > 400 is greater than 7!");
			return 1;
		}
	}
	return 0;
}

#** @method public SPL_005 ()
# @brief There is at least one movie in the database whose title has a palindrome in it.
# @brief Example: "title": "Batman: Return of the Kayak Crusaders". The title contains ‘kayak’ which is a palindrome.
#*
sub SPL_005 {
	my $json = Utility::get_json($RESTClient->responseContent());
	my @lists = @{$json->{results}};
	Utility::logging("======= SPL_005 =======");
	foreach my $movie (@lists) {
		if (is_palindrome($movie->{title})) {
			Utility::logging("	Movie: [$movie->{title}] has the palindrome!");
			return 0;
		}
	}
	Utility::warning("	The movie with title contains palindrome is not found!");
	return 1;
}

#** @method public is_palindrome ($string_line_input)
# @brief Remove the punctuations and check each word in a line if its palindrome
# @return true if palindrome is found in the give string, else false
#*
sub is_palindrome {
	my $line = shift @_;
	$line =~ s/[[:punct:]]//g;
	$line = lc $line;
	my @words = split / /, $line;
	foreach my $word (@words) {
		if ($word eq reverse($word)){
			return 1;
		}
	}
	return 0;
}

#** @method public SPL_006 ()
# @brief There are at least two movies in the database whose title contain the title of another movie.
# @brief Example: movie id: 287757 (Scooby-Doo Meets Dante), movie id: 404463 (Dante). This example shows one such set. The business requirement is that there are at least two such occurences. 
#*
sub SPL_006 {
	my $json = Utility::get_json($RESTClient->responseContent());
	my @lists = @{$json->{results}};
	my $count = 0;
	Utility::logging("======= SPL_006 =======");
	for (my $i = 0; $i < scalar @lists; $i++) {
		for (my $j = 0; $j < scalar @lists; $j++) {
			if ($i != $j && $lists[$i]->{title} =~ m/$lists[$j]->{title}/) {
				Utility::logging("	Movie:[$lists[$i]->{title}] contains the title of another movie:[$lists[$j]->{title}]");
				$count++;
				if ($count > 1) {
					return 0;
				}
			}
		}
	}
	Utility::warning("	The movie that contains the title of another movie is not found in the database!");
	return 1;
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
