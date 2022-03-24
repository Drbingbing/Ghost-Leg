//
//  GameViewController.swift
//  LadderGame
//
//  Created by Bing Bing on 2022/3/21.
//

import UIKit

class GameViewController: UIViewController {
    
    private let gameService: GameService
    
    lazy var gameView = GameView(service: gameService)
    let scrollView = UIScrollView()
    
    private var timer: Timer?
    
    init(gameService: GameService) {
        self.gameService = gameService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.timer?.invalidate()
        self.timer = nil
        self.view.backgroundColor = .white
        self.view.addSubview(self.scrollView)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false

        self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        self.scrollView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        self.scrollView.contentSize = self.view.frame.size
        self.scrollView.addSubview(self.gameView)
        self.scrollView.isDirectionalLockEnabled = true
        self.scrollView.delegate = self
        
        
        
        self.gameView.onTap.delegate(on: self) { (self, track) in
            self.startTrack(tracker: track.tracker, routes: track.routes)
        }
        
        self.gameView.playerCompleteAnimated.delegate(on: self) { (self, gameResult) in
            
            self.stopTrack()
            
            let congratulationController = CongratulationViewController()
            congratulationController.player = gameResult.player
            congratulationController.reward = gameResult.reward
            congratulationController.modalTransitionStyle = .crossDissolve
            congratulationController.modalPresentationStyle = .overFullScreen
            congratulationController.view.backgroundColor = .white
            
            self.present(congratulationController, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.dismiss(animated: true)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let playerCount = CGFloat(self.gameService.players.count)
        let totalWidth = playerCount * 80
        self.gameView.frame = CGRect(x: 20, y: 0, width: totalWidth, height: self.view.frame.height - 100 - self.view.safeAreaInsets.bottom)
        self.scrollView.contentSize = CGSize(width: self.gameView.frame.width + 40, height: self.gameView.frame.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func startTrack(tracker: ItemHashable, routes: [CGPoint]) {
        self.timer?.invalidate()
        self.timer = nil
        // Since we have two second duration to display animation
        var timeInterval: TimeInterval = 0.1
        
        let duration: TimeInterval = 2
        
        timeInterval = duration / Double(routes.count)
        
        var offset = routes.startIndex + 2
        let endIndex = routes.endIndex

        self.timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _ in
            
            if offset >= endIndex {
                self.updateScrollOffset(before: routes[endIndex - 2], after: routes[endIndex - 1])
            }
            else {
                self.updateScrollOffset(before: routes[offset - 1], after: routes[offset])
            }
            
            offset += 1
        }
    }
    
    private func stopTrack() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    private func updateScrollOffset(before: CGPoint, after: CGPoint) {
        
        let minOffsetX = CGFloat(0)
        let maxOffsetX = CGFloat(self.gameView.frame.maxX)
        
        let hasChange = abs(before.x - after.x) > 0
        
        if !hasChange { return }
        
        let scrollOffsetX = self.scrollView.contentOffset.x
        
        let width = self.view.frame.width
        let distanceToScrollOffsetX = after.x - scrollOffsetX
        print("scrollOffset x: \(scrollOffsetX)")
        print("distance to scrolloffset x: \(distanceToScrollOffsetX)")
        
        if distanceToScrollOffsetX < 0 {
            
            let delta = (scrollOffsetX + distanceToScrollOffsetX) < minOffsetX ? minOffsetX : (scrollOffsetX + distanceToScrollOffsetX)
            print("should scroll, recommend adjusted offset: \(scrollOffsetX - after.x)")
            
            let newOffset = CGPoint(x: delta, y: self.scrollView.contentOffset.y)
            
            self.scrollView.setContentOffset(newOffset, animated: true)
        }
        
        else if distanceToScrollOffsetX - scrollOffsetX > width * 0.8 {
            
            if after.x > scrollOffsetX {
                
                let delta = (after.x + scrollOffsetX) * 0.6 > maxOffsetX ? maxOffsetX : (after.x + scrollOffsetX) * 0.6
                print("should scroll, recommend adjusted offset: \(delta)")
                
                let newOffset = CGPoint(x: scrollOffsetX + delta, y: self.scrollView.contentOffset.y)
                
                self.scrollView.setContentOffset(newOffset, animated: true)
                
            }
        }
    }
}

extension GameViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.gameView
    }
}
