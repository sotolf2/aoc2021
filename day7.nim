import strutils, sequtils, math

proc getData(filename: string): seq[int] =
  readFile(filename).strip().split(',').map(parseInt)

proc calculateFuel(positions: seq[int], goal: int): int =
  for crab in positions:
    result += abs(crab - goal)
  
proc calculateFuel2(positions: seq[int], goal: int): int =
  for crab in positions:
    for i in 1..abs(crab - goal):
      result += i

proc part1(data: seq[int]): int =
  let mini = min(data)
  let maxi = max(data)
  result = high(int)
  for i in mini..maxi:
    result = min(calculateFuel(data, i), result)

proc part2(data: seq[int]): int =
  let mini = min(data)
  let maxi = max(data)
  result = high(int)
  for i in mini..maxi:
    result = min(calculateFuel2(data, i), result)
  

let data = getData("day7.txt")
echo "Part 1: ", part1(data)
echo "Part 2: ", part2(data)
