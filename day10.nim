import
  strutils,
  algorithm,
  deques,
  options

type Bracket = enum
  Round,
  Square,
  Squiggly,
  Sharp

proc errorCheck(line: string): (Option[Bracket], Deque[Bracket]) =
  var bracketStack = initDeque[Bracket]()
  for ch in line:
    case ch:
      of '(':
        bracketStack.addFirst(Round)
      of '[':
        bracketStack.addFirst(Square)
      of '{':
        bracketStack.addFirst(Squiggly)
      of '<':
        bracketStack.addFirst(Sharp)
      of ')':
        let cur = bracketStack.popFirst
        if cur != Round:
          return (some(Round), bracketStack)
      of ']':
        let cur = bracketStack.popFirst
        if cur != Square:
          return (some(Square), bracketStack)
      of '}':
        let cur = bracketStack.popFirst
        if cur != Squiggly:
          return (some(Squiggly), bracketStack)
      of '>':
        let cur = bracketStack.popFirst
        if cur != Sharp:
          return (some(Sharp), bracketStack)
      else:
        echo "Illegal character: ", ch
  return (none(Bracket), bracketStack)

func scoreError(tkn: Bracket): int =
  case tkn:
    of Round: 3
    of Square: 57
    of Squiggly: 1197
    of Sharp: 25137

func autoValues(tkn: Bracket): int =
  case tkn:
    of Round: 1
    of Square: 2
    of Squiggly: 3
    of Sharp: 4

func scoreAutocomplete(tkns: Deque[Bracket]): int =
  for tkn in tkns:
    result *= 5
    result += autoValues(tkn)


proc part1(data: seq[string]): int =
  for line in data:
    let (error, _) = line.errorCheck
    if error.isSome:
      result += error.get.scoreError

proc part2(data: seq[string]): int =
  var scores: seq[int]
  for line in data:
    let (error, completion) = line.errorCheck
    if error.isNone:
      scores.add(completion.scoreAutocomplete)
  scores.sort
  let idx = len(scores) div 2
  result = scores[idx]

let data = readFile("day10.txt").strip.splitLines
echo "Part1: ", part1(data)
echo "Part2: ", part2(data)

