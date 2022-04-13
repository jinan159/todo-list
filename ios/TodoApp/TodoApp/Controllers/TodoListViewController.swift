//
//  TodoListViewController.swift
//  TodoApp
//
//  Created by 송태환 on 2022/04/04.
//

import UIKit
import OSLog

class TodoListViewController: UIViewController {
    // TODO: Todo 모델 정의 & 소유
    
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet private weak var badgeView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var addToDoButton: UIButton!
    
    // Temporary usage, must be removed in the future
    private var viewModel = Array(repeating: 0, count: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.addDelegates()
    }
    
    private func addDelegates() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    private func configureUI() {
        self.badgeLabel?.text = String(self.viewModel.count)
        self.badgeView.clipsToBounds = true
        self.badgeView.layer.cornerRadius = self.badgeView.frame.size.height / 2
        
        self.addToDoButton.addAction(UIAction(handler: self.editCard(_:)), for: .touchUpInside)
    }
    
    private func editCard(_ action: UIAction) {
    }
}

extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.identifier) as? TodoCell else {
            Logger.view.error("Fail to get a cell instance of TodoCell in \(#function), \(#fileID)")
            fatalError()
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.viewModel.remove(at: indexPath.section)
            self?.badgeLabel?.text = String(self?.viewModel.count ?? 0)
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            completion(true)
        }
        action.image = UIImage(systemName: "trash")
        
        let config = UISwipeActionsConfiguration(actions: [action])
        config.performsFirstActionWithFullSwipe = true
        
        // TODO: Delete 버튼 corner radius 적용
        
        return config
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            self.viewModel.remove(at: indexPath.section)
            self.badgeLabel?.text = String(self.viewModel.count)
            
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil) { _ in
                let move = UIAction(
                    title: "완료한 일로 이동",
                    image: UIImage(systemName: "folder"),
                    state: .off) { _ in
                        // TODO: Post Notification
                    }
                
                let modify = UIAction(
                    title: "수정하기",
                    image: UIImage(systemName: "square.and.pencil"),
                    state: .off) { _ in
                        // TODO: Segue with Todo data
                    }
                
                let delete = UIAction(
                    title: "삭제하기",
                    image: UIImage(systemName: "trash"),
                    attributes: .destructive,
                    state: .off) { _ in
                        self.viewModel.remove(at: indexPath.section)
                        self.badgeLabel?.text = String(self.viewModel.count)
                        tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                    }
                
                return UIMenu(
                    title: "옵션",
                    options: .displayInline,
                    children: [move, modify, delete]
                )
            }
        
        return config
    }
}
