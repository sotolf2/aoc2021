import strutils, options, sugar

type Point = tuple
  row: int
  col: int

type Bounds = tuple
  low: int
  high: int

proc parseToken(tokens: seq[string], idx: int): Bounds =
  let token = tokens[idx].split("..")
  (
    token[0].split("=")[1].parseInt(),
    token[1].split(",")[0].parseInt()
  )

proc parseFile(filename: string): (Bounds, Bounds) =
  let tkns = readFile(filename).strip().split()
  (tkns.parseToken(2), tkns.parseToken(3))

proc `+=`(self: var Point, other: Point) =
  self.row += other.row
  self.col += other.col

proc step(pos: var Point, vel: var Point) =
  pos += vel
  if vel.col > 0:
    vel.col -= 1
  vel.row -= 1

proc within(pos: Point, brow, bcol: Bounds): bool =
  if pos.row >= brow.low and pos.row <= brow.high:
    if pos.col >= bcol.low and pos.col <= bcol.high:
      result = true

proc steps(initvel: Point, brow, bcol: Bounds): Option[int] =
  var highestPoint = 0
  var vel = initvel
  var pos: Point = (0,0)
  while pos.row >= brow.low:
    step(pos, vel)
    if pos.row > highestPoint:
      highestPoint = pos.row
    if pos.within(brow, bcol):
      return some(highestPoint)
  return none[int]()
      

proc part1(brow, bcol: Bounds): int =
  for coli in 0..bcol.high:
    for rowi in 0..bcol.high:
      let highHit = steps((rowi, coli), brow, bcol)
      if highHit.isSome:
        result = max(result, highHit.get)

proc part2(brow, bcol: Bounds): int =
  for coli in 0..bcol.high:
    for rowi in brow.low..bcol.high:
      let highHit = steps((rowi, coli), brow, bcol)
      if highHit.isSome:
        result += 1


let (bcol, brow) = parseFile("day17.txt")
echo "Part1: ", part1(brow, bcol)
echo "Part2: ", part2(brow, bcol)
