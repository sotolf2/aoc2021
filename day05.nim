import strutils, tables, math, sugar

type Point = tuple
  x: int
  y: int

type Line = object
  frm: Point
  to: Point

proc isOrthogonal(self: Line): bool =
  self.frm.x == self.to.x or self.frm.y == self.to.y

proc `+`(self: Point, other: Point): Point =
  result.x = self.x + other.x
  result.y = self.y + other.y

proc `+=`(self: var Point, other: Point) =
  self = self + other

proc getReducedForm(dy, dx: int): Point = 
  if dy == 0:
      return(dy, 1)
  if dx == 0:
      return (1, dx)
  
  let gradient = gcd(abs(dy), abs(dx))
  let isNegative = (dy < 0) xor (dx < 0)
  
  if isNegative:
    (abs(dx) div gradient, -abs(dy) div gradient)
  else:
    (abs(dx) div gradient, abs(dy) div gradient)



proc coordsCovered(self: Line): seq[Point] =
  var curPoint = min(self.frm, self.to)
  var endPoint = max(self.frm, self.to)
  let rise = endPoint.y - curPoint.y
  let run = endPoint.x - curPoint.x
  let delta = getReducedForm(run, rise)
  while curPoint <= endPoint:
    result.add(curPoint)
    curPoint += delta

proc parsePoint(data: string): Point =
  let tkns  = data.split(",")
  result.x = tkns[0].parseInt
  result.y = tkns[1].parseInt

proc parseLine(data: string): Line =
  let pnts = data.split(" -> ")
  result.frm = parsePoint(pnts[0])
  result.to = parsePoint(pnts[1])

proc parseData(data: seq[string]): seq[Line] =
  for line in data:
    result.add(parseLine(line))

proc part1(lines: seq[Line]): int =
  var cover = initCountTable[Point]()
  for line in lines:
    if line.isOrthogonal:
      for point in coordsCovered(line):
        cover.inc(point)
  
  for value in cover.values:
    if value >= 2:
      result += 1

proc part2(lines: seq[Line]): int =
  var cover = initCountTable[Point]()
  for line in lines:
    for point in coordsCovered(line):
      cover.inc(point)
  
  for value in cover.values:
    if value >= 2:
      result += 1

let lines = parseData(readFile("day5.txt").strip().splitLines)
echo "Part1: ", part1(lines)
echo "Part2: ", part2(lines)

