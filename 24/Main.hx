// Run:
//     haxe --main Main --interp < input.txt
// Compiler/Runtime version:
//     haxe --version
//     4.1.4

using Lambda;
using StringTools;

class Position {
  public var x:Int;
  public var y:Int;

  public function new(x:Int, y:Int) {
    this.x = x;
    this.y = y;
  }

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

    var paths = lines.map(function(line) return parseLine(line).map(directionToVector));
    var tiles = paths.map(function(path) return path.fold(Position.add, origin));

    // Haxe doesn't have a set in their stdlib (only as a package)
    // We use a HashMap<Position, Bool> to simulate that
    var tileMap = new haxe.ds.HashMap<Position, Bool>();
    for (flippedTile in tiles) {
      if (tileMap.exists(flippedTile)) {
        tileMap.remove(flippedTile);
      } else {
        tileMap.set(flippedTile, true);
      }
    }

    var part1 = countBlackTiles(tileMap);
    Sys.println('Number of black tiles after applying flip operations; Part 1: $part1');
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

  static function directionToVector(direction:String):Position {
    switch (direction) {
      case 'ne': return new Position(50, -75);
      case 'e': return new Position(100, 0);
      case 'se': return new Position(50, 75);
      case 'sw': return new Position(-50, 75);
      case 'w': return new Position(-100, 0);
      case 'nw': return new Position(-50, -75);
      default: throw "Unhandled direction: " + direction;
    }
  }
  static function countBlackTiles(tileMap:haxe.ds.HashMap<Position, Bool>):Int {
    // Lambda.count doens't work on HashMaps, so we count this manually

    var counter = 0;
    for (tile in tileMap.keys()) {
      ++counter;
    }
    return counter;
  }
}
