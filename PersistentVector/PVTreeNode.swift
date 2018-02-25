final class PVTreeNode : PVNode {
    let level: Int
    var nodes: [PVNode]
    var size: Int
    
    private init(level: Int, nodes: [PVNode], size: Int) {
        self.nodes = nodes
        
        if nodes.count == 0 {
            fatalError("Attempt to create an empty TreeNode")
        }
        
        self.size = size
        
        self.level = level
    }
    
    init(level: Int, subNode: PVNode) {
        let nodes = [subNode]
        
        self.nodes = nodes
        self.size = subNode.getSize()
        
        if self.size == 0 {
            fatalError("Attempt to create an empty TreeNode")
        }
        
        self.level = level
    }
    
    init(lhs: PVNode, rhs: Any) {
        if lhs.isFull() == false {
            fatalError("lhs node is not full")
        }
        
        let nodes = [lhs, createNodeForValue(level: lhs.level, value: rhs)]
        
        self.nodes = nodes
        self.size = lhs.getSize() + 1
        
        if self.size == 0 {
            fatalError("Attempt to create an empty TreeNode")
        }
        
        self.level = lhs.level + 1
    }
    
    init(lhs: PVNode, rhs: PVValueNode) {
        if lhs.isFull() == false {
            fatalError("lhs node is not full")
        }
        
        let nodes = [lhs, createNodeForValueNode(level: lhs.level, valueNode: rhs)]
        
        self.nodes = nodes
        self.size = lhs.getSize() + rhs.getSize()
        
        if self.size == 0 {
            fatalError("Attempt to create an empty TreeNode")
        }
        
        self.level = lhs.level + 1
    }
    
    func get(idx: Int) -> Any {
        var idx = idx
        
        if idx >= 0 && idx < size {
            for node in nodes {
                if idx < node.getSize() {
                    return node.get(idx: idx)
                } else {
                    idx -= node.getSize()
                }
            }
        }
        
        fatalError("Logical error in TreeNode")
    }
    
    func with(idx: Int, value: Any) -> PVTreeNode {
        var idx = idx
        
        if idx >= 0 && idx < size {
            for nodeIdx in 0 ..< nodes.count {
                let node = nodes[nodeIdx]
                
                if idx < node.getSize() {
                    let newNode = node.with(idx: idx, value: value)
                    
                    if newNode !== node {
                        var newNodes = nodes
                        newNodes[nodeIdx] = newNode
                        return PVTreeNode(level: level, nodes: newNodes, size: size)
                    } else {
                        return self
                    }
                } else {
                    idx -= node.getSize()
                }
            }
        }
        
        fatalError("Logical error in TreeNode")
    }
    
    func set(idx: Int, value: Any) {
        var idx = idx
        
        if idx >= 0 && idx < size {
            for nodeIdx in 0 ..< nodes.count {
                let unshared = isKnownUniquelyReferenced(&nodes[nodeIdx])
                
                let node = nodes[nodeIdx]
                
                if idx < node.getSize() {
                    if unshared {
                        node.set(idx: idx, value: value)
                    } else {
                        let newNode = node.with(idx: idx, value: value)
                        
                        if newNode !== node {
                            nodes[nodeIdx] = newNode
                        }
                    }
                    
                    return
                } else {
                    idx -= node.getSize()
                }
            }
        }
        
        fatalError("Logical error in TreeNode")
    }
    
    func getSize() -> Int {
        return size
    }
    
    func isFull() -> Bool {
        return nodes.count == maximumSubNodes && nodes[nodes.count - 1].isFull()
    }
    
    func plus(value: Any) -> PVNode? {
        // attempt to replace the last sub-node
        if nodes.count > 0 {
            let lastSubnode = nodes[nodes.count - 1]
            
            let lastSubnodeReplacement = lastSubnode.plus(value: value)
            
            if let lastSubnodeReplacement = lastSubnodeReplacement {
                var newNodes = nodes
                newNodes[nodes.count - 1] = lastSubnodeReplacement
                
                return PVTreeNode(level: level, nodes: newNodes, size: size + 1)
            }
        }
        
        // attempt to add a new sub-node
        if nodes.count < maximumSubNodes {
            var newNodes = nodes
            newNodes.append(createNodeForValue(level: level - 1, value: value))
            
            return PVTreeNode(level: level, nodes: newNodes, size: size + 1)
        }
        
        // this node is full
        return nil
    }
    
    func add(value: Any) -> Bool {
        // attempt to replace the last sub-node
        if nodes.count > 0 {
            let unshared = isKnownUniquelyReferenced(&nodes[nodes.count - 1])
            
            let lastSubnode = nodes[nodes.count - 1]
            
            if unshared {
                if lastSubnode.add(value: value) {
                    size += 1
                    
                    return true
                }
            } else {
                let lastSubnodeReplacement = lastSubnode.plus(value: value)
                
                if let lastSubnodeReplacement = lastSubnodeReplacement {
                    nodes[nodes.count - 1] = lastSubnodeReplacement
                    
                    return true
                }
            }
        }
        
        // attempt to add a new sub-node
        if nodes.count < maximumSubNodes {
            nodes.append(createNodeForValue(level: level - 1, value: value))
            
            size += 1
            
            return true
        }
        
        // this node is full
        return false
    }
    
    func plus(valueNode: PVValueNode) -> PVTreeNode? {
        // attempt to replace the last sub-node
        if nodes.count > 0 {
            let lastSubnode = nodes[nodes.count - 1]
            
            let lastSubnodeReplacement = lastSubnode.plus(valueNode: valueNode)
            
            // if the last sub-node is not full and thus could create a replacement node...
            if let lastSubnodeReplacement = lastSubnodeReplacement {
                var newNodes = nodes
                newNodes[nodes.count - 1] = lastSubnodeReplacement
                
                return PVTreeNode(level: level, nodes: newNodes, size: size + valueNode.getSize())
            }
        }
        
        // attempt to add a new sub-node
        if nodes.count < maximumSubNodes {
            var newNodes = nodes
            newNodes.append(createNodeForValueNode(level: level - 1, valueNode: valueNode))
            
            return PVTreeNode(level: level, nodes: newNodes, size: size + valueNode.getSize())
        }
        
        // this node is full
        return nil
    }
    
    func withoutLast() -> PVTreeNode? {
        let lastSubnode = nodes[nodes.count - 1]
        
        let lastSubnodeReplacement = lastSubnode.withoutLast()
        
        if let lastSubnodeReplacement = lastSubnodeReplacement {
            var newNodes = nodes
            newNodes[nodes.count - 1] = lastSubnodeReplacement
            
            if lastSubnodeReplacement.getSize() != lastSubnode.getSize() - 1 {
                fatalError("Logical error - subnode of size \(lastSubnode.getSize()) returned null on withoutLast")
            }
            
            return PVTreeNode(level: level, nodes: newNodes, size: size - 1)
        } else {
            if nodes.count == 1 {
                return nil
            } else {
                var newNodes = nodes
                newNodes.removeLast()
                
                if lastSubnode.getSize() != 1 {
                    fatalError("Logical error - subnode of size \(lastSubnode.getSize()) returned null on withoutLast")
                }
                
                return PVTreeNode(level: level, nodes: newNodes, size: size - 1)
            }
        }
    }
    
    func removeLast() -> Bool {
        let unshared = isKnownUniquelyReferenced(&nodes[nodes.count - 1])
        
        let lastSubnode = nodes[nodes.count - 1]
        
        if unshared {
            if lastSubnode.removeLast() == false {
                nodes.removeLast()
            }
            
            size -= 1
            
            return size > 0
        } else {
            let lastSubnodeReplacement = lastSubnode.withoutLast()
            
            if let lastSubnodeReplacement = lastSubnodeReplacement {
                nodes[nodes.count - 1] = lastSubnodeReplacement
                
                if lastSubnodeReplacement.getSize() != lastSubnode.getSize() - 1 {
                    fatalError("Logical error - subnode of size \(lastSubnode.getSize()) returned null on withoutLast")
                }
                
                size -= 1
                
                return true
            } else {
                if nodes.count == 1 {
                    return false
                } else {
                    nodes.removeLast()
                    
                    if lastSubnode.getSize() != 1 {
                        fatalError("Logical error - subnode of size " +
                            "\(lastSubnode.getSize()) returned null on withoutLast")
                    }
                    
                    size -= 1
                    
                    return true
                }
            }
        }
    }
}