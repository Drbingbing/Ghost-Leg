//
//  Reward.swift
//  LadderGame
//
//  Created by Bing Bing on 2022/3/21.
//

import Foundation

struct Reward: Hashable, ItemHashable {
    
    let id = UUID()
    
    let object: String
    
    let image: String? = nil
    
    var presentedColor: Color?
    
    var isWin: Bool {
        return !object.isEmpty
    }
}
