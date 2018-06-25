//
//  Node.swift
//  TopologyMusicNode
//
//  Created by Pofat Tseng on 2018/3/14.
//  Copyright © 2018年 Pofat. All rights reserved.
//

import Foundation

class Node: Hashable {
    var hashValue: Int {
        return id.hashValue ^ value.hashValue ^ position.hashValue
    }
    
    static func ==(lhs: Node, rhs: Node) -> Bool {
        return lhs.position == rhs.position && lhs.id == rhs.id && lhs.value == rhs.value
    }
    
    enum Position: Int {
        case start, intermediate, end
    }
    
    var position: Position
    var id: Int
    var value: Int = 0
    var children: Set<Node> = []
    var isHidden = false
    var parents: Set<Node> = []

    
    init(position: Position = .intermediate, id: Int) {
        self.position = position
        self.id = id
    }
    
    func resetRelation() {
        children = []
        parents = []
    }
    /// Return parent nodes who are not in the same level (left-side parent nodes)
    func parentsInAboveLevel() -> [Node] {
        // root node
        guard self.position != .start else {
            return []
        }
        
        let levelNumber = self.id / 3
        let currentLevelIds = [levelNumber * 3, levelNumber * 3 + 1, levelNumber * 3 + 2]
        
        return self.parents.filter { !currentLevelIds.contains($0.id) }
    }
}
