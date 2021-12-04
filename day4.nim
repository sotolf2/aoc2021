import strutils, sequtils, strformat, sets

type Board = object
  numbers: seq[seq[int]]
  marks: seq[seq[bool]]

proc `$`(board: Board): string =
  for i in 0..board.numbers.high:
    for j in 0..board.numbers[i].high:
      let cell = board.numbers[i][j]
      if board.marks[i][j]:
        result &= fmt"[{cell:>2}]"
      else:
        result &= fmt" {cell:>2} "
    result &= "\n"

proc parseQueue(line: string): seq[int] =
  line.split(',').map(parseInt)

proc parseBoard(lines: seq[string]): Board =
  for line in lines:
    let prepared = line.split().filterIt(it!="").map(parseInt)
    result.numbers.add(prepared)
    let falses = repeat(false, prepared.len)
    result.marks.add(falses)

proc parseData(data: string): (seq[int], seq[Board]) =
  let lines = data.splitLines()
  let queue = parseQueue(lines[0])
  
  var boards: seq[Board]
  var i = 2
  while i < lines.high:
    boards.add(parseBoard(lines[i..i+4]))
    i += 6
 
  (queue, boards)

proc checkRows(self: Board): bool =
  var subs: seq[bool]
  for row in self.marks:
    subs.add(row.allIt(it))

  subs.anyIt(it)

proc checkCols(self: Board): bool =
  var transposed: seq[seq[bool]]
  for col in 0..self.marks[0].high:
    var r: seq[bool]
    for row in 0..self.marks.high: 
      r.add self.marks[row][col]
    transposed.add(r)

  var subs: seq[bool]
  for row in transposed:
    subs.add(row.allIt(it))

  subs.anyIt(it)

proc check(self: Board): bool =
  self.checkRows() or self.checkCols() 

proc mark(self: var Board, number: int) =
  for row in 0..self.numbers.high:
    for col in 0..self.numbers[0].high:
      if self.numbers[row][col] == number:
        self.marks[row][col] = true
        return

proc score(self: Board, called: int): int =
  var notMarked: int
  for row in 0..self.numbers.high:
    for col in 0..self.numbers[0].high:
      if not self.marks[row][col]:
        notMarked += self.numbers[row][col]
  notMarked * called

proc part1(queue: seq[int], inBoards: seq[Board]): int =
  var boards = inBoards
  for num in queue:
    for board in boards.mItems():
      board.mark(num)
      if board.check():
        return board.score(num)

proc part2(queue: seq[int], inBoards: seq[Board]): int =
  var boards = inBoards
  var play: HashSet[int]
  for i in 0..boards.high:
    play.incl(i)

  for num in queue:
    #echo fmt"----- {num} called -----"
    for i in 0..boards.high:
      boards[i].mark(num)
      #echo boards[i]
      if i in play and boards[i].check():
        if play.len() == 1:
          return boards[i].score(num)
        else:
          play.excl(i)

var (queue, boards) = readFile("day4.txt").parseData()
echo "Part1: ", part1(queue, boards)
echo "Part2: ", part2(queue, boards)
