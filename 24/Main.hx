// Run:
//     haxe --main Main --interp < input.txt
// Compiler/Runtime version:
//     haxe --version
//     4.1.4

using Lambda;
using StringTools;
using haxe.ds.HashMap;

class Position {
  public var x:Int;
  public var y:Int;

  public function new(x:Int, y:Int) {
    this.x = x;
    this.y = y;
  }

  // For some reason, it seems that a HashMap only takes the hashCode into account (no "equals" here).
  public function hashCode():Int { return x + (y * 1000); }
  public function toString() { return '($x, $y)'; }
  static public function add(a:Position, b:Position): Position {
    return new Position(a.x + b.x, a.y + b.y);
  }
}

class Main {
  static public function main():Void {
    var content = Sys.stdin().readAll().toString();
    var lines = content.trim().split("\n");

    var origin:Position = new Position(0, 0);

    // Paths basically represent a list of vectors that can be added.
    // The resulting value is the coordinate of the tile described by the path.
    // A tile that can be reached via different paths will result in the same final coordinate for each path.

    // What we do:
    // - The edges of a tile are 0.5 away from the center.
    // - This means that the distance between the centers of a pair of tiles is always 1.0
    // - Walking on a path takes us from center to center
    // - We multiply all this by 100 so we can work with integer values (and avoid floating point arithmetic)
    // - Walking N* or S* always takes aus -75 or 75 in the Y direction due to the notion of triangles (see directionToVector)

    var paths = lines.map(function(line) return parseLine(line).map(directionToVectorMap.get));
    var tiles = paths.map(function(path) return path.fold(Position.add, origin));

    // Haxe doesn't have a set in their stdlib (only as a package)
    // We use a HashMap<Position, Bool> to simulate that
    var tileMap = new HashMap<Position, Bool>();
    for (flippedTile in tiles) {
      if (tileMap.exists(flippedTile)) {
        tileMap.remove(flippedTile);
      } else {
        tileMap.set(flippedTile, true);
      }
    }

    var part1 = countBlackTiles(tileMap);
    Sys.println('Number of black tiles after applying flip operations; Part 1: $part1');

    var iteratedTileMap = tileMap;
    for (iteration in 0...100) {
      iteratedTileMap = doTileIterationPart2(iteratedTileMap);
    }

    var part2 = countBlackTiles(iteratedTileMap);
    Sys.println('Number of black tiles after 100 days of the living art exhibit; Part 2: $part2');
  }

  static function parseLine(line:String):List<String> {
    var path = new List<String>();

    var currentPrefix:String = null;

    for (charCode in line) {
      var char = String.fromCharCode(charCode);

      if (currentPrefix != null) {
        path.add(currentPrefix + char);
        currentPrefix = null;
      } else {
        switch (char) {
          case 'n': currentPrefix = char;
          case 'e': path.add(char);
          case 's': currentPrefix = char;
          case 'w': path.add(char);
          default: throw "Unhandled direction: " + char;
        }
      }
    }
    return path;
  }

  static var directionToVectorMap = [
    'ne' => new Position(50, -75),
    'e' => new Position(100, 0),
    'se' => new Position(50, 75),
    'sw' => new Position(-50, 75),
    'w' => new Position(-100, 0),
    'nw' => new Position(-50, -75),
  ];

  static function countBlackTiles(tileMap:HashMap<Position, Bool>):Int {
    // Lambda.count doens't work on HashMaps, so we count this manually

    var counter = 0;
    for (tile in tileMap.keys()) {
      ++counter;
    }
    return counter;
  }

  static function doTileIterationPart2(tileMap:HashMap<Position, Bool>) {
    var nextTiles = new HashMap<Position, Bool>();

    var stats = getMinMaxValuesOfHashMap(tileMap);

    // As our field is infinite, we just take a portion that is large enough to fit all our data

    var startX = stats.min.x - 100;
    var startY = stats.min.y - 150;
    var endX = stats.max.x + 1 + 100;
    var endY = stats.max.y + 1 + 100;

    // We need extra code for a stepped iterator: https://code.haxe.org/category/data-structures/step-iterator.html
    var x = startX;
    while (x < endX) {
      var y = startY;
      while (y < endY) {

        var pos = new Position(x, y);
        var adjacentBlackTiles = countAdjacentBlackTiles(tileMap, pos);

        if (tileMap.exists(pos)) {
          // Tile is black
          if (adjacentBlackTiles == 0 || adjacentBlackTiles > 2) {
            // This tile becomes white, do not set it on the result
          } else {
            nextTiles.set(pos, true);
          }
        } else {
          // Tile is white

          if (adjacentBlackTiles == 2) {
            // This tile becomes black
            nextTiles.set(pos, true);
          } else {
            // This tile remains white, do not set it on the result
          }
        }

        y += 75;
      }
      x += 50;
    }

    return nextTiles;
  }

  static function countAdjacentBlackTiles(tileMap:HashMap<Position, Bool>, tile:Position) {
    var blackTiles = 0;
    for (dir => offset in directionToVectorMap) {
      var otherTile = Position.add(tile, offset);
      if (tileMap.exists(otherTile)) {
        ++blackTiles;
      }
    }
    return blackTiles;
  }

  static function getMinMaxValuesOfHashMap(map:HashMap<Position, Bool>) {
    // Again, Lambda.fold doesn't work on HashMap<K, V>.keys()
    var minX: Int = 0;
    var minY: Int = 0;
    var maxX: Int = 0;
    var maxY: Int = 0;

    for (tilePosition in map.keys()) {
      maxX = cast(Math.max(tilePosition.x, maxX), Int);
      maxY = cast(Math.max(tilePosition.y, maxY), Int);
      minX = cast(Math.min(tilePosition.x, minX), Int);
      minY = cast(Math.min(tilePosition.y, minY), Int);
    }
    return { min: { x: minX, y: minY }, max: { x: maxX, y: maxY } };
  }
}
