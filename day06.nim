include strutils, sequtils, tables

proc parseData(data: string): seq[int] =
  data.strip().split(',').map(parseInt)

proc countFish(data: seq[int], days: int): int =
  var sea = data
  for i in 1..days:
    var newSea: seq[int] = @[]
    for fish in sea:
      case fish
      of 1..8: newSea.add(fish - 1)
      of 0: 
        newSea.add(6)
        newSea.add(8)
      else: echo "Fish with invalid timer"
    sea = newSea
  len(sea)

proc countFishLong(data: seq[int], days: int): int =
  var sea: Table[int, int]

  for fish in data:
    if sea.hasKeyOrPut(fish, 1):
      sea[fish] += 1

  for i in 1..days:
    #echo i, ": ", sea
    var newSea: Table[int, int]
    for (fish, amount) in sea.pairs(): 
      if fish > 0:
        newSea[fish-1] = amount
      else:
        if newSea.hasKeyOrPut(8, amount):
          newSea[8] += amount
        if newSea.hasKeyOrPut(6, amount):
          newSea[6] += amount
    sea = newSea
  for amount in sea.values():
    result += amount


let data = parseData(readFile("day6.txt"))
echo "Part1: ", countFish(data, 80)
echo "Part2: ", countFishLong(data, 256)

