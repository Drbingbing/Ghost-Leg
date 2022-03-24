//
//  TextFieldCell.swift
//  LadderGame
//
//  Created by Bing Bing on 2022/3/23.
//

import UIKit

class TextFieldCell: UITableViewCell {
    
    static let nib = UINib(nibName: "TextFieldCell", bundle: nil)
    static let reuseID = "TextFieldCell"
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    var onCompleteInput: Delegate<TextFieldCell, Void> = Delegate()
    
    var onTextFieldEditing: Delegate<TextFieldCell, Void> = Delegate()
    
    var onBeginEditing: Delegate<TextFieldCell, Void> = Delegate()
    
    var onTextFieldReturnKey: Delegate<TextFieldCell, Void> = Delegate()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .none
        self.textField.delegate = self
        self.textField.returnKeyType = .next
        self.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc func textDidChange(_ textField: UITextField) {
        onTextFieldEditing(self)
    }
}

extension TextFieldCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onTextFieldReturnKey(self)
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        onCompleteInput(self)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        onBeginEditing(self)
    }
}
