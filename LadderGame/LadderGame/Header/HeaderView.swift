//
//  HeaderView.swift
//  LadderGame
//
//  Created by Bing Bing on 2022/3/23.
//

import UIKit

class HeaderView: UITableViewHeaderFooterView {

    static let reuseID = "HeaderView"
    
    let label = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.addSubview(label)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
        self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
        self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
