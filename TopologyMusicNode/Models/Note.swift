//
//  SoundManager.swift
//  TopologyMusicNode
//
//  Created by Pofat Tseng on 2018/3/16.
//  Copyright © 2018年 Pofat. All rights reserved.
//

import Foundation

enum Note: String {
    case `do`, re, mi, fa, sol, la, si
    
    var fileURL: URL {
        return Bundle.main.url(forResource: self.rawValue, withExtension: "wav")!
    }
}

extension Note {
    init?(_ value: Int) {
        switch value {
        case 1:
            self = .`do`
        case 2:
            self = .re
        case 3:
            self = .mi
        case 4:
            self = .fa
        case 5:
            self = .sol
        case 6:
            self = .la
        case 7:
            self = .si
        default:
            return nil
        }
    }
}


/// Play wav file of notes based on given integer array sequentially
///
/// - Parameter numbers: The notes to play in a playing order
func playNotes(from numbers: [Int]) {
    let items = numbers.flatMap { Note.init($0) }
        .flatMap { AZSoundItem.init(contentsOf: $0.fileURL) }
    var iterator = items.makeIterator()
    
    let soundManager = AZSoundManager.shared()
    soundManager?.getItemInfo(progressBlock: { _ in }) { [weak soundManager] item in
        if let nextItem = iterator.next() {
            soundManager?.play(nextItem)
        }
    }
    
    if let next = iterator.next() {
        soundManager?.play(next)
    }
    
}
