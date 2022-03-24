//
//  PlayerIconView.swift
//  LadderGame
//
//  Created by Bing Bing on 2022/3/21.
//

import UIKit

class IconView: UIView {
    
    let item: ItemHashable
    
    var imageView: UIImageView?
    var nameLabel: UILabel?
    
    var foregroundColor: UIColor?
    
    var onTouchUpInside = Delegate<ItemHashable, Void>()
    
    init(item: ItemHashable) {
        self.item = item
        super.init(frame: .zero)
        
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        nameLabel?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        imageView?.layer.cornerRadius = (imageView?.frame.width ?? 0) / 2
        nameLabel?.layer.cornerRadius = (nameLabel?.frame.width ?? 0) / 2
    }
    
    private func commonInit() {
        
        if let image = item.image {
            let imageView = UIImageView(image: UIImage(named: image))
            imageView.layer.borderColor = UIColor.lightGray.cgColor
            imageView.layer.borderWidth = 1
            self.addSubview(imageView)
            self.imageView = imageView
        }
        else {
            let label = UILabel()
            label.layer.borderWidth = 1
            label.layer.borderColor = UIColor.lightGray.cgColor
            label.text = String(item.object.prefix(2))
            label.textColor = .black
            label.textAlignment = .center
            self.addSubview(label)
            self.nameLabel = label
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.addGestureRecognizer(tap)
    }
    
    @objc
    private func onTap(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        
        onTouchUpInside(self.item)
    }
    
    func updateState(_ isSelected: Bool) {
        self.nameLabel?.textColor = isSelected ? (foregroundColor ?? UIColor.systemOrange) : UIColor.lightGray
        self.nameLabel?.layer.borderColor = isSelected ? (foregroundColor ?? UIColor.systemOrange).cgColor : UIColor.lightGray.cgColor
        self.nameLabel?.layer.borderWidth = isSelected ? 2 : 1
        
        self.imageView?.tintColor = isSelected ? UIColor.systemIndigo : UIColor.lightGray
        self.imageView?.layer.borderColor = isSelected ? (foregroundColor ?? UIColor.systemOrange).cgColor : UIColor.lightGray.cgColor
        self.imageView?.layer.borderWidth = isSelected ? 2 : 1
    }
}
