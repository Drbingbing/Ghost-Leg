//
//  Player.swift
//  LadderGame
//
//  Created by Bing Bing on 2022/3/18.
//

import Foundation

struct Player: Hashable, ItemHashable {
    
    internal init(name: String, image: String?, presentedColor: Color? = nil) {
        self.name = name
        self.image = image
        self.presentedColor = presentedColor
    }
    
    let id: UUID = UUID()
    
    var object: String { return name }
    let name: String
    
    var image: String?
    
    var presentedColor: Color?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}
