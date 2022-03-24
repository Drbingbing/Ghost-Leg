//
//  GameView.swift
//  LadderGame
//
//  Created by Bing Bing on 2022/3/18.
//

import UIKit

class GameView: UIView {
    typealias GameResult = (player: Player, reward: Reward)
    typealias GameRouteTrack = (tracker: ItemHashable, routes: [CGPoint])

    private lazy var ladderView = LadderView(randomGenerator: serivce.randomGenerator,
                                     totalPlayers: serivce.players.count,
                                     frame: .zero)
    
    private let routeView = UIView()
    private let markerView = UIView()
    private let playerView = HorizontalStackView()
    private let rewardView = HorizontalStackView()
    
    private var routeLayers: [CAShapeLayer] = []
    private var reversedLayers: [CAShapeLayer] = []
    private var markerLayers: [CAShapeLayer] = []
    private var reversedMarkers: [CAShapeLayer] = []
    
    private let serivce: GameService
    
    var onTap: Delegate<GameRouteTrack, Void> = Delegate()
    
    var playerCompleteAnimated: Delegate<GameResult, Void> = Delegate()
    
    init(service: GameService, frame: CGRect = .zero) {
        self.serivce = service
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        self.addSubview(ladderView)
        self.addSubview(markerView)
        self.addSubview(routeView)
        self.addSubview(playerView)
        self.addSubview(rewardView)
        
        self.playerView.translatesAutoresizingMaskIntoConstraints = false
        self.playerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.playerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.playerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.playerView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        self.playerView.backgroundColor = .white
        
        self.serivce.players.map {
            let v = IconView(item: $0)
            v.foregroundColor = $0.displayColor
            v.onTouchUpInside.delegate(on: self) { (self, item) in
                self.animateRoute(from: item)
            }
            return v
        }.forEach(self.playerView.addSubview)

        
        self.rewardView.translatesAutoresizingMaskIntoConstraints = false
        self.rewardView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.rewardView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.rewardView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.rewardView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        self.rewardView.backgroundColor = .white
        
        self.serivce.rewards.map {
            let v = IconView(item: $0)
            v.foregroundColor = $0.displayColor
            v.onTouchUpInside.delegate(on: self) { (self, item) in
                self.animateBackwardRoute(from: item)
            }
            return v
        }.forEach(self.rewardView.addSubview)
        
        self.routeLayers = [CAShapeLayer](repeating: CAShapeLayer(), count: self.serivce.players.count)
        self.reversedLayers = [CAShapeLayer](repeating: CAShapeLayer(), count: self.serivce.players.count)
        self.markerLayers = [CAShapeLayer](repeating: CAShapeLayer(), count: self.serivce.players.count)
        self.reversedMarkers = [CAShapeLayer](repeating: CAShapeLayer(), count: self.serivce.players.count)
        
        self.bringSubviewToFront(self.playerView)
        self.bringSubviewToFront(self.rewardView)
        
        self.routeView.backgroundColor = UIColor.clear
        self.markerView.backgroundColor = UIColor.clear
        
        self.ladderView.onRenderComplete.delegate(on: self) { (self, intersections) in
            self.rewardView.positions = self.ladderView.endLocations
            self.playerView.positions = self.ladderView.startLocations
            
            self.calculateRoutings(from: intersections)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        self.ladderView.frame = CGRect(x: 32,
                                       y: playerView.frame.maxY,
                                       width: self.frame.width - 64,
                                       height: frame.size.height - playerView.frame.height - rewardView.frame.height)
        
        self.markerView.frame = self.ladderView.frame
        self.routeView.frame = self.ladderView.frame
    }
    
    private var playerRoutes: [Player: [CGPoint]] = [:]
    private var endLocationY: CGFloat {
        return self.ladderView.endLocations[0].y
    }
    private func calculateRoutings(from intersetions: [IntersectionPoint]) {
        for player in self.serivce.players {
            calculateRouting(player, for: intersetions)
        }
    }
    
    private func calculateRouting(_ player: Player, for routes: [IntersectionPoint]) {
        
        var playerRoutes = self.playerRoutes[player] ?? []
        
        let startLocation = playerRoutes.last ?? self.getPlayerStartLocation(player)
        
        if startLocation.y >= endLocationY {
            // Calculate done
            // let drawing route
            self.drawingRoute(player)
            
            return
        }
        
        let possibleRoutes = self.calculatePossibleRoutes(by: routes, from: startLocation)
        
        if let point = possibleRoutes.first {
            
            playerRoutes.append(point.from)
            playerRoutes.append(point.to)
            self.apply(player, routes: playerRoutes)
        }
        
        else {
            
            playerRoutes.append(CGPoint(x: startLocation.x, y: endLocationY))
            self.apply(player, routes: playerRoutes)
        }
        
        self.calculateRouting(player, for: routes)
    }
    
    private func calculatePossibleRoutes(by routes: [IntersectionPoint], from point: CGPoint) -> [IntersectionPoint] {
        routes
            .filter({ $0.from.x == point.x && $0.to.y > point.y })
            .sorted(by: { $0.from.y < $1.from.y })
    }
    
    private func apply(_ player: Player, routes: [CGPoint]) {
        self.playerRoutes[player] = routes
        
        if let last = routes.last, last.y >= endLocationY {
           
            if let index = self.ladderView.endLocations.firstIndex(of: last) {
                self.serivce.rewardIndexReferenceFromPlayer[player] = index
                
                let reward = self.serivce.rewards[index]
                self.serivce.playerIndexReferenceFromReward[reward] = self.serivce.players.firstIndex(of: player)
            }
            
        }
    }
    
    private func drawingRoute(_ player: Player) {
        guard
            let routes = self.playerRoutes[player]
        else {
            return
        }
        
        let playerIndex = self.serivce.players.firstIndex(of: player) ?? 0
        let rewardIndex = self.serivce.rewardIndexReferenceFromPlayer[player] ?? 0
        let startLocation = self.getPlayerStartLocation(player)
        let routeLayer = CAShapeLayer()
        routeLayer.path = self.createRoutePath(from: routes, beginAt: startLocation).cgPath
        routeLayer.lineWidth = 2
        routeLayer.fillColor = nil
        routeLayer.strokeColor = nil
        routeLayer.zPosition = 1
        
        let markers = CAShapeLayer()
        markers.frame = CGRect(x: 0, y: 0, width: 12, height: 12)
        markers.backgroundColor = player.displayColor.cgColor
        markers.cornerRadius = 6
        markers.fillColor = nil
        markers.strokeColor = nil
        markers.position = CGPoint(x: startLocation.x, y: startLocation.y - 12)
        
        self.markerView.layer.addSublayer(markers)
        self.routeView.layer.addSublayer(routeLayer)
        
        self.markerLayers[playerIndex] = markers
        self.routeLayers[playerIndex] = routeLayer
        
        let reseversedLayer = CAShapeLayer()
        reseversedLayer.path = self.createReversedRoutePath(from: routes, beginAt: startLocation).cgPath
        reseversedLayer.lineWidth = 2
        reseversedLayer.fillColor = nil
        reseversedLayer.strokeColor = nil
        reseversedLayer.zPosition = 1
        
        
        let reversedMarker = CAShapeLayer()
        reversedMarker.frame = CGRect(x: 0, y: 0, width: 12, height: 12)
        reversedMarker.backgroundColor = player.displayColor.cgColor
        reversedMarker.cornerRadius = 6
        reversedMarker.fillColor = nil
        reversedMarker.strokeColor = nil
        reversedMarker.position = CGPoint(x: startLocation.x, y: endLocationY + 12)
        
        self.routeView.layer.addSublayer(reseversedLayer)
        self.markerView.layer.addSublayer(reversedMarker)
        
        self.reversedMarkers[rewardIndex] = reversedMarker
        self.reversedLayers[rewardIndex] = reseversedLayer
    }
    
    private func getPlayerStartLocation(_ player: Player) -> CGPoint {
        
        guard let index = self.serivce.players.firstIndex(of: player) else {
            return .zero
        }
        
        return ladderView.startLocations[index]
    }
    
    private func animateBackwardRoute(from item: ItemHashable) {
        
        guard
            let indexToAnimate = self.serivce.rewards.firstIndex(where: { $0.id == item.id })
        else {
            return
        }
        
        self.routeLayers.forEach { routeLayer in
            routeLayer.strokeColor = nil
            routeLayer.speed = 0
            routeLayer.removeAllAnimations()
            routeLayer.zPosition = 0
        }
        
        self.markerLayers.forEach { layer in
            layer.backgroundColor = nil
        }
        
        for (index, routeLayer) in reversedLayers.enumerated() {
            
            let marker = reversedMarkers[index]
            let reward = self.serivce.rewards[indexToAnimate]
            let referencePlayerIndex = self.serivce.playerIndexReferenceFromReward[reward] ?? 0
            
            if indexToAnimate == index {
                
                routeLayer.strokeColor = self.serivce.players[referencePlayerIndex].displayColor.cgColor
                routeLayer.zPosition = 1
                routeLayer.speed = 1
                routeLayer.removeAllAnimations()

                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue = 0
                animation.toValue = 1
                animation.duration = 2
                animation.delegate = self
                animation.setValue(routeLayer, forKey: "reversedRouteLayer")
                routeLayer.add(animation, forKey: "reversedLayer")
                
                let moveAnimation = CAKeyframeAnimation(keyPath: "position")
                moveAnimation.path = routeLayer.path
                moveAnimation.duration = 2
                moveAnimation.calculationMode = CAAnimationCalculationMode.paced
                moveAnimation.delegate = self
                moveAnimation.setValue(marker, forKey: "reversedMarkerLayer")
                marker.add(moveAnimation, forKey: "reversedMoveAnimation")
            }
            else {
                routeLayer.strokeColor = nil //UIColor.clear.cgColor
                routeLayer.speed = 0
                routeLayer.removeAllAnimations()
                routeLayer.zPosition = 0
                
                marker.backgroundColor = nil
            }
        }
    }
    
    private func animateRoute(from item: ItemHashable) {

        guard
            let indexToAnimate = self.serivce.players.firstIndex(where: { $0.id == item.id })
        else {
            return
        }
        
        self.reversedMarkers.forEach { layer in
            layer.backgroundColor = nil
        }
        
        self.reversedLayers.forEach { routeLayer in
            routeLayer.strokeColor = nil
            routeLayer.speed = 0
            routeLayer.removeAllAnimations()
            routeLayer.zPosition = 0
        }
        
        let player = self.serivce.players[indexToAnimate]
        if let route = self.playerRoutes[player] {
            onTap((player, route))
        }
        
        for (index, routeLayer) in routeLayers.enumerated() {
            
            let marker = markerLayers[index]

            if indexToAnimate == index {

                routeLayer.strokeColor = item.displayColor.cgColor
                routeLayer.zPosition = 1
                routeLayer.speed = 1
                routeLayer.removeAllAnimations()

                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue = 0
                animation.toValue = 1
                animation.duration = 2
                animation.delegate = self
                animation.setValue(routeLayer, forKey: "routeLayer")
                routeLayer.add(animation, forKey: "layer")
                
                let moveAnimation = CAKeyframeAnimation(keyPath: "position")
                moveAnimation.path = routeLayer.path
                moveAnimation.duration = 2
                moveAnimation.calculationMode = CAAnimationCalculationMode.paced
                moveAnimation.delegate = self
                moveAnimation.setValue(marker, forKey: "markerLayer")
                marker.add(moveAnimation, forKey: "moveAnimation")
            }

            else {
                routeLayer.strokeColor = nil //UIColor.clear.cgColor
                routeLayer.speed = 0
                routeLayer.removeAllAnimations()
                routeLayer.zPosition = 0
                
                marker.backgroundColor = nil
            }
        }

    }
    
    private func createRoutePath(from route: [CGPoint], beginAt start: CGPoint) -> UIBezierPath {
        
        let path = UIBezierPath()
        
        path.move(to: start)
        
        for route in route {
            path.addLine(to: route)
        }
        
        path.stroke()
        
        return path
    }
    
    private func createReversedRoutePath(from routes: [CGPoint], beginAt start: CGPoint) -> UIBezierPath {
        
        let path = UIBezierPath()
        
        var r = routes
        let s = r.removeLast()
        
        r.insert(start, at: 0)
        
        path.move(to: s)
        
        for _r in r.reversed() {
            path.addLine(to: _r)
        }
        
        path.stroke()
        
        return path
    }
    
}

extension GameView: CAAnimationDelegate {
    
