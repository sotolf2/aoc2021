import 
  deques,
  sets,
  tables,
  strutils,
  sugar

type 
  Graph = Table[string, seq[string]]
  Path = seq[string]

func addEdge(self: var Graph, a, b: string) =
  if a != "end" and b != "start":
    if self.hasKeyOrPut(a, @[b]):
      self[a].add(b)
  if a != "start" and b != "end":
    if self.hasKeyOrPut(b, @[a]):
      self[b].add(a)

func parse(data: seq[string]): Graph =
  for line in data:
    let tkns = line.split("-")
    result.addEdge(tkns[0], tkns[1])

func enqueue(self: var Deque, item: string, path: Path = @[], seen: HashSet[string] = initHashSet[string]()) =
  self.addFirst((item, path, seen))

proc findAllPaths(graph: Graph): seq[Path] =
  var toExplore = initDeque[(string, Path, HashSet[string])]()
  toExplore.enqueue("start")
  while toExplore.len > 0:
    let (cur, path, seen) = toExplore.popFirst()
    if cur == "end":
      #echo "Found path: ", path
      result.add(path)
      continue
    for newNode in graph[cur]:
      var 
        nuSeen = seen
        nuPath = path
      if newNode notin seen:
        if newNode[0].isLowerASCII:
          nuSeen.incl(newNode)
        nuPath.add(newNode)
        #dump (newNode, nuPath, nuSeen)
        toExplore.enqueue(newNode, nuPath, nuSeen)

func enqueue2(self: var Deque, item: string, path: Path = @[], seen: HashSet[string] = initHashSet[string](), seen2: string = "") =
  self.addFirst((item, path, seen, seen2))

proc findAllPathsWithTwist(graph: Graph): seq[Path] =
  var toExplore = initDeque[(string, Path, HashSet[string], string)]()
  toExplore.enqueue2("start")
  while toExplore.len > 0:
    let (cur, path, seen, seen2) = toExplore.popFirst()
    if cur == "end":
      #echo "Found path: ", path
      result.add(path)
      continue
    for newNode in graph[cur]:
      var 
        nuSeen = seen
        nuPath = path
        nuSeen2 = seen2
      if newNode notin seen or seen2 == "":
        if newNode[0].isLowerASCII:
          if newNode in seen:
            nuSeen2 = newNode
          nuSeen.incl(newNode)
        nuPath.add(newNode)
        #dump (newNode, nuPath, nuSeen)
        toExplore.enqueue2(newNode, nuPath, nuSeen, nuSeen2)

proc part1(graph: Graph): int =
  var paths = findAllPaths(graph)
  paths.len

proc part2(graph: Graph): int =
  var paths = findAllPathsWithTwist(graph)
  paths.len

let data = readFile("day12.txt").strip.splitLines.parse
#echo data
echo "Part1: ", part1(data)
echo "Part2: ", part2(data)
