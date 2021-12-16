import strutils, deques, strformat, sequtils, sugar

type 
  BitStream = object
    data: Deque[char]
    buffer: BitString

  BitString = distinct string

type
  OpType = enum
    Sum,
    Product,
    Minimum,
    Maximum,
    Number,
    GreaterThan,
    LessThan,
    Equal

  Packet = ref object of RootObj
    version: int
    typeId: int

  Literal = ref object of Packet
    intValue: int

  Operation = ref object of Packet
    packets: seq[Packet] 
    opType: OpType

method `$`(self: Packet, indent: int = 0): string =
  result &= " ".repeat(indent)
  result &= fmt"<{self.typeId}>"

method `$`(self: Literal, indent: int = 0): string =
  result &= " ".repeat(indent)
  result &= fmt"<Literal> {self.intValue}"

method `$`(self: Operation, indent: int = 0): string =
  result &= " ".repeat(indent)
  result &= fmt"<{self.opType}>"
  for pkt in self.packets:
    result &= "\n"
    result &= " ".repeat(indent + 2)
    result &= pkt $ (indent + 2)
 
method sumVersions(self: Packet): int =
  self.version

method sumVersions(self: Operation): int =
  self.packets.mapIt(it.sumVersions()).foldl(a+b) + self.version

proc convertHexDigit(ch: char): BitString =
  result =
    case ch:
    of '0': "0000".BitString
    of '1': "0001".BitString
    of '2': "0010".BitString
    of '3': "0011".BitString
    of '4': "0100".BitString
    of '5': "0101".BitString
    of '6': "0110".BitString
    of '7': "0111".BitString
    of '8': "1000".BitString
    of '9': "1001".BitString
    of 'A': "1010".BitString
    of 'B': "1011".BitString
    of 'C': "1100".BitString
    of 'D': "1101".BitString
    of 'E': "1110".BitString
    of 'F': "1111".BitString
    else: "".BitString

proc len(a: BitString): int {.borrow.}
proc `&=`(a: var BitString, b: BitString) {.borrow.}
proc `$`(a: BitString): string {.borrow.}
proc `==`(a, b: BitString): bool {.borrow.}
proc parseBinInt(a: BitString): int {.borrow.}

proc newBitStream(data: string): BitStream =
  result.data = data.toDeque
  result.buffer = "".BitString

proc clearBuffer(self: var BitStream) =
  self.buffer = "".BitString

proc `$`(self: BitStream): string =
  result &= "Buffer: "
  result &= $self.buffer
  result &= "\n"
  result &= "Stream: "
  result &= $self.data

proc len(self: BitStream): int =
  result += len(self.buffer)
  result += len(self.data) * 4

proc read(self: var BitStream, numBits: int): BitString =
  while len(self.buffer) < numBits:
    self.buffer &= self.data.popFirst.convertHexDigit
  result = self.buffer.string[0..<numBits].BitString
  self.buffer = self.buffer.string[numBits..^1].BitString

proc readInt(stream: var BitStream): int =
  var bits = "".BitString
  while stream.read(1) == "1".BitString:
    bits &= stream.read(4)
  bits &= stream.read(4)
  bits.parseBinInt()

proc hasData(self: BitStream): bool =
  if self.buffer != "".BitString and len(self.data) > 0:
    result = true

proc parsePkg(stream: var BitStream): Packet

proc readPacketLen(stream: var Bitstream, length: int): seq[Packet] =
  var readLen = 0
  var streamlen = stream.len()
  while readLen < length:
    result.add(stream.parsePkg())
    var nulen = streamlen - stream.len() 
    readLen += nulen
    streamlen = stream.len()

proc readPackets(stream: var BitStream, numPackets: int): seq[Packet] =
  for _ in 1..numPackets:
    result.add(stream.parsePkg())

proc readSubPackages(stream: var BitStream): seq[Packet] =
  let lenType = stream.read(1)
  case lenType:
    of "0".BitString:
      var packetLen = stream.read(15).parseBinInt()
      #echo "--- Operation with length: ", packetLen, " ---"
      result &= stream.readPacketLen(packetLen)
    of "1".BitString:
      var numPackets = stream.read(11).parseBinInt()
      #echo "--- Operation with ", numPackets, " packets ---"
      result &= stream.readPackets(numPackets)
    else: 
      echo "--!!-- LenType: ", lenType, " is of an illegal value --!!--"


proc parsePkg(stream: var BitStream): Packet =
  let version = stream.read(3).parseBinInt()
  let typeId = stream.read(3).parseBinInt()
  case typeId:
    of 4:
      #echo "-- Parsing Literal --"
      return Literal(version: version, typeId: typeId, intValue: stream.readInt())
    else:
      #echo "-- Parsing Operation --"
      return Operation(version: version, typeId: typeId, opType: typeId.OpType ,packets: stream.readSubPackages())
    #else:
      #echo "Type: ", typeId, " is not yet implemented"

proc part1(inStream: BitStream): int =
  var stream = inStream
  var packet = stream.parsePkg()
  packet.sumVersions()

proc eval(pkt: Packet): Literal

proc sum(pkt: Operation): Literal =
  var args: seq[int]
  for sub in pkt.packets:
    args.add(sub.eval().intValue)
  Literal(version: 0, typeId: 4, intValue: args.foldl(a+b))

proc product(pkt: Operation): Literal =
  var args: seq[int]
  for sub in pkt.packets:
    args.add(sub.eval().intValue)
  Literal(version: 0, typeId: 4, intValue: args.foldl(a*b))

proc minimum(pkt: Operation): Literal =
  var args: seq[int]
  for sub in pkt.packets:
    args.add(sub.eval().intValue)
  Literal(version: 0, typeId: 4, intValue: min(args))

proc maximum(pkt: Operation): Literal =
  var args: seq[int]
  for sub in pkt.packets:
    args.add(sub.eval().intValue)
  Literal(version: 0, typeId: 4, intValue: max(args))

proc greaterThan(pkt: Operation): Literal =
  let fst = pkt.packets[0].eval().intValue
  let snd = pkt.packets[1].eval().intValue
  var res = 0
  if fst > snd:
    res = 1
  Literal(version: 0, typeId: 4, intValue: res)

proc lessThan(pkt: Operation): Literal =
  let fst = pkt.packets[0].eval().intValue
  let snd = pkt.packets[1].eval().intValue
  var res = 0
  if fst < snd:
    res = 1
  Literal(version: 0, typeId: 4, intValue: res)

proc equals(pkt: Operation): Literal =
  let fst = pkt.packets[0].eval().intValue
  let snd = pkt.packets[1].eval().intValue
  var res = 0
  if fst == snd:
    res = 1
  Literal(version: 0, typeId: 4, intValue: res)

proc eval(pkt: Packet): Literal =
  if pkt of Operation: 
    var pkt = pkt.Operation
    case pkt.opType:
      of Sum:
        return pkt.sum()
      of Product:
        return pkt.product()
      of Minimum:
        return pkt.minimum()
      of Maximum:
        return pkt.maximum()
      of Number:
        echo "Number not implemented"
      of GreaterThan:
        return pkt.greaterThan()
      of LessThan:
        return pkt.lessThan()
      of Equal:
        return pkt.equals()
  else:
    return pkt.Literal
  

proc part2(inStream: BitStream): int =
  var stream = inStream
  var packet = stream.parsePkg()
  packet.eval().intValue

let hexData = readFile("day16.txt")
echo "Part1: ", part1(newBitStream(hexData))
echo "Part2: ", part2(newBitStream(hexData))

