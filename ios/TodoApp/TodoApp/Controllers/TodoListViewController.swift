//
//  TodoListViewController.swift
//  TodoApp
//
//  Created by 송태환 on 2022/04/04.
//

import UIKit
import OSLog

protocol TodoListViewControllerDelegate {
    func didStartDragging(from performer: TodoListViewController)
    func didEndDropping()
}

class TodoListViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet private weak var badgeView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    
    // TODO: 커스텀 생성자(NSCoder) 만들어서 주입하기
    var viewModel: TodoListViewModel?
    var delegate: TodoListViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.addDelegates()
        self.bind()
        
        self.viewModel?.fetchData()
    }
    
    private func bind() {
        self.viewModel?.models.bind { [weak self] models in
            self?.badgeLabel?.text = String(self?.viewModel?.count ?? .zero)
            // 최적화 필요
            self?.tableView.reloadData()
        }
    }
    
    private func addDelegates() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    
    private func configureUI() {
        self.titleLabel?.text = self.viewModel?.getHeaderTitle()
        self.badgeLabel?.text = String(self.viewModel?.count ?? .zero)
        
        self.badgeView.clipsToBounds = true
        self.badgeView.layer.cornerRadius = self.badgeView.frame.size.height / 2
    }
    
    func reset() {
        guard let section = self.viewModel?.selection else { return }
        self.tableView.deleteSections(IndexSet(integer: section), with: .automatic)
    }
}

extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.identifier) as? TodoCell else {
            Logger.view.error("Fail to get a cell instance of TodoCell in \(#function), \(#fileID)")
            fatalError()
        }
        
        guard let model = self.viewModel?[indexPath.section] else {
            return cell
        }
        
        cell.setTitle(text: model.title)
        cell.setContent(text: model.content)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel?.count ?? .zero
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .zero
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}

extension TodoListViewController: UITableViewDelegate {
    // MARK: - Swipe to delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.viewModel?.remove(at: indexPath.section)
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
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil) { [weak self] _ in
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
                        guard let self = self else { return }
                        self.viewModel?.remove(at: indexPath.section)
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

extension TodoListViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let model = self.viewModel?[indexPath.section] else {
            fatalError()
        }
        
        self.viewModel?.selection = indexPath.section
        
        let itemProvider = NSItemProvider()
        let item = UIDragItem(itemProvider: itemProvider)
        item.localObject = model
        
        return [item]
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.items.count == 1
    }
    
    func tableView(_ tableView: UITableView, dragSessionWillBegin session: UIDragSession) {
        // delegate 호출
        self.delegate?.didStartDragging(from: self)
    }
}

extension TodoListViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        var dropProposal = UITableViewDropProposal(operation: .cancel)
        
        guard session.items.count == 1 else { return dropProposal }
        
        if tableView.hasActiveDrag {
            dropProposal = UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            dropProposal = UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
        
        return dropProposal
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = tableView.numberOfSections == .zero ? .zero : tableView.numberOfSections - 1
            let row = max(tableView.numberOfRows(inSection: section), 1)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        guard let item = coordinator.session.items.first else { return }
        guard let model = item.localObject as? Todo else { return }
        
        self.viewModel?.insert(data: model, at: destinationIndexPath.section)
        self.tableView.insertRows(at: [destinationIndexPath], with: .automatic)
        self.delegate?.didEndDropping()
    }
}
