import
  strutils,
  sets,
  algorithm

proc parseLine(ln: string): seq[int] =
  for ch in ln:
    result.add(parseInt($ch))

proc parseData(data: string): seq[seq[int]] =
  for line in data.strip().splitLines():
    result.add(parseLine(line))

proc isLowpoint(data: seq[seq[int]], row, col: int): bool =
  let point = data[row][col]
  if row - 1 >= 0:
    if point >= data[row-1][col]:
      return false
  if col - 1 >= 0:
    if point >= data[row][col-1]:
      return false
  if row + 1 <= data.high:
    if point >= data[row+1][col]:
      return false
  if col + 1 <= data[row].high:
    if point >= data[row][col+1]:
      return false

  return true

proc fillBasinSub(data: seq[seq[int]], row, col: int, seen: HashSet[(int, int)]): HashSet[(int,int)] =
  result = initHashSet[(int, int)]()
  if data[row][col] == 9:
    return result
  result.incl((row, col))
  if row - 1 >= 0 and (row - 1, col) notin seen:
    result = result + fillbasinSub(data, row - 1, col, seen + result)
  if col - 1 >= 0 and (row, col - 1) notin seen:
    result = result + fillbasinSub(data, row, col - 1, seen + result)
  if row + 1 <= data.high and (row+1, col) notin seen:
    result = result + fillbasinSub(data, row + 1, col, seen + result)
  if col + 1 <= data[row].high and (row, col+1) notin seen:
    result = result + fillbasinSub(data, row, col+1, seen + result)

proc fillBasin(data: seq[seq[int]], row, col: int): HashSet[(int, int)] =
  fillBasinSub(data, row, col, initHashSet[(int, int)]())

proc part1(data: seq[seq[int]]): int =
  for row in 0..<len(data):
    for col in 0..<len(data[row]):
      if isLowpoint(data, row, col):
        result += (data[row][col] + 1)

proc part2(data: seq[seq[int]]): int =
  var seen = initHashSet[(int, int)]()
  var basins: seq[int]
  for row in 0..<len(data):
    for col in 0..<len(data[row]):
      if (row, col) notin seen:
        let basin = fillBasin(data, row, col)
        if basin.len() == 0:
          seen.incl((row, col))
        else:
          seen = seen + basin
          basins.add(basin.len)
  basins.sort()
  basins.reverse()
  result = basins[0] * basins[1] * basins[2]

let data = parseData(readFile("day9.txt"))
echo "Part1: ", part1(data)
echo "Part2: ", part2(data)
