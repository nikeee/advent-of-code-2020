# Compile:
#     nim c -d:release main.nim
# Use:
#     ./main < input.txt
# Compiler version:
#     nim --version
#     Nim Compiler Version 1.4.2 [Linux: amd64]

import tables
import sequtils, sugar

var lines = newSeq[string]()
for line in stdin.lines:
    lines.add(line)

type
    Space1D = set[int16]
    Space2D = Table[int16, Space1D]
    Space3D = Table[int16, Space2D]
    Space4D = Table[int16, Space3D]
    ActiveCube3D = tuple[x: int16, y: int16, z: int16]
    ActiveCube4D = tuple[x: int16, y: int16, z: int16, w: int16]

proc initSpace1D(): Space1D = {}
proc initSpace2D(): Space2D = initTable[int16, Space1D]()
proc initSpace3D(): Space3D = initTable[int16, Space2D]()
proc initSpace4D(): Space4D = initTable[int16, Space3D]()


func `[]`(self: var Space2D, key: int16): var set[int16] = self.mgetOrPut(key, initSpace1D())
func `[]`(self: var Space3D, key: int16): var Space2D = self.mgetOrPut(key, initSpace2D())
func `[]`(self: var Space4D, key: int16): var Space3D = self.mgetOrPut(key, initSpace3D())


proc get_entry(space: var Space3D, x: int16, y: int16, z: int16): bool =
    return z in space[x][y]

proc get_entry(space: var Space4D, x: int16, y: int16, z: int16, w: int16): bool =
    return w in space[x][y][z]


proc set_entry(space: var Space3D, x: int16, y: int16, z: int16, value: bool): void =
    if value:
        space[x][y] = space[x][y] + {z}
    else:
        space[x][y] = space[x][y] - {z}

proc set_entry(space: var Space4D, x: int16, y: int16, z: int16, w: int16, value: bool): void =
    if value:
        space[x][y][z] = space[x][y][z] + {w}
    else:
        space[x][y][z] = space[x][y][z] - {w}


func get_active(space: var Space3D): seq[ActiveCube3D] =
    var active_cubes = newSeq[ActiveCube3D]()
    for x, yzs in space:
        for y, zs in yzs:
            for z in zs:
                active_cubes.add((x: x, y: y, z: z))
    active_cubes

func get_active(space: var Space4D): seq[ActiveCube4D] =
    var active_cubes = newSeq[ActiveCube4D]()
    for x, yzws in space:
        for y, zws in yzws:
            for z, ws in zws:
                for w in ws:
                    active_cubes.add((x: x, y: y, z: z, w: w))
    active_cubes


func get_neighbors(space: var Space3D, origin_x: int16, origin_y: int16, origin_z: int16): int =
    var neighbors = 0
    for x in (origin_x - 1)..(origin_x + 1):
        for y in (origin_y - 1)..(origin_y + 1):
            for z in (origin_z - 1)..(origin_z + 1):
                if x == origin_x and y == origin_y and z == origin_z:
                    continue

                if get_entry(space, x, y, z):
                    neighbors += 1

    neighbors

func get_neighbors(space: var Space4D, origin_x: int16, origin_y: int16, origin_z: int16, origin_w: int16): int =
    var neighbors = 0
    for x in (origin_x - 1)..(origin_x + 1):
        for y in (origin_y - 1)..(origin_y + 1):
            for z in (origin_z - 1)..(origin_z + 1):
                for w in (origin_w - 1)..(origin_w + 1):
                    if x == origin_x and y == origin_y and z == origin_z and w == origin_w:
                        continue

                    if get_entry(space, x, y, z, w):
                        neighbors += 1

    neighbors


func get_new_state(current: bool, neighbors: int): bool =
    if current:
        return neighbors in 2..3
    return neighbors == 3


func iterate(space: var Space3D): Space3D =
    var next_space = space

    let active_cubes = get_active(space)

    let min_x = min(active_cubes.map(c => c.x))
    let max_x = max(active_cubes.map(c => c.x))
    let min_y = min(active_cubes.map(c => c.y))
    let max_y = max(active_cubes.map(c => c.y))
    let min_z = min(active_cubes.map(c => c.z))
    let max_z = max(active_cubes.map(c => c.z))

    for x in (min_x - 1) .. (max_x + 1):
        for y in (min_y - 1) .. (max_y + 1):
            for z in (min_z - 1) .. (max_z + 1):
                let current = get_entry(space, x, y, z)
                let neighbors = get_neighbors(space, x, y, z)
                let new_value = get_new_state(current, neighbors)
                set_entry(next_space, x, y, z, new_value)
    next_space


func iterate(space: var Space4D): Space4D =
    var next_space = space

    let active_cubes = get_active(space)

    let min_x = min(active_cubes.map(c => c.x))
    let max_x = max(active_cubes.map(c => c.x))
    let min_y = min(active_cubes.map(c => c.y))
    let max_y = max(active_cubes.map(c => c.y))
    let min_z = min(active_cubes.map(c => c.z))
    let max_z = max(active_cubes.map(c => c.z))
    let min_w = min(active_cubes.map(c => c.w))
    let max_w = max(active_cubes.map(c => c.w))

    for x in (min_x - 1) .. (max_x + 1):
        for y in (min_y - 1) .. (max_y + 1):
            for z in (min_z - 1) .. (max_z + 1):
                for w in (min_w - 1) .. (max_w + 1):
                    let current = get_entry(space, x, y, z, w)
                    let neighbors = get_neighbors(space, x, y, z, w)
                    let new_value = get_new_state(current, neighbors)
                    set_entry(next_space, x, y, z, w, new_value)
    next_space


var current_space_part1 = initSpace3D()
var current_space_part2 = initSpace4D()

for y, line in lines:
    for x, c in line:
        if c == '#':
            set_entry(current_space_part1, cast[int16](x), cast[int16](y), 0, true)
            set_entry(current_space_part2, cast[int16](x), cast[int16](y), 0, 0, true)

let iterations = 6
for i in 1..iterations:
    current_space_part1 = iterate(current_space_part1)
    echo "Part 1 iteration ", i, "/", iterations, " done"

    current_space_part2 = iterate(current_space_part2)
    echo "Part 2 iteration ", i, "/", iterations, " done"

echo "Number of active cubes (in 3D); Part 1: ", len(get_active(current_space_part1))
echo "Number of active cubes (in 4D); Part 2: ", len(get_active(current_space_part2))
