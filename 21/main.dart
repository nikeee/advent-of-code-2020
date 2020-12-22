// Compile:
//     dart compile exe main.dart
// Run:
//     ./main.exe < input.txt


import 'dart:async';
import 'dart:io';
import 'dart:convert';

RegExp allergenPattern = new RegExp(r'\(contains (.+)\)$');

void main(List<String> arguments) async {

  List<List> foods = await stdin
    .transform(utf8.decoder)
    .transform(const LineSplitter())
    .map(processLine)
    .toList();

  var allAllergens = foods.map((food) => food[1]).expand((e) => e).toSet();
  var allIngredients = foods.map((food) => food[0]).expand((e) => e).toSet();

  Map resolvedAllergens = new Map<String, String>();

  while (resolvedAllergens.length < allAllergens.length) {

    var remainingAllergens = allAllergens.difference(Set.of(resolvedAllergens.keys));

    remainingAllergens.forEach((allergen) {
      var ingredientsMayContainingCurrentAllergen = foods.where((f) => f[1].contains(allergen)).map((f) => f[0]).toSet();

      var candidates = allIngredients;
      ingredientsMayContainingCurrentAllergen.forEach((c) => candidates = candidates.intersection(c));

      candidates = candidates.difference(Set.of(resolvedAllergens.values));

      if (candidates.length == 1) {
        var resolvedIngredient = candidates.first;
        resolvedAllergens[allergen] = resolvedIngredient;
      }
    });
  }

  var safeIngredients = allIngredients.difference(Set.of(resolvedAllergens.values));

  var part1 = foods.map((f) => safeIngredients.intersection(f[0]).length).fold(0, (p, c) => p + c);
  print("Number of safe ingredients appering; Part 1: ${part1}");

  var sortedResolvedAllergens = resolvedAllergens.entries.toList();
  sortedResolvedAllergens.sort((a, b) => a.key.compareTo(b.key));
  var dangerousIngredients = sortedResolvedAllergens.map((entry) => entry.value).join(',');

  print("What is your canonical dangerous ingredient list; Part 2: ${dangerousIngredients}");

}

List processLine(String line) {
  var match = allergenPattern.allMatches(line).elementAt(0);

  var allergensArray = match.group(1).split(', ');
  var ingredientsArray = line.split('(')[0].trim().split(' ');

  var allergens = Set.of(allergensArray);
  var ingredients = Set.of(ingredientsArray);

  return [ingredients, allergens];
}
