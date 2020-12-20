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

my %parsedRules = ParseRules(@rules);

# Part 1
# The rules of the input are basically a context free grammar (CFG).
# But as the grammar does not contain a loop, it can also be represented as a regular expression.
# We could do it the hard way and basically implement regular expression matching, but we're using Perl here.

sub CreatePattern {
	my ($ruleNumber, %rules) = @_;

	my $optionsStr = $rules{$ruleNumber};
	$optionsStr =~ s/^\s+|\s+$//g; # trim
	my @options = split("\\|", $optionsStr);

	my @optionPatterns = map { CreateOptionPattern($_, %rules) } @options;

	return '(' . join("|", @optionPatterns) . ')';
}

sub CreateOptionPattern {
	my ($option, %rules) = @_;
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
		$pattern .= CreatePattern($descendingRuleNumber, %rules);
	}
	return $pattern;
}

my $pattern = CreatePattern(0, %parsedRules);

my @validWords = grep(/^$pattern$/, @words);
my $part1 = scalar @validWords;
print "Number of valid words; Part 1: $part1\n";
