//
//  GameRewardViewController.swift
//  LadderGame
//
//  Created by Bing Bing on 2022/3/23.
//

import UIKit

class GameRewardViewController: UIViewController {

    var dataSource: [RewardItem] = [] {
        didSet {
            self.updatePlayButton()
        }
    }
    
    let tableView = UITableView()
    
    let banner = UILabel()
    
    let playButton = UIButton(type: .system)
    
    let gameService: GameService
    
    init(gameService: GameService) {
        self.gameService = gameService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        self.view.addSubview(tableView)
        self.view.addSubview(banner)
        self.view.addSubview(playButton)
        
        self.navigationItem.title = "爬梯子"
        
        self.banner.numberOfLines = 0
        self.updateBanner()
        
        self.playButton.isEnabled = false
        self.playButton.setTitle("開始  >", for: .normal)
        self.playButton.setTitle("開始  >", for: .disabled)
        self.playButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        self.playButton.setTitleColor(.black, for: .normal)
        self.playButton.setTitleColor(.lightGray, for: .disabled)
        self.playButton.addTarget(self, action: #selector(self.nextStep), for: .touchUpInside)
        
        self.dataSource = [RewardItem()]
        self.tableView.dataSource = self
        self.tableView.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(endTextFieldInput))
        self.tableView.addGestureRecognizer(tap)
        self.tableView.separatorStyle = .none
        self.tableView.register(TextFieldCell.nib, forCellReuseIdentifier: TextFieldCell.reuseID)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.banner.frame = CGRect(x: 20, y: self.view.safeAreaInsets.top, width: self.view.frame.width, height: 64)
        self.tableView.frame = CGRect(x: 0, y: self.banner.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - 64)
        
        self.playButton.frame = CGRect(x: self.view.frame.width - 100, y: self.view.frame.height - view.safeAreaInsets.bottom - 48, width: 88, height: 32)
    }
    
    @objc
    private func endTextFieldInput(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc
    private func nextStep(_ sender: UIButton) {
        
        let rewards = self.dataSource.compactMap { item -> Reward? in
            
            if let reward = item.reward {
                return Reward(object: reward.object, presentedColor: randomColor(luminosity: .dark))
            }
            
            return nil
        }
        
        self.gameService.prepare()
        self.gameService.setReward(rewards)
        let gameController = GameViewController(gameService: self.gameService)
        
        self.navigationController?.pushViewController(gameController, animated: true)
    }
    
    func updateBanner() {
        
        let string = NSMutableAttributedString(
            string: "輸入抽籤選項\n",
            attributes: [.foregroundColor: UIColor.black,
                         .font: UIFont.systemFont(ofSize: 32, weight: .bold)]
        )
        
        let subtitle = NSAttributedString(
            string: "空白選項將顯示「槓龜」",
            attributes: [.foregroundColor: UIColor.lightGray,
                         .font: UIFont.systemFont(ofSize: 14)]
        )
        
        string.append(subtitle)
        
        self.banner.attributedText = string
    }
    
    func updatePlayButton() {
        self.playButton.isEnabled = !self.dataSource.compactMap(\.reward).isEmpty 
    }
    
    private func updateSection(_ cell: TextFieldCell) {
        if let text = cell.textField.text,
           let indexPath = self.tableView.indexPath(for: cell),
           !text.isEmpty {
            
            let item = self.dataSource[indexPath.section]
            item.reward = Reward(object: text)
            
            if let last = self.dataSource.last, last.reward != nil,
               self.dataSource.count < self.gameService.players.count {
                let newItem = RewardItem()
                self.dataSource.append(newItem)
                
                self.tableView.insertSections([self.dataSource.count - 1], with: .fade)
            }
        }
        else {
            // delete last section if needed
            if let last = self.dataSource.last,
               last.reward == nil,
               self.dataSource.count >= 2 {
                
                self.dataSource.removeLast()
                
                self.tableView.deleteSections([self.dataSource.count], with: .fade)
            }
        }
    }
    
    private func shouldGoNextTextField(from cell: TextFieldCell) {
        guard
            let indexPath = self.tableView.indexPath(for: cell)
        else {
            return
        }
        
        let nextIndex = IndexPath(row: indexPath.row, section: indexPath.section + 1)
        if let nextCell = tableView.cellForRow(at: nextIndex) as? TextFieldCell {
            nextCell.textField.becomeFirstResponder()
        }
    }
}

extension GameRewardViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseID, for: indexPath) as! TextFieldCell
        
        let item = self.dataSource[indexPath.section]
        
        cell.numberLabel.text = String(indexPath.section + 1)
        cell.textField.placeholder = "新增選項"
        cell.textField.text = item.reward?.object
        cell.textField.textColor = item.color
        
        cell.onBeginEditing.delegate(on: self) { (self, view) in
            self.adjustInsetWhileEditing(true, cell: view)
        }
        
        cell.onCompleteInput.delegate(on: self) { (self, view) in
            self.adjustInsetWhileEditing(false, cell: view)
        }
        cell.onTextFieldEditing.delegate(on: self) { (self, view) in
            self.updateSection(view)
        }
        
        cell.onTextFieldReturnKey.delegate(on: self) { (self, view) in
            self.shouldGoNextTextField(from: view)
        }
        
        
        
        return cell
    }
    
    private func adjustInsetWhileEditing(_ isEditing: Bool, cell: UITableViewCell) {
        
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: isEditing ? self.view.frame.height / 2 : 0, right: 0)
        
        if let indexPath = self.tableView.indexPath(for: cell) {
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}

extension GameRewardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let item = self.dataSource[indexPath.section]
        
        return item.reward != nil
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "刪除") { [weak self] action, contextView, block in
            guard let self = self else { return }
            
            self.dataSource.remove(at: indexPath.section)
            tableView.deleteSections([indexPath.section], with: .fade)
            
            if self.dataSource.last?.reward != nil {
                self.dataSource.append(RewardItem())
            }
            
            tableView.reloadData()
            
            
            block(true)
        }
        
        return UISwipeActionsConfiguration(
            actions: [delete]
        )
        
    }
}
