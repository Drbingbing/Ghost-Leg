//
//  Item.swift
//  LadderGame
//
//  Created by Bing Bing on 2022/3/23.
//

import UIKit

class PlayerItem {
    
    var player: Player?
    
    var color: UIColor = randomColor(luminosity: .dark)
}


class RewardItem {
    
    var reward: Reward?
    
    var color = Color.black
}

protocol ItemHashable {
    
    var id: UUID { get }
    
    var object: String { get }
    
    var image: String? { get }
    
    var presentedColor: Color? { get set }
}

extension ItemHashable {
    
    var displayColor: UIColor {
        return presentedColor ?? .systemOrange
    }
    
    var title: String {
        return object == "槓" ? "槓龜" : object
    }
}
//
//extension Module: AnyObject {
//    
//    var object: ItemHashable { get set }
//    
//    var
//}
