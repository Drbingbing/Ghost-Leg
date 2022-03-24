//
//  RandomGameGenerator.swift
//  LadderGame
//
//  Created by Bing Bing on 2022/3/18.
//

import Foundation


class RandomRowGenerator {
    typealias Rungs = [[Int]]
    
    private(set) var rungs: Rungs {
        get {
            assert(self._cachedRowMatrix != nil,"game must be setting before play")
            return self._cachedRowMatrix!
        }
        set { self._cachedRowMatrix = newValue }
    }
    
    private var _cachedRowMatrix: Rungs?
    func prepare(by totalPlayers: Int) {
        
        guard self._cachedRowMatrix == nil else { return }
        
        var matrix = Rungs(repeating: [], count: totalPlayers)
        
        for index in 0..<totalPlayers - 1 {
            
            let isEvenNumber = index % 2 == 0
            
            let range = isEvenNumber ? [0, 2, 4, 6, 8] : [1, 3, 5, 7, 9]
            
            let rows = range.choose(self.randomChoose())
            
            matrix[index] = rows.collection()
        }
        
        self._cachedRowMatrix = matrix
        
    }
    
    private func randomChoose() -> Int {
        return Int.random(in: 3...5)
    }
}


extension Collection {
    
    func choose(_ n: Int) -> ArraySlice<Element> { shuffled().prefix(n) }
    
}

extension ArraySlice {
    
    func collection() -> [Element] {
        Array(self)
    }
    
}
