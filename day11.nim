import
  strutils,
  sugar,
  deques

type Grid = seq[seq[int]]
type Point = tuple
  row: int
  col: int

func `+`(self, other: Point): Point =
  (self.row + other.row,
   self.col + other.col)

func inGrid(self: Point, grid: Grid): bool =
  if self.row < 0 or self.col < 0:
    return false
  if self.row > grid.high:
    return false
  if self.col > grid[0].high:
    return false
  return true

proc setAt(grid: var Grid, point: Point, val: int) =
  grid[point.row][point.col] = val

func getAt(grid: Grid, point: Point): int =
  grid[point.row][point.col]

func parseLine(line: string): seq[int] = 
  for ch in line:
    result.add(parseInt($ch))

func parse(data: string): Grid =
  for line in data.strip.splitlines:
    result.add(line.parseLine)

proc echoGrid(board: Grid) =
  for row in board:
    echo row.join

proc inc(grid: Grid): (Grid, Deque[Point]) =
  var 
    nuGrid = grid
    toFlash = initDeque[Point]()
  for (row, cols) in grid.pairs:
    for (col, squid) in cols.pairs:
      nuGrid[row][col] = squid + 1
      if squid + 1 == 10:
        toFlash.addLast((row,col))
  (nuGrid, toFlash)

proc getNeighbourCoords(frm: Point): seq[Point] =
  var deltas = [(-1, -1), (-1, 0), (-1, 1),
                ( 0, -1),          ( 0, 1),
                ( 1, -1), ( 1, 0), ( 1, 1)]
  for delta in deltas:
    result.add(frm + delta)


proc flash(self: Grid, inToFlash: Deque[Point]): (Grid, int) =
  var 
    grid = self
    flashes = 0
    toFlash = inToFlash
  
  while toFlash.len > 0:
    let cur = toFlash.popFirst()
    flashes += 1
    grid.setAt(cur, 0)
    let neighbours = cur.getNeighbourCoords()
    for neighbour in neighbours:
      if neighbour.inGrid(grid):
        let nu = grid.getAt(neighbour) + 1
        if nu == 1:
          continue
        grid.setAt(neighbour, nu)
        if nu == 10:
          toFlash.addLast(neighbour)
  (grid, flashes)

proc step(self: Grid): (Grid, int) =
  var 
    toFlash: Deque[Point]
    grid = self
  (grid, toFlash) = grid.inc()
  result = grid.flash(toFlash)

proc part1(inGrid: Grid): int =
  var 
    grid = inGrid
    nuFlashes: int
  for i in 1..100:
    (grid, nuFlashes) = grid.step()
    result += nuFlashes

proc part2(inGrid: Grid): int =
  let squidCount = inGrid.len * inGrid[0].len
  var 
    grid = inGrid
    flashes: int
  while flashes != squidCount:
    (grid, flashes) = grid.step
    result += 1


let data = parse(readFile("day11.txt"))
echo "Part1: ", part1(data)
echo "Part2: ", part2(data)
