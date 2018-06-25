//
//  Topology.swift
//  TopologyMusicNode
//
//  Created by Pofat Tseng on 2018/3/18.
//  Copyright © 2018年 Pofat. All rights reserved.
//

import SwiftGraph

class Topology {
    let start: Node
    let end: Node
    let nodes: [Node]
    var graph: WeightedGraph<Node, Int>? = nil
    
    init() {
        start = Node(position: .start, id: -1)
        end = Node(position: .end, id: 15)
        nodes = [start] + (0...14).map { Node(id: $0) } + [end]
    }
    
    
    func generateNewTopology(randomLevelUpperBound bound: Int = -1, onCompletion completion: (() -> Void)?) {
        // keep doing until requirement satisfied
        var numberOfTry = 1
        while true {
            // pick up some nodes and reset all props
            let visibleNodes = randomlySelectNodes()
            
            // Generate a new graph
            graph = WeightedGraph<Node, Int>(vertices: nodes)
            
            var numberOfAtLeastThreeChildren = 1
            var numberOfAtLeastTwoChildren = 3
            for index in 1...5 {
                let nodes = visibleNodes[index]
                
                var childrenCandidates: [Node] = []
                var parentCandidates: [Node] = []
                // 從任意多層前/後選擇 parent/children candidates
                if bound == -1 {
                    childrenCandidates = visibleNodes[index..<visibleNodes.endIndex].flatMap { $0 }
                    parentCandidates = visibleNodes[visibleNodes.startIndex ..< index].flatMap { $0 }
                } else { //只選擇給定的層數內之node 做為 candidates
                    childrenCandidates = visibleNodes[index..<min(visibleNodes.endIndex, index + bound)].flatMap { $0 }
                    parentCandidates = visibleNodes[max(visibleNodes.startIndex, index - bound) ..< index].flatMap { $0 }
                }
                // randomly assign children and parents for each nodes
                for n in nodes {
                    var randomChildren: Set<Node> = []
                    
                    var shouldContinueOutterLoop = false
                    var tryTimes = 0
                    while true {
                        randomChildren = selectRandomNumberOfElements(from: childrenCandidates)
                        // Remove self from children candidates
                        if randomChildren.contains(n) {
                            randomChildren.remove(n)
                        }
                        
                        // If children candidate is also a parent to current node, remove it from candidates
                        // Because we want a DAG, which is easier to handle
                        randomChildren.subtract(n.parents)
                        
                        // Must have at least one child
                        if !randomChildren.isEmpty {
                            break
                        }
                        
                        if tryTimes >= 10 {
                            shouldContinueOutterLoop = true
                            break
                        }
                        
                        tryTimes += 1
                    }
                    if shouldContinueOutterLoop {
                        numberOfTry += 1
                        print("select children failed, go to new random")
                        continue
                    }

                    n.children = randomChildren
                    
                    for c in n.children {
                        c.parents.insert(n)
                    }
                    
                    if n.children.count >= 3 && numberOfAtLeastThreeChildren > 0 {
                        numberOfAtLeastThreeChildren -= 1
                    } else if n.children.count >= 2 && numberOfAtLeastTwoChildren > 0 {
                        numberOfAtLeastTwoChildren -= 1
                    }
                    
                    let parents = selectRandomNumberOfElements(from: parentCandidates)
                    
                    for p in parents {
                        // add current node as new parent's child node
                        p.children.insert(n)
                        
                        if n.children.count >= 3 && numberOfAtLeastThreeChildren > 0 {
                            numberOfAtLeastThreeChildren -= 1
                        } else if n.children.count >= 2 && numberOfAtLeastTwoChildren > 0 {
                            numberOfAtLeastTwoChildren -= 1
                        }
                        // add new parent node
                        n.parents.insert(p)
                    }
                }
            }
            
            
            // check if satisfies requirement
            if numberOfAtLeastTwoChildren == 0 && (numberOfAtLeastThreeChildren == 0 || start.children.count >= 3) {
                // build graphs
                for n in nodes {
                    for c in n.children {
                        graph!.addEdge(from: n, to: c, directed: true, weight: c.value)
                    }
                }
                
                // Avoid cycles
                if graph!.detectCycles().isEmpty {
                    break
                }
            }
            print("#\(numberOfTry) run. Requirement not satisfied")
            numberOfTry += 1
        }
        
        completion?()
    }
    
    
    /// Retun visible nodes
    func visibleInternalNodes() -> [Node] {
        return nodes.filter { !$0.isHidden && $0.position == .intermediate }
    }
    
    /// Randomly set nodes to hide and assign random value
    ///
    /// - Returns: Visible node group in a level order
    func randomlySelectNodes() -> [[Node]] {
        // reset all to visible first
        for node in nodes {
            node.isHidden = false
            node.value = 0
            node.children.removeAll()
            node.parents.removeAll()
        }
        
        let hiddenNodeNumber = randomInt(from: 3...6)
        let hiddenNodeIds = Set<Int>(randomInts(from: 0...14, number: hiddenNodeNumber))
        
        for node in nodes {
            if node.position == .intermediate {
                node.value = randomInt(from: 1...7)
            }
            if hiddenNodeIds.contains(node.id) {
                node.isHidden = true
            }
        }
        
        let allVisibleNodes = nodes.filter { !hiddenNodeIds.contains($0.id) }
        var result: [[Node]] = Array(repeating: [], count: 7)
        for node in allVisibleNodes {
            if node.position == .start {
                result[0].append(node)
            } else if node.position == .end {
                result[6].append(node)
            } else {
                result[node.id / 3 + 1].append(node)
            }
        }
        
        return result
    }
    
    // print all nodes and its reloation
    func printTopology() {
        for n in nodes {
            if n.isHidden {
                continue
            }
            print("node #\(n.id), value: \(n.value)")
            print("parents: \(n.parents.map { $0.id })")
            print("children: \(n.children.map { $0.id })")
        }
    }
}

