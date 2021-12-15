import strutils, sequtils, sugar, heapqueue, tables, algorithm

type
  Grid = seq[seq[int]]
  Point = tuple
    row: int
    col: int
  Path = seq[Point]

proc parseFile(filename: string): Grid =
  let lines = filename.readFile().strip().splitlines()
  collect(newSeq):
    for line in lines:
      collect(newSeq):
        for ch in line:
          parseInt($ch)

proc `$`(self: Grid): string =
  result = "\n"
  for rowi in 0..self.high:
    var line = ""
    for coli in 0..self[rowi].high:
      line &= $self[rowi][coli]
    result &= line
    result &= "\n"

proc findBottomRight(self: Grid): Point =
  (
    len(self) - 1,
    len(self[self.high]) - 1
  )

proc `[]`(self: Grid, point: Point): int =
  self[point.row][point.col]

proc `+`(self: Point, other: Point): Point =
  (
    self.row + other.row,
    self.col + other.col,
  )

proc includes(self: Grid, point:Point): bool =
  if point.row < 0 or point.col < 0:
    false
  else:
    let comparison = self.findBottomRight()
    if point.row > comparison.row or point.col > comparison.col:
      false
    else:
      true

proc getNeighbours(grid: Grid, point: Point): seq[Point] =
  var candidates = @[
    point + (-1,  0), # up
    point + ( 1,  0), # down
    point + ( 0, -1), #left
    point + ( 0,  1), #right
  ]
  result = candidates.filterIt(grid.includes(it))

proc manhattan(self: Point, other: Point): int =
  abs(other.row - self.row) + abs(other.col - self.col)

proc buildPath(cameFrom: Table[Point, Point], start, goal: Point): Path =
  result.add(goal)
  var current = goal
  while current != start:
    current = cameFrom[current]
    result.add(current)
  result.sort()

proc aStar(grid: Grid, start: Point, goal: Point): (Path, int) =
  # Getting path with aStar and manhattan distance as a heuristic
  var 
    frontier = initHeapqueue[(int, Point)]()
    cameFrom: Table[Point, Point]
    costSoFar: Table[Point, int]

  frontier.push((0, start))
  costSoFar[start] = 0

  while len(frontier) > 0:
    let (_, current) = frontier.pop()

    if current == goal:
      return (cameFrom.buildPath(start, goal), costSoFar[goal])

    for next in grid.getNeighbours(current):
      let newCost = costSoFar[current] + grid[next]
      if next not_in costSoFar or newCost < costSoFar[next]:
        costSoFar[next] = newCost
        let priority = newCost + next.manhattan(goal)
        frontier.push((priority, next))
        cameFrom[next] = current

proc next(self: Grid): Grid =
  for rowi in 0..self.high:
    var row: seq[int] = @[]
    for coli in 0..self[rowi].high:
      let newVal = self[rowi][coli] + 1
      if newVal > 9:
        row.add(1)
      else:
        row.add(newVal)
    result.add(row)

proc `&=`(self: var Grid, other: Grid) =
  for rowi in 0..self.high:
    self[rowi] &= other[rowi]

proc add(self: var Grid, other: Grid) =
  for row in other:
    self.add(row)

proc stitchGrid(subGrid: Table[int, Grid], tmplt: Grid): Grid =
  for rowi in 0..tmplt.high:
    var row = subGrid[tmplt[rowi][0]]
    for coli in 1..tmplt[rowi].high:
      row &= subGrid[tmplt[rowi][coli]]
    result.add(row)

proc expand(self: Grid): Grid =
  var subGrid: Table[int, Grid]
  subGrid[0] = self
  for i in 1..8:
    subGrid[i] = subGrid[i-1].next()
  let tmplt =
    @[
      @[0, 1, 2, 3, 4],
      @[1, 2, 3, 4, 5],
      @[2, 3, 4, 5, 6],
      @[3, 4, 5, 6, 7],
      @[4, 5, 6, 7, 8]
    ]
  stitchGrid(subGrid, tmplt)

proc part1(data: Grid): int =
  let topLeft = (0, 0)
  let bottomRight = data.findBottomRight()
  var path: Path
  (path, result) = data.aStar(topLeft, bottomRight)

proc part2(data: Grid): int =
  let grid = data.expand()
  let topLeft = (0, 0)
  let bottomRight = grid.findBottomRight()
  var path: Path
  (path, result) = grid.aStar(topLeft, bottomRight)

let data = parseFile("day15.txt")
echo "Part1: ", part1(data)
echo "Part2: ", part2(data)