    func animationDidStart(_ anim: CAAnimation) {
        
        self.routeLayerDidStartAnimate(anim)
        self.markerLayerDidStartAnimate(anim)
        self.reversedLayerDidStartAnimate(anim)
        self.reversedMarkerLayerDidStartAnimate(anim)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        self.routeLayerDidStopAnimate(anim, isComplete: flag)
        self.markerLayerDidStopAnimate(anim, isComplete: flag)
        self.reversedLayerDidStopAnimation(anim, isComplete: flag)
        self.reversedMarkerLayerDidStopAnimate(anim, isComplete: flag)
    }
    
    private func routeLayerDidStartAnimate(_ anim: CAAnimation) {
        guard
            let routeLayer = anim.value(forKey: "routeLayer") as? CAShapeLayer,
            let layerIndex = self.routeLayers.firstIndex(of: routeLayer)
        else {
            return
        }
        
        for (iconIndex, playerIcon) in self.playerView.subviews.enumerated() {
            let iconView = playerIcon as! IconView
            
            iconView.foregroundColor = self.serivce.players[iconIndex].displayColor 
            
            iconView.updateState(iconIndex == layerIndex)
        }
        
        
        for playerIcon in self.rewardView.subviews {
            let iconView = playerIcon as! IconView
            
            iconView.updateState(false)
        }
        
    }
    
