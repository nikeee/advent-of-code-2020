// Use:
//     dotnet run < input.txt

#nullable enable

using System;
using System.Linq;
using System.Collections.Generic;

var forms = new List<HashSet<char>>();

var currentGroup = new HashSet<char>();

string? line = null;
while ((line = Console.ReadLine()) != null)
{
    if (line == string.Empty) {
        forms.Add(currentGroup);
        currentGroup = new HashSet<char>();
    }

    foreach(var c in line.ToCharArray())
        currentGroup.Add(c);
}
forms.Add(currentGroup);

var part1 = forms.Select(group => group.Count).Sum();

Console.WriteLine($"Total different answers of all groups; Part1: {part1}");
