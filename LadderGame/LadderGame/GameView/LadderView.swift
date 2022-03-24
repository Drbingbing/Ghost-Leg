//
//  LadderView.swift
//  LadderGame
//
//  Created by Bing Bing on 2022/3/18.
//

import UIKit

struct IntersectionPoint {
    
    var from: CGPoint
    
    var to: CGPoint
}


class LadderView: UIView {
    
    private let randomGenerator: RandomRowGenerator
    private let totalPlayers: Int
    
    private(set) var startLocations: [CGPoint] = []
    private(set) var endLocations: [CGPoint] = []
    
    var onRenderComplete: Delegate<[IntersectionPoint], Void> = Delegate()
    
    var lineWidth: CGFloat = 1 { didSet { self.setNeedsDisplay() } }
    
    private var intersections: [IntersectionPoint] = []
    
    // Actual Frame to drawing content
    private(set) var cachedContentSize: CGRect = .zero
    
    init(randomGenerator: RandomRowGenerator, totalPlayers: Int, frame: CGRect) {
        self.randomGenerator = randomGenerator
        self.totalPlayers = totalPlayers
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.startLocations = [CGPoint](repeating: .zero, count: totalPlayers)
        self.endLocations = [CGPoint](repeating: .zero, count: totalPlayers)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    override func draw(_ rect: CGRect) {
        
        self.cachedContentSize = rect.insetBy(dx: lineWidth / 2, dy: 0)
        
        self.intersections.removeAll()
        
        drawingVerticalLines(in: cachedContentSize)
    }

    
    private func drawingVerticalLines(in rect: CGRect) {
       
        let startPoint = rect.origin
        
        let path = UIBezierPath()
        
        let availableWidth = rect.width
                
        let columns = totalPlayers
        let spacing = availableWidth / CGFloat(columns - 1)
        
        
        for column in 0..<columns {
            
            let index = CGFloat(column)
            
            let oirginalPoint = CGPoint(x: startPoint.x + spacing * index, y: startPoint.y)
            
            path.move(to: oirginalPoint )
            
            self.startLocations[column] = oirginalPoint
            
            let toPoint = CGPoint(x: startPoint.x + spacing * index, y: startPoint.y + rect.height)
            
            path.addLine(to: toPoint )
            
            self.endLocations[column] = toPoint
            
            let matrix = self.randomGenerator.rungs

            let rows = matrix[column]


            let frameToDraw = CGRect(x: startPoint.x + spacing * (index),
                                     y: startPoint.y,
                                     width: spacing,
                                     height: rect.height)

            if column < totalPlayers - 1 {
                drawHorizontalLines(in: frameToDraw, rows: rows)
                
            }
            
            
            if intersections.count >= self.randomGenerator.rungs
                .dropLast()
                .flatMap({ $0 }).count * 2, column >= totalPlayers - 1 {
                
                self.onRenderComplete(self.intersections)
                print("done create game ")
            }
            
        }
        
        UIColor.lightGray.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }
    
    private func drawHorizontalLines(in rect: CGRect, rows: [Int] = []) {
        
        var startPoint = rect.origin
        
        let totalRows = 10
        
        let path = UIBezierPath()
        
        let availableHeight = rect.height
        
        let spacing = availableHeight / CGFloat(totalRows + 1)
        
        path.move(to: startPoint)
        
        for row in 0..<totalRows {
            
            startPoint.y += spacing
            
            path.move(to: startPoint)

            if rows.contains(row) {
                let toPoint = CGPoint(x: startPoint.x + rect.width, y: startPoint.y)
                
                path.addLine(to: toPoint)
                
                let intersection1 = IntersectionPoint(from: startPoint,
                                                     to: toPoint)
                let intersection2 = IntersectionPoint(from: toPoint,
                                                      to: startPoint)
                
                intersections.append(contentsOf: [intersection1, intersection2])
                
            }
            
        }
        
        UIColor.lightGray.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }
    
}
