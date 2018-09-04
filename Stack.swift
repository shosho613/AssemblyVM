struct IntStack : CustomStringConvertible {
  var size : Int
  var array : [Int]
  var head : Int = -1
  init (size : Int) {
    self.size = size
    array = [Int](repeating: 0, count: size)
  }
  func isEmpty() -> Bool {
    return head < 0
  }
  func isFull() -> Bool {
    return head >= size-1
  }
  mutating func push(_ element: Int) {
    if head < size-1 {
      head += 1
      array[head] = element
    }
  }
  mutating func pop() -> Int? {
    if head >= 0 {
      let r : Int? = array[head]
      head -= 1
      return r
    }
    return nil
  }
  var description : String {
    var rs : String = ""
    var index : Int = 0
    for a in array {
      if index <= head {
        rs += "\(a) "
      }
      index += 1
    }
    return "H \(rs)H"
  }
}