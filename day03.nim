import strutils, sequtils

proc calculateGamma(data: seq[string]): string =
  let numChars = data[0].len()

  for place in 0..<numChars:
    var zeroes, ones: int
    for line in 0..<len(data):
      case data[line][place]
        of '1': ones += 1
        of '0': zeroes += 1
        else: echo "non binary number in string"
    if ones > zeroes:
      result &= "1"
    else:
      result &= "0"


proc flip(num: string): string =
  for ch in num:
    case ch
      of '1': result &= "0"
      of '0': result &= "1"
      else: echo "non binary number in string"

proc findOxygenRating(data: seq[string]): uint =
  var curPlace = 0
  var candidates = data

  while len(candidates) > 1:
    var zeroes, ones: int
    for line in 0..<len(candidates):
      case candidates[line][curplace]
        of '1': ones += 1
        of '0': zeroes += 1
        else: echo "non binary number in string"
    var test: char
    if ones >= zeroes:
      test = '1'
    else:
      test = '0'

    candidates = candidates.filterIt(it[curPlace] == test)
    curPlace += 1

  return fromBin[uint](candidates[0])
      

proc findCo2Rating(data: seq[string]): uint =
  var curPlace = 0
  var candidates = data

  while len(candidates) > 1:
    var zeroes, ones: int
    for line in 0..<len(candidates):
      case candidates[line][curplace]
        of '1': ones += 1
        of '0': zeroes += 1
        else: echo "non binary number in string"
    var test: char
    if zeroes <= ones:
      test = '0'
    else:
      test = '1'

    candidates = candidates.filterIt(it[curPlace] == test)
    curPlace += 1

  return fromBin[uint](candidates[0])


proc part1(data: seq[string]): uint =
  let gamma = calculateGamma(data)
  let epsilon = flip(gamma)
  fromBin[uint](gamma) * fromBin[uint](epsilon)

proc part2(data: seq[string]): uint =
  let oxygen = findOxygenRating(data)
  let co2 = findCo2Rating(data)
  result = oxygen * co2

let data = readFile("day3.txt").strip().splitLines()
echo "Part1: ", part1(data)
echo "Part2: ", part2(data)
