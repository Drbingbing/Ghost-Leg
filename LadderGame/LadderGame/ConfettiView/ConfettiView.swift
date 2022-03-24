//
//  ConfetiiView.swift
//  ConffetiView
//
//  Created by Bing Bing on 2022/3/24.
//

import UIKit

class ConfettiView: UIView {
    
    enum ConfettiType {
        
        case confetti
        
        case triangle
        
        case start
        
        case diamond
        
        case image(UIImage)
        
    }
    
    
    var emitter: CAEmitterLayer!
    
    var colors: [UIColor] = []
    
    var intensity: Float = 0
    
    var style: ConfettiType = .confetti
    
    var active: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    private func setup() {
        
        self.colors = [
            UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
            UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
            UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
            UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
            UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0)
        ]
        
        self.intensity = 0.5
        self.style = .confetti
        self.active = false
    }
    
    func startConfetti() {
        
        emitter = CAEmitterLayer()
        
        emitter.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: frame.size.width, height: 1)
        
        var cells = [CAEmitterCell]()
        for color in self.colors {
            cells.append(self.conffettiWithColor(color))
        }
        
        emitter.emitterCells = cells
        layer.addSublayer(emitter)
        active = true
    }
    
    func stopConfetti() {
        self.emitter?.birthRate = 0
        self.active = false
    }
    
    private func conffettiWithColor(_ color: UIColor) -> CAEmitterCell {
        let confetti = CAEmitterCell()
        confetti.birthRate = 6.0 * intensity
        confetti.lifetime = 14.0 * intensity
        confetti.lifetimeRange = 0
        confetti.color = color.cgColor
        confetti.velocity = CGFloat(350.0 * intensity)
        confetti.velocityRange = CGFloat(80.0 * intensity)
        confetti.emissionRange = CGFloat(Double.pi)
        confetti.emissionLongitude = CGFloat(Double.pi)
        confetti.spin = CGFloat(3.5 * intensity)
        confetti.spinRange = CGFloat(4.0 * intensity)
        confetti.scaleRange = CGFloat(intensity)
        confetti.scaleSpeed = CGFloat(-0.1 * intensity)
        confetti.contents = self.imageForStyle(self.style)?.cgImage
        
        return confetti
    }
    
    private func imageForStyle(_ style: ConfettiType) -> UIImage? {
        
        var filename: String = ""
        
        switch style {
        case .confetti:
            filename = "confetti"
        case .triangle:
            filename = "triangle"
        case .start:
            filename = "star"
        case .diamond:
            filename = "diamond"
        case .image(let uIImage):
            return uIImage
        }
        
        let path = Bundle(for: ConfettiView.self).path(forResource: filename, ofType: "png")
        let url = URL(fileURLWithPath: path!)
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        } catch {
            print(error)
        }
        return nil
    }
}
