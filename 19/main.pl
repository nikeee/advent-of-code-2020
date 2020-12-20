#!/usr/bin/env perl
# Use:
#      ./main.pl < input.txt
# Runtime version:
#     perl --version
#     This is perl 5, version 30, subversion 3 (v5.30.3) built for x86_64-linux-gnu-thread-multi

@input = <STDIN>;
my ($rules, $words) = split("\n\n", join("", @input));

@rules = split("\n", $rules);
@words = split("\n", $words);

sub ParseRules {
	my @rules = @_;

	%parsedRules = ();
	foreach (@rules) {
		my ($ruleNumberStr, $optionsStr) = split(":", $_);

		my $ruleNumber = $ruleNumberStr + 0;

		$optionsStr =~ s/^\s+|\s+$//g; # trim
		$parsedRules{$ruleNumber} = $optionsStr;
	}

	return %parsedRules;
}

# Part 1
# The rules of the input are basically a context free grammar (CFG).
# But as the grammar does not contain a loop, it can also be represented as a regular expression.
# We could do it the hard way and basically implement regular expression matching, but we're using Perl here.

sub CreatePattern {
	my ($ruleNumber, $recursionDepth, %rules) = @_;

	if ($recursionDepth > 100) {
		# See notes on part 2 about this
		return '';
	}

	my $optionsStr = $rules{$ruleNumber};
	$optionsStr =~ s/^\s+|\s+$//g; # trim
	my @options = split("\\|", $optionsStr);

	my @optionPatterns = map { CreateOptionPattern($_, $recursionDepth, %rules) } @options;

	return '(' . join("|", @optionPatterns) . ')';
}

sub CreateOptionPattern {
	my ($option, $recursionDepth, %rules) = @_;
	$option =~ s/^\s+|\s+$//g; # trim

	my @descendingRulesStr = split(" ", $option);

	if (scalar @descendingRulesStr == 1) {
		if ($descendingRulesStr[0] =~ m/"/) {
			my $terminal = $descendingRulesStr[0];
			$terminal =~ s/"//g;
			return $terminal;
		}
	}

	my $pattern = '';
	foreach (@descendingRulesStr) {
		my $descendingRuleNumber = $_;
		$pattern .= CreatePattern($descendingRuleNumber, $recursionDepth + 1, %rules);
	}
	return $pattern;
}

my %parsedRules;
my $pattern;

%parsedRules = ParseRules(@rules);

$pattern = CreatePattern(0, 0, %parsedRules);
$pattern = qr/^$pattern$/; # Perf trick: Force compilation of regex: https://stackoverflow.com/a/53339431

my $part1 = scalar grep(/$pattern/, @words);
print "Number of valid words; Part 1: $part1\n";

# Part 2
# We now have loops inside the grammar. This means, we cannot represent it as a regular expression anymore.
# However, the task hints this:
#     "you only need to handle the rules you have"

# Let's be hacky here: The input words could maybe be validated by using a finite representation of the CFG.
# This means we can still try to use regex, while being aware that it doesn't cover all words in the set of our language.
# We just hope it covers enough.
# Bonus: Our solution will still yield the same results for part 1.

push @rules, "8: 42 | 42 8";
push @rules, "11: 42 31 | 42 11 31";

%parsedRules = ParseRules(@rules);

$pattern = CreatePattern(0, 0, %parsedRules);
$pattern = qr/^$pattern$/; # Perf trick: Force compilation of regex: https://stackoverflow.com/a/53339431

my $part2 = scalar grep(/$pattern/, @words);
print "Number of valid words (with loops in grammar); Part 2: $part2\n";
