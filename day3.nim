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

proc findClosestMatch(needle: string, stack: seq[string]): uint =
  var prefix = needle
  while prefix != "":
    let matches = stack.filterIt(it.startsWith(prefix))
    if matches.len() == 1:
      return fromBin[uint](matches[0])
    let last = prefix.len()-1
    prefix.delete(last..last)
  

proc part1(data: seq[string]): uint =
  let gamma = calculateGamma(data)
  let epsilon = flip(gamma)
  fromBin[uint](gamma) * fromBin[uint](epsilon)


let data = readFile("day3t.txt").strip().splitLines()
echo "Part1: ", part1(data)
echo findClosestMatch("test", data)
