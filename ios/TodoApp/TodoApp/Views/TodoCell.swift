//
//  ToDoCell.swift
//  TodoApp
//
//  Created by YEONGJIN JANG on 2022/04/07.
//

import UIKit

class TodoCell: UITableViewCell {
    static let identifier = "TodoCell"
    
    @IBOutlet private weak var cardView: UIView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureUI()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func configureUI() {
        self.contentView.layer.cornerRadius = 10
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerCurve = .continuous
    }
    
}
