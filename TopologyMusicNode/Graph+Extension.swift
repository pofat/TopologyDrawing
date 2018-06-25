//
//  Graph+Extension.swift
//  TopologyMusicNode
//
//  Created by Pofat Tseng on 2018/3/18.
//  Copyright © 2018年 Pofat. All rights reserved.
//

import SwiftGraph

class MyQueue<T: Equatable> {
    private var container: [T] = [T]()
    var isEmpty: Bool { return container.isEmpty }
    var count: Int { return container.count }
    func push(_ thing: T) { container.append(thing) }
    func pop() -> T { return container.remove(at: 0) }
    func contains(_ thing: T) -> Bool {
        if container.index(of: thing) != nil {
            return true
        }
        return false
    }
}

extension Graph {    
    /// Find all possible routes from a vertex to all others nodes which
    /// satisfy goalTest() for using a depth-first search.
    ///
    /// - parameter from: The index of the starting vertex.
    /// - parameter goalTest: Returns true if a given vertex is a goal.
    /// - returns: An array of arrays of Edges containing routes to every vertex connected and passing goalTest(), or an empty array if no routes could be founding the entire route, or an empty array if no route could be found
    func findAllPathsByDFS(from: V, goalTest: (V) -> Bool) -> [[Edge]] {
        // pretty stand dfs; pathDict tracks route
        guard let fromInt = indexOfVertex(from) else {
            return []
        }
        var pathDict: [Int: Edge] = [Int: Edge]()
        var paths: [[Edge]] = [[Edge]]()
        
        myDfs(from: fromInt, node: fromInt, pathDict: &pathDict, paths: &paths, goalTest: goalTest)
        return paths
        
    }
    
    func myDfs(from: Int, node: Int, pathDict: inout [Int: Edge], paths: inout [[Edge]], goalTest: (V) -> Bool) {
        
        if goalTest(vertexAtIndex(node)) {
            paths.append(pathDictToPath(from: from, to: node, pathDict: pathDict))
            return
        }
        
        for e in edgesForIndex(node) {
            pathDict[e.v] = e
            myDfs(from: from, node: e.v, pathDict: &pathDict, paths: &paths, goalTest: goalTest)
            pathDict.removeValue(forKey: e.v)
        }
    }
}

