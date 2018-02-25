protocol PVNode {
    var level: Int { get }
    
    init(level: Int)
    
    func get(idx: Int) -> Any
    
    func with(idx: Int, value: Any) -> PVNode
    
    func set(idx: Int, value: Any)
    
    func getSize() -> Int
    
    func isFull() -> Bool
    
    func plus(value: Any) -> PVNode?
    
    func add(value: Any) -> Bool
    
    func plus(valueNode: PVValueNode<Any>) -> PVNode?
    
    func withoutLast() -> PVNode?
    
    func removeLast() -> Bool
}

//func == <E: Equatable>(lhs: PVNode, rhs: PVNode<E>) -> Bool {
//    return false
//}

func createNodeForValue(level: Int, value: Any) -> PVNode {
    if level > 0 {
        return PVTreeNode(level: level, subNode: createNodeForValue(level: level - 1, value: value))
    } else if level == 0 {
        return PVValueNode(value: value)
    } else {
        fatalError("Logical error in createNodeForValue")
    }
}

func createNodeForValueNode(level: Int, valueNode: PVValueNode<Any>) -> PVNode {
    if level > 1 {
        return PVTreeNode(level: level, subNode: createNodeForValueNode(level: level - 1, valueNode: valueNode))
    } else if level == 1 {
        return PVTreeNode(level: level, subNode: valueNode)
    } else if level == 0 {
        return valueNode
    } else {
        fatalError("Logical error in createNodeForValue")
    }
}
