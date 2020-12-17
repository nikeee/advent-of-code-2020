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
    ActiveCube3D = tuple[x: int16, y: int16, z: int16]

proc initSpace1D(): Space1D = {}
proc initSpace2D(): Space2D = initTable[int16, Space1D]()
proc initSpace3D(): Space3D = initTable[int16, Space2D]()

func `[]`(self: var Space2D, key: int16): var set[int16] = self.mgetOrPut(key, initSpace1D())
func `[]`(self: var Space3D, key: int16): var Space2D = self.mgetOrPut(key, initSpace2D())


proc get_entry(space: var Space3D, x: int16, y: int16, z: int16): bool =
    return z in space[x][y]


proc set_entry(space: var Space3D, x: int16, y: int16, z: int16, value: bool): void =
    if value:
        space[x][y] = space[x][y] + {z}
    else:
        space[x][y] = space[x][y] - {z}


func get_active(space: var Space3D): seq[ActiveCube3D] =
    var active_cubes = newSeq[ActiveCube3D]()
    for x, yzs in space:
        for y, zs in yzs:
            for z in zs:
                active_cubes.add((x: x, y: y, z: z))
    active_cubes


func get_neighbors(space: var Space3D, origin_x: int16, origin_y: int16, origin_z: int16): seq[ActiveCube3D] =
    var neighbors = newSeq[ActiveCube3D]()
    for x in (origin_x - 1)..(origin_x + 1):
        for y in (origin_y - 1)..(origin_y + 1):
            for z in (origin_z - 1)..(origin_z + 1):
                if x == origin_x and y == origin_y and z == origin_z:
                    continue

                let is_active = get_entry(space, x, y, z)
                if is_active:
                    neighbors.add((x: x, y: y, z: z))

    neighbors

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
                if current:
                    let new_value = len(neighbors) in 2..3
                    set_entry(next_space, x, y, z, new_value)
                else:
                    let new_value = len(neighbors) == 3
                    set_entry(next_space, x, y, z, new_value)
    next_space

var current_space: Space3D = initSpace3D()

for y, line in lines:
    for x, c in line:
        if c == '#':
            set_entry(current_space, cast[int16](x), cast[int16](y), 0, true)

let iterations = 6
for i in 1..iterations:
    current_space = iterate(current_space)
    echo "Iteration ", i, "/", iterations, " done"

echo "Number of active cubes; Part 1: ", len(get_active(current_space))
