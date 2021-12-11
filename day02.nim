import strutils

type Direction = enum
  Forward,
  Down,
  Up

type Instruction = tuple
  direction: Direction
  amount: int

proc parseDirection(str: string): Direction =
  case str:
    of "forward": return Forward
    of "down": return Down
    of "up": return Up

proc parseLine(line: string): Instruction =
  let parts = line.split()
  result.direction = parseDirection(parts[0])
  result.amount = parts[1].parseInt()

proc getData(filename: string): seq[Instruction] =
  let str = readFile(filename).strip().splitLines()
  for line in str:
    result.add(parseLine(line))

proc part1(data: seq[Instruction]): int =
  var horizontal = 0
  var depth = 0
  
  for instruction in data:
    case instruction.direction:
      of Forward:
        horizontal += instruction.amount
      of Down:
        depth += instruction.amount
      of Up:
        depth -= instruction.amount

  result = horizontal * depth

proc part2(data: seq[Instruction]): int =
  var aim = 0
  var horizontal = 0
  var depth = 0

  for instruction in data:
    case instruction.direction:
      of Down:
        aim += instruction.amount
      of Up:
        aim -= instruction.amount
      of Forward:
        horizontal += instruction.amount
        depth += instruction.amount * aim

  result = horizontal * depth

let instructions = getData("day2.txt")
echo "part1: ", part1(instructions)
echo "part2: ", part2(instructions)
