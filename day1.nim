import strutils

proc getData(filename: string): seq[int] =
  let file = open(filename)
  var line: string
  while file.readLine(line):
    if line.len > 1:
      result.add(line.parseInt())

proc findIncreasing(data: seq[int]): int =
  for i in 1..<data.len():
    if data[i-1] < data[i]:
      result += 1

proc findIncreasingWindow(data: seq[int]): int =
  var last = data[0] + data[1] + data[2]
  for i in 3..<data.len():
    let cur = data[i-2] + data[i-1] + data[i]
    if cur > last:
      result += 1
    last = cur

let data = getData("day1.txt")
echo "part1: " & $findIncreasing(data)
echo "part2: " & $findIncreasingWindow(data)
