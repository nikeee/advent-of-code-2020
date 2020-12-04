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

	PassportField currentFields = PassportField.None;

	foreach(line; stdin.byLine) {

		auto strippedLine = strip(line.to!string);

		if ( strippedLine == "") {
			// The passport was finished

			++totalPassportCount;

			if ((currentFields & ~PassportField.cid) >= validPassport) {
				++validPassports;
			}

			currentFields = PassportField.None;
		}

		auto kvPairs = strippedLine.split;
		auto parsedFields = kvPairs.map!(readKeyValue);

		foreach(field; parsedFields) {
			currentFields |= to!PassportField(field.key);
		}
	}

	++totalPassportCount;
	if ((currentFields & ~PassportField.cid) >= validPassport) {
		++validPassports;
	}

	writefln("Found %d passports", totalPassportCount);
	writefln("%d were valid", validPassports);
}

KeyValueEntry readKeyValue(string keyValueString) {
	auto split_data = keyValueString.split(':');
	return KeyValueEntry(split_data[0], split_data[1]);
}
