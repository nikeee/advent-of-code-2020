// Use:
//     dmd -run main.d < input.txt
// Using docker:
//     docker run --rm -ti -v $(pwd):/src dlanguage/dmd dmd -run main.d < input.txt

import std.stdio, std.string, std.conv, std.array, std.algorithm, std.typecons, std.regex, std.algorithm.searching, std.ascii;

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

alias KeyValueEntry = Tuple!(string, "key", string, "value");

static color = regex(r"^#[0-9a-f]{6}$");
static passportId = regex(r"^\d{9}$");

void main()
{
	int totalPassportCount = 0;
	int validPassportsPart1 = 0;
	int validPassportsPart2 = 0;

	string[PassportField] currentPassport;

	foreach(line; stdin.byLine) {

		auto strippedLine = strip(line.to!string);

		if (strippedLine == "") {
			// The passport was finished

			++totalPassportCount;
			if (isValidPassportPart1(currentPassport)) {
				++validPassportsPart1;

				if (isValidPassportPart2(currentPassport))
					++validPassportsPart2;
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
		++validPassportsPart1;
		if(isValidPassportPart2(currentPassport))
			++validPassportsPart2;
	}

	writefln("Total passports checked: %d", totalPassportCount);
	writefln("Valid passports accoring to part 1: %d", validPassportsPart1);
	writefln("Valid passports accoring to part 2: %d", validPassportsPart2);
}

bool isValidPassportPart1(string[PassportField] passport) {
	if (PassportField.cid in passport) {
		return passport.length == 8;
	}
	return passport.length == 7;
}

bool isValidPassportPart2(string[PassportField] passport) {
	foreach(field, value; passport) {
		if (!validateField(field, value)) {
			// writeln("Invalid field value; ", field, " ", value);
			return false;
		}
	}
	return true;
}

bool validateField(PassportField field, string value) {
	final switch (field) {
		case PassportField.None: return true;
		case PassportField.byr: return 1920 <= to!int(value) && to!int(value) <= 2002;
		case PassportField.iyr: return 2010 <= to!int(value) && to!int(value) <= 2020;
		case PassportField.eyr: return 2020 <= to!int(value) && to!int(value) <= 2030;
		case PassportField.hgt: {
			if (value.endsWith("cm")) {
				auto cm = to!int(strip(value, "cm"));
				return 150 <= cm && cm <= 193;
			} else if (value.endsWith("in")) {
				auto inch = to!int(strip(value, "in"));
				return 59 <= inch && inch <= 76;
			}
			return false;
		}
		case PassportField.hcl: return !!matchFirst(value, color);
		case PassportField.ecl: return ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"].canFind(value);
		case PassportField.pid: return !!matchFirst(value, passportId);
		case PassportField.cid: return true;
	}
}

KeyValueEntry readKeyValue(string keyValueString) {
	auto split_data = keyValueString.split(':');
	return KeyValueEntry(split_data[0], split_data[1]);
}