    private func routeLayerDidStopAnimate(_ anim: CAAnimation, isComplete: Bool) {
        guard
            let routeLayer = anim.value(forKey: "routeLayer") as? CAShapeLayer,
            let layerIndex = self.routeLayers.firstIndex(of: routeLayer)
        else {
            return
        }
        
        let player = self.serivce.players[layerIndex]
        let playerRewardIndex = self.serivce.rewardIndexReferenceFromPlayer[player] ?? 0
        
        for (iconIndex, playerIcon) in self.rewardView.subviews.enumerated() {
            let iconView = playerIcon as! IconView
            iconView.foregroundColor = player.displayColor
            
            if isComplete {
                
                iconView.updateState(iconIndex == playerRewardIndex)
                
            }
        }
        
        if isComplete {
            
            self.playerCompleteAnimated((player, self.serivce.rewards[playerRewardIndex]))
        }
        
    }
    
    private func reversedLayerDidStartAnimate(_ anim: CAAnimation) {
        guard
            let layer = anim.value(forKey: "reversedRouteLayer") as? CAShapeLayer,
            let layerIndex = self.reversedLayers.firstIndex(of: layer)
        else {
            return
        }
        
        let reward = self.serivce.rewards[layerIndex]
        let referencePlayerIndex = self.serivce.playerIndexReferenceFromReward[reward] ?? 0
        
        for playerIcon in self.playerView.subviews {
            let iconView = playerIcon as! IconView
            
            iconView.updateState(false)
        }
        
        for (iconIndex, rewardIcon) in self.rewardView.subviews.enumerated() {
            let iconView = rewardIcon as! IconView
            
            iconView.foregroundColor = self.serivce.players[referencePlayerIndex].displayColor
            
            iconView.updateState(iconIndex == layerIndex)
        }
    }
    
