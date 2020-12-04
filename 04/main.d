// Use:
//     dmd -run main.d < input.txt
// Using docker:
//     docker run --rm -ti -v $(pwd):/src dlanguage/dmd dmd -run main.d < input.txt

import std.stdio, std.string, std.conv, std.array, std.algorithm, std.typecons;

enum PassportField
{
	None = 0,
	byr = 1 << 0,
	iyr = 1 << 1,
	eyr = 1 << 2,
	hgt = 1 << 3,
	hcl = 1 << 4,
	ecl = 1 << 5,
	pid = 1 << 6,
	cid = 1 << 7,
};

// It's okay to miss cid
const PassportField validPassport = PassportField.byr
									| PassportField.iyr
									| PassportField.eyr
									| PassportField.hgt
									| PassportField.hcl
									| PassportField.pid
									| PassportField.ecl;

alias KeyValueEntry = Tuple!(string, "key", string, "value");

void main()
{
	int totalPassportCount = 0;
	int validPassports = 0;

	string[PassportField] currentPassport;

	foreach(line; stdin.byLine) {

		auto strippedLine = strip(line.to!string);

		if ( strippedLine == "") {
			// The passport was finished

			++totalPassportCount;
			if (isValidPassportPart1(currentPassport)) {
				++validPassports;
			}

			currentPassport.clear();
		}

		auto kvPairs = strippedLine.split;
		auto parsedFields = kvPairs.map!(readKeyValue);

		foreach(field; parsedFields) {
			currentPassport[to!PassportField(field.key)] = field.value;
		}
	}

	++totalPassportCount;
	if (isValidPassportPart1(currentPassport)) {
		++validPassports;
	}

	writefln("Found %d passports", totalPassportCount);
	writefln("%d were valid", validPassports);
}

bool isValidPassportPart1(string[PassportField] passport) {
	if (PassportField.cid in passport) {
		return passport.length == 8;
	}
	return passport.length == 7;
}

KeyValueEntry readKeyValue(string keyValueString) {
	auto split_data = keyValueString.split(':');
	return KeyValueEntry(split_data[0], split_data[1]);
}
