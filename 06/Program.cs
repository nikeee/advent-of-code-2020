// Use:
//     dotnet run < input.txt

using System;
using System.Linq;
using System.Collections.Generic;

const string alphabet = "abcdefghijklmnopqrstuvwxyz";

var anyoneAnsweredForms = new List<HashSet<char>>();
var anyoneAnswered = new HashSet<char>();

var allAnsweredForms = new List<HashSet<char>>();
var allAnswered = new HashSet<char>(alphabet.ToCharArray());

string? line = null;
while ((line = Console.ReadLine()?.Trim()) != null)
{
    if (line == string.Empty)
    {
        // Group is finished

        anyoneAnsweredForms.Add(anyoneAnswered);
        anyoneAnswered = new HashSet<char>();

        allAnsweredForms.Add(allAnswered);
        allAnswered = new HashSet<char>(alphabet.ToCharArray());
    }
    else
    {
        anyoneAnswered.UnionWith(line.ToCharArray());
        allAnswered.IntersectWith(line.ToCharArray());
    }
}

anyoneAnsweredForms.Add(anyoneAnswered);
allAnsweredForms.Add(allAnswered);

var part1 = anyoneAnsweredForms.Select(group => group.Count).Sum();
Console.WriteLine($"Total different answers of all groups (any answer counts); Part1: {part1}");

var part2 = allAnsweredForms.Select(group => group.Count).Sum();
Console.WriteLine($"Total different answers of all groups (all must answer the same); Part2: {part2}");
