import 
  strutils,
  sets,
  sugar

type 
  Point = tuple
    row, col: int
  
  Grid = HashSet[Point]

  Direction = enum
    Up,
    Left
  
  Instruction = tuple
    dir: Direction
    line: int

proc parsePoint(data: string): Point =
  let tkns = data.split(',')
  result.row = tkns[1].parseInt()
  result.col = tkns[0].parseInt()

proc parseInstruction(data: string): Instruction =
  let tkns = data.split()[2].split('=')
  case tkns[0]:
    of "y": result.dir = Up
    of "x": result.dir = Left
    else: echo "Invalid direction when Parsing instruction: ", tkns[0]
  result.line = tkns[1].parseInt()


proc parseFile(data: string): (Grid, seq[Instruction]) =
  var 
    grid: Grid
    instructions: seq[Instruction]
    parsingPoints = true
  
  for line in data.strip.splitLines:
    if line == "":
      parsingPoints = false
      continue
    if parsingPoints:
      grid.incl(line.parsePoint())
    else:
      instructions.add(line.parseInstruction())

  (grid, instructions)

proc foldUp(grid: Grid, line: int): Grid =
  for point in grid:
    if point.row > line:
      let row = line - (point.row - line)
      result.incl((row, point.col))
    else:
      result.incl(point)

proc foldLeft(grid: Grid, line: int): Grid =
  for point in grid:
    if point.col > line:
      let col = line - (point.col - line)
      result.incl((point.row, col))
    else:
      result.incl(point)

proc part1(grid: Grid, instruction: Instruction): int =
  case instruction.dir:
    of Up: grid.foldUp(instruction.line).len()
    of Left: grid.foldLeft(instruction.line).len()

proc part2(grid: Grid, instructions: seq[Instruction]): Grid =
  result = grid
  for instruction in instructions:
    case instruction.dir:
      of Up: result = result.foldUp(instruction.line)
      of Left: result = result.foldLeft(instruction.line)

proc findMaxRow(self: Grid): int =
  let rows = 
    collect(newSeq):
      for point in self:
        point.row
  max(rows)

proc findMaxCol(self: Grid): int =
  let cols =
    collect(newSeq):
      for point in self:
        point.col
  max(cols)

proc `$`(self: Grid): string =
  var 
    maxRow = self.findMaxRow()
    maxCol = self.findMaxCol()
  result &= "\n"
  for row in 0..maxRow:
    var line = ""
    for col in 0..maxCol:
      if (row,col) in self:
        line &= "#"
      else:
        line &= " "
    result &= line
    result &= "\n"


let (grid, instructions) = parseFile(readFile("day13.txt"))
echo "Part1: ", part1(grid, instructions[0])
echo "Part2: ", part2(grid, instructions)
