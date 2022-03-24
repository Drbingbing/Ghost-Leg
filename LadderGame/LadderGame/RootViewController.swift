//
//  RootViewController.swift
//  LadderGame
//
//  Created by Bing Bing on 2022/3/21.
//

import Foundation
import UIKit

class RootViewController: UIViewController {
    
    var dataSource: [PlayerItem] = [] {
        didSet {
            self.updateBanner()
            self.updatePlayButton()
        }
    }
    
    let tableView = UITableView()
    
    let banner = UILabel()
    
    let playButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(tableView)
        self.view.addSubview(banner)
        self.view.addSubview(playButton)
        
        self.navigationItem.title = "爬梯子"
        
        self.banner.numberOfLines = 0
        
        self.playButton.isEnabled = false
        self.playButton.setTitle("下一步  >", for: .normal)
        self.playButton.setTitle("下一步  >", for: .disabled)
        self.playButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        self.playButton.setTitleColor(.black, for: .normal)
        self.playButton.setTitleColor(.lightGray, for: .disabled)
        self.playButton.addTarget(self, action: #selector(self.nextStep), for: .touchUpInside)
        
        self.dataSource = [PlayerItem()]
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
        
        let players = self.dataSource.compactMap { item -> Player? in
            if let player = item.player {
                return Player(name: player.name, image: nil, presentedColor: item.color)
            }
            return nil
        }
        
        let gameService = GameService(players: players)
        
        let gameRewardController = GameRewardViewController(gameService: gameService)
        
        self.navigationController?.pushViewController(gameRewardController, animated: true)
    }
    
    func updateBanner() {
        
        let totalPlayers = self.dataSource
            .compactMap{ $0.player }
            .count
        
        let string = NSMutableAttributedString(
            string: "參與人數：\(totalPlayers)\n",
            attributes: [.foregroundColor: UIColor.black,
                         .font: UIFont.systemFont(ofSize: 32, weight: .bold)]
        )
        
        let subtitle = NSAttributedString(
            string: "如果參與人數超過30人，系統只會顯示最終將果",
            attributes: [.foregroundColor: UIColor.lightGray,
                         .font: UIFont.systemFont(ofSize: 14)]
        )
        
        string.append(subtitle)
        
        self.banner.attributedText = string
    }
    
    func updatePlayButton() {
        self.playButton.isEnabled = self.dataSource.compactMap(\.player).count >= 2
    }
    
    private func updateSection(_ cell: TextFieldCell) {
        if let text = cell.textField.text,
           let indexPath = self.tableView.indexPath(for: cell),
           !text.isEmpty {
            
            let item = self.dataSource[indexPath.section]
            item.player = Player(name: text, image: nil)
            
            if let last = self.dataSource.last, last.player != nil, self.dataSource.count < 30 {
                let newItem = PlayerItem()
                self.dataSource.append(newItem)
                
                self.tableView.insertSections([self.dataSource.count - 1], with: .fade)
            }
        }
        else {
            // delete last section if needed
            if let last = self.dataSource.last,
               last.player == nil,
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

extension RootViewController: UITableViewDataSource {
    
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
        cell.textField.placeholder = "新增參與者"
        cell.textField.text = item.player?.name
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

extension RootViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let item = self.dataSource[indexPath.section]
        
        return item.player != nil
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "刪除") { [weak self] action, contextView, block in
            guard let self = self else { return }
            
            self.dataSource.remove(at: indexPath.section)
            tableView.deleteSections([indexPath.section], with: .fade)
            
            if self.dataSource.last?.player != nil {
                self.dataSource.append(PlayerItem())
            }
            
            tableView.reloadData()
            
            block(true)
        }
        
        return UISwipeActionsConfiguration(
            actions: [delete]
        )
        
    }
}
