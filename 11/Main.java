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
  private static final char FLOOR = '.';
  private static final char EMPTY = 'L';
  private static final char OCCUPIED = '#';

  static List<Character> parseLine(String line) {
    return line.chars()
        .mapToObj(i -> (char) i)
        .collect(Collectors.toUnmodifiableList());
  }

  public static void main(String[] args) throws IOException {
    var initialMap = Files.lines(Path.of(args[0]))
        .filter(line -> !"".equals(line.trim()))
        .map(Main::parseLine)
        .collect(Collectors.toUnmodifiableList());

    var part1 = countOccupiedSeatsIterated(initialMap, Main::getOccupationPart1);
    System.out.println("Number of occupied seats in part 1: " + part1);

    var part2 = countOccupiedSeatsIterated(initialMap, Main::getOccupationPart2);
    System.out.println("Number of occupied seats in part 2: " + part2);
  }

  static long countOccupiedSeatsIterated(List<List<Character>> initialMap, OccupationProcessor processor) {
    var map = initialMap;
    var prevMap = toStringMap(map);
    String mapStr = "";
    do {
      prevMap = mapStr;
      // System.out.println(prevMap);

      map = iterate(map, processor);
      mapStr = toStringMap(map);
    } while (!prevMap.equals(mapStr));

    return map.stream()
        .flatMap(Collection::stream)
        .filter(c -> c == OCCUPIED)
        .count();
  }

  interface OccupationProcessor {
    char getOccupation(int x, int y, List<List<Character>> map, int width, int height);
  }

  static List<List<Character>> iterate(List<List<Character>> inputMap, OccupationProcessor processor) {
    var mapWidth = inputMap.get(0).size();
    var mapHeight = inputMap.size();

    List<List<Character>> res = new ArrayList<>(mapHeight);
    for (int y = 0; y < mapHeight; ++y) {
      var row = new ArrayList<Character>(mapWidth);
      res.add(row);
      for (int x = 0; x < mapWidth; ++x) {
        var newValue = processor.getOccupation(x, y, inputMap, mapWidth, mapHeight);
        row.add(newValue);
      }
    }
    return res;
  }

  static char getOccupationPart1(int x, int y, List<List<Character>> map, int width, int height) {
    var current = map.get(y).get(x);
    if (current == FLOOR)
      return FLOOR;

    int occupied = 0;
    for (int currentY = Math.max(y - 1, 0); currentY < Math.min(y + 2, height); ++currentY) {
      var row = map.get(currentY);

      for (int currentX = Math.max(x - 1, 0); currentX < Math.min(x + 2, width); ++currentX) {
        if (currentX == x && currentY == y)
          continue;

        var field = row.get(currentX);
        if (field == OCCUPIED) {
            ++occupied;
        }
      }
    }

    if (current == EMPTY && occupied == 0)
      return OCCUPIED;
    if (current == OCCUPIED && occupied >= 4)
      return EMPTY;
    return current;
  }

  static char getOccupationPart2(int x, int y, List<List<Character>> map, int width, int height) {
    var current = map.get(y).get(x);
    if (current == FLOOR)
      return FLOOR;

    int occupied = 0;
    for(int walkDirX = -1; walkDirX <= 1; ++walkDirX) {
      for(int walkDirY = -1; walkDirY <= 1; ++walkDirY) {
        if (!(walkDirX == 0 && walkDirY == 0)) {
          occupied += countSeatsInSight(x, y, map, width, height, walkDirX, walkDirY);
        }
      }
    }

    if (current == EMPTY && occupied == 0)
      return OCCUPIED;
    if (current == OCCUPIED && occupied >= 5)
      return EMPTY;
    return current;
  }

  static int countSeatsInSight(int originX, int originY, List<List<Character>> map, int width, int height, int walkDirX, int walkDirY) {
    int x = originX;
    int y = originY;

    while (true) {
      x += walkDirX;
      y += walkDirY;

      if(!isOnMap(width, height, x, y))
        return 0;

      var field = map.get(y).get(x);
      if (field == OCCUPIED)
        return 1;
      if (field == EMPTY)
        return 0;
    }
  }

  static boolean isOnMap(int width, int height, int x, int y) {
    return 0 <= x && x < width && 0 <= y && y < height;
  }

  static String toStringMap(List<List<Character>> inputMap) {
    var mapWidth = inputMap.get(0).size();
    var mapHeight = inputMap.size();

    var sb = new StringBuilder();
    for (int y = 0; y < mapHeight; ++y) {
      for (int x = 0; x < mapWidth; ++x) {
        sb.append(inputMap.get(y).get(x));
      }
      sb.append('\n');
    }
    return sb.toString();
  }
}
