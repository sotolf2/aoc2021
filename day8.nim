import 
  strutils,
  sequtils,
  sugar,
  sets,
  tables

type Entry = tuple
  pattern: seq[string]
  output: seq[string]

proc parseLine(data: string): Entry =
  let inOut = data.split(" | ")
  result.pattern = inOut[0].split()
  result.output = inOut[1].split()

proc parseFile(data: string): seq[Entry] =
  let lines = data.strip().splitLines()
  for line in lines:
    result.add(parseLine(line))

proc deduceSimple(patterns: seq[string], segments: int): HashSet[char] =
  for cand in patterns:
    if len(cand) == segments:
      return toHashset(cand)

proc searchSets(patterns: seq[string], needle: HashSet[char], difference: int): HashSet[char] =
  for cand in patterns:
    let candSet = toHashset(cand)
    if len(needle - candSet) == 0 and len(candSet) - len(needle) == difference:
      return candSet

proc deduceNine(patterns: seq[string], seven, four: HashSet[char]): HashSet[char] =
  let needle = seven + four
  searchSets(patterns, needle, 1)

proc deduceThree(patterns: seq[string], one, four, nine: HashSet[char]): HashSet[char] =
  let needle = nine - (four - one)
  searchSets(patterns, needle, 1)

proc deduceZero(one, four, nine, eight, three: HashSet[char]): HashSet[char] =
  let acfg = nine - (four - one)
  let b = nine - three
  let e = eight - nine
  result = acfg + b + e

proc deduceFive(patterns: seq[string], nine, one, eight: HashSet[char]): HashSet[char] =
  let needle = nine - one
  searchSets(patterns, needle, 1)

proc deduceSix(eight, five, nine: HashSet[char]): HashSet[char] =
  let ce = eight - five
  let e = eight - nine
  let c = ce - e
  result = eight - c

proc deduceTwo(six, one, nine, three, eight: HashSet[char]): HashSet[char] =
  let f = six * one
  let b = nine - three
  result = eight - f - b


proc deduceSegments(patterns: seq[string]): Table[HashSet[char], int] =
  let 
    one = deduceSimple(patterns, 2)
    seven = deduceSimple(patterns, 3)
    four = deduceSimple(patterns, 4)
    eight = deduceSimple(patterns, 7)
    nine = deduceNine(patterns, seven, four)
    three = deduceThree(patterns, one, four, nine)
    zero = deduceZero(one, four, nine, eight, three)
    five = deduceFive(patterns, nine, one, eight)
    six = deduceSix(eight, five, nine)
    two = deduceTwo(six, one, nine, three, eight)
    
    sets = [zero, one, two, three, four, five, six, seven, eight, nine]
    ints = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

  for pairs in zip(sets, ints):
    let (set, i) = pairs
    result[set] = i

proc deduceOutput(entry: Entry): int =
  let dict = deduceSegments(entry.pattern)
  var numString = ""
  for token in entry.output:
    let needle = toHashset(token)
    numString &= $dict[needle]
  numString.parseInt()
  

proc part1(data: seq[Entry]): int =
  let uniqueSegments = [2, 4, 3, 7]
  for entry in data:
    for segments in entry.output:
      if len(segments) in uniqueSegments:
        result += 1
      
proc part2(data: seq[Entry]): int =
  for entry in data:
    result += deduceOutput(entry)

let data = readFile("day8.txt").parseFile()
echo "Part 1: ", part1(data)
echo "Part 2: ", part2(data)

