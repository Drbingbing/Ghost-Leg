//
//  CongratulationViewController.swift
//  LadderGame
//
//  Created by Bing Bing on 2022/3/24.
//

import UIKit

class CongratulationViewController: UIViewController {
    
    var player: Player!
    var reward: Reward!
    
    let conffettiView = ConfettiView()
    lazy var playerIconView = IconView(item: self.player)
    let label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(conffettiView)
        self.view.addSubview(self.playerIconView)
        self.view.addSubview(self.label)
        
        self.playerIconView.foregroundColor = self.player.displayColor
        self.playerIconView.updateState(true)
        self.label.text = reward.title
        self.label.textColor = reward.displayColor
        self.label.textAlignment = .center
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.conffettiView.frame = self.view.frame
        self.playerIconView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        self.playerIconView.center = self.view.center
        self.label.frame = CGRect(x: 0, y: 0, width: 100, height: 24)
        self.label.numberOfLines = 0
        self.label.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 64)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.conffettiView.startConfetti()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
