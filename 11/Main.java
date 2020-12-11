// Compile:
//     javac Main.java
// Use:
//     java -ea Main input.txt

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

public class Main {
  enum Occupation {
    FLOOR('.'),
    EMPTY('L'),
    OCCUPIED('#'),
    ;
    private final char representation;

    Occupation(char representation) {
      this.representation = representation;
    }

    static Occupation parse(char value) {
      return Arrays.stream(Occupation.values())
          .filter(e -> e.representation == value)
          .findFirst()
          .orElseThrow();
    }
  }

  static List<Occupation> parseLine(String line) {
    return line.chars()
        .mapToObj(i -> (char) i)
        .map(Occupation::parse)
        .collect(Collectors.toUnmodifiableList());
  }

  public static void main(String[] args) throws IOException {
    var initialMap = Files.lines(Path.of(args[0]))
        .filter(line -> !"".equals(line.trim()))
        .map(Main::parseLine)
        .collect(Collectors.toUnmodifiableList());

    var part1 = countOccupiedSeatsIterated(initialMap, Main::getOccupationPart1);
    System.out.println("Number of occupied seats in part 1: " + part1);
  }

  static long countOccupiedSeatsIterated(List<List<Occupation>> initialMap, OccupationProcessor processor) {
    var map = initialMap;
    var prevMap = toStringMap(map);
    String mapStr = "";
    do {
      prevMap = mapStr;
      System.out.println(prevMap);

      map = iterate(map, processor);
      mapStr = toStringMap(map);
    } while (!prevMap.equals(mapStr));

    System.out.println(mapStr);

    return map.stream()
        .flatMap(Collection::stream)
        .filter(Occupation.OCCUPIED::equals)
        .count();
  }

  interface OccupationProcessor {
    Occupation getOccupation(int x, int y, List<List<Occupation>> map, int width, int height);
  }

  static List<List<Occupation>> iterate(List<List<Occupation>> inputMap, OccupationProcessor processor) {
    var mapWidth = inputMap.get(0).size();
    var mapHeight = inputMap.size();

    List<List<Occupation>> res = new ArrayList<>(mapHeight);
    for (int y = 0; y < mapHeight; ++y) {
      var row = new ArrayList<Occupation>(mapWidth);
      res.add(row);
      for (int x = 0; x < mapWidth; ++x) {
        var newValue = processor.getOccupation(x, y, inputMap, mapWidth, mapHeight);
        row.add(newValue);
      }
    }
    return res;
  }

  static Occupation getOccupationPart1(int x, int y, List<List<Occupation>> map, int width, int height) {
    var current = map.get(y).get(x);
    if (current == Occupation.FLOOR)
      return Occupation.FLOOR;

    int occupied = 0;
    for (int currentY = Math.max(y - 1, 0); currentY < Math.min(y + 2, height); ++currentY) {
      var row = map.get(currentY);

      for (int currentX = Math.max(x - 1, 0); currentX < Math.min(x + 2, width); ++currentX) {
        if (currentX == x && currentY == y)
          continue;

        var field = row.get(currentX);
        if (field == Occupation.OCCUPIED) {
            ++occupied;
        }
      }
    }

    if (current == Occupation.EMPTY && occupied == 0)
      return Occupation.OCCUPIED;
    if (current == Occupation.OCCUPIED && occupied >= 4)
      return Occupation.EMPTY;
    return current;
  }

  static String toStringMap(List<List<Occupation>> inputMap) {
    var mapWidth = inputMap.get(0).size();
    var mapHeight = inputMap.size();

    var sb = new StringBuilder();
    for (int y = 0; y < mapHeight; ++y) {
      for (int x = 0; x < mapWidth; ++x) {
        sb.append(inputMap.get(y).get(x).representation);
      }
      sb.append('\n');
    }
    return sb.toString();
  }
}
