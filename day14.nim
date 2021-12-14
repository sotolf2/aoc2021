import strutils, strtabs, tables, deques, sugar


proc parseFile(filename: string): (string, StringTableRef) =
  let parts = readFile(filename).strip.split("\n\n")
  let polymer = parts[0]
  var rules = newStringTable()
  for line in parts[1].splitLines():
    let tkns = line.split(" -> ")
    rules[tkns[0]] = tkns[1]

  (polymer, rules)

proc part1(inPolymer: string, rules: StringTableRef): int =
  var polymer = inPolymer
  for i in 1..10:
    var newPolymer = ""
    for i in 0..(polymer.len - 2):
      let cur = polymer[i] & polymer[i+1]
      newPolymer &= polymer[i]
      newPolymer &= rules[cur]
    newPolymer &= polymer[polymer.high]
    polymer = newPolymer

  let counts = toCountTable(polymer)
  var largest = 0
  var smallest = int.high
  for count in counts.values:
    if count > largest:
      largest = count
    if count < smallest:
      smallest = count
  largest - smallest

proc part2(polymer: string, rules: StringTableRef): int =
  # first make a count of characters
  var charCount = toCountTable(polymer)
  # since we can do pairs independently we work with the pairs
  # instead of having to do the whole string this time
  var pairCount = initCountTable[string]()
  for i in 1..polymer.high:
    pairCount.inc(polymer[i-1 .. i])

  # Now for each iteration we can go through the pairs
  # witout having to deal with having the whole thing saved
  for _ in 1..40:
    # now we deal with the pairs one by the other
    let loop = pairCount
    for (pair, count) in loop.pairs:
      let newChar = rules[pair]
      # we now create new pairs with the new character
      pairCount.inc(pair[0] & newChar, count)
      pairCount.inc(newChar & pair[1], count)
      # and we delete pairs for the one we just used
      pairCount.inc(pair, -count)
      # now we can add the new character to our character count
      charCount.inc(newChar[0], count)

  # and finally we can calculate the result
  let (_, largest) = charCount.largest
  let (_, smallest) = charCount.smallest
  largest - smallest


let (polymer, rules) = parseFile("day14.txt")
echo "Part1: ", part1(polymer, rules)
echo "Part2: ", part2(polymer, rules)