    private func reversedLayerDidStopAnimation(_ anim: CAAnimation, isComplete: Bool) {
        guard
            let layer = anim.value(forKey: "reversedRouteLayer") as? CAShapeLayer,
            let layerIndex = self.reversedLayers.firstIndex(of: layer)
        else {
            return
        }
        
        let reward = self.serivce.rewards[layerIndex]
        let playerIndex = self.serivce.playerIndexReferenceFromReward[reward] ?? 0
        
        for (iconIndex, playerIcon) in self.playerView.subviews.enumerated() {
            let iconView = playerIcon as! IconView
            iconView.foregroundColor = self.serivce.players[playerIndex].displayColor
            
            if isComplete {
                iconView.updateState(iconIndex == playerIndex)
            }
        }
        
        if isComplete {
            
            self.playerCompleteAnimated((self.serivce.players[playerIndex], reward))
        }
    }
    
    private func markerLayerDidStartAnimate(_ anim: CAAnimation) {
        guard
            let markerLayer = anim.value(forKey: "markerLayer") as? CAShapeLayer,
            let layerIndex = self.markerLayers.firstIndex(of: markerLayer)
        else {
            return
        }
        
        let player = self.serivce.players[layerIndex]
        
        markerLayer.backgroundColor = player.displayColor.cgColor
    }
    
    private func markerLayerDidStopAnimate(_ anim: CAAnimation, isComplete: Bool) {
        guard
            let markerLayer = anim.value(forKey: "markerLayer") as? CAShapeLayer
        else {
            return
        }
        if isComplete {
            
            markerLayer.backgroundColor = nil

        }
    }
    
    private func reversedMarkerLayerDidStartAnimate(_ anim: CAAnimation) {
        guard
            let markerLayer = anim.value(forKey: "reversedMarkerLayer") as? CAShapeLayer,
            let layerIndex = self.reversedMarkers.firstIndex(of: markerLayer)
        else {
            return
        }
        
        let reward = self.serivce.rewards[layerIndex]
        let referencePlayerIndex = self.serivce.playerIndexReferenceFromReward[reward] ?? 0
        
        markerLayer.backgroundColor = self.serivce.players[referencePlayerIndex].displayColor.cgColor
    }
    
    private func reversedMarkerLayerDidStopAnimate(_ anim: CAAnimation, isComplete: Bool) {
        guard
            let markerLayer = anim.value(forKey: "reversedMarkerLayer") as? CAShapeLayer
        else {
            return
        }
        if isComplete {
            
            markerLayer.backgroundColor = nil

        }
    }
}

extension UIColor {
    
    static var randomColor: UIColor {
        return UIColor(red: CGFloat.random(in: 0...1),
                       green: CGFloat.random(in: 0...1),
                       blue: CGFloat.random(in: 0...1),
                       alpha: 1)
    }
    
}
