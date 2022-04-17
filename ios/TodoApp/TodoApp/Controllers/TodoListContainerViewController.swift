//
//  ViewController.swift
//  TodoApp
//
//  Created by 송태환 on 2022/04/04.
//

import UIKit

class TodoListContainerViewController: UIViewController {
    // MARK: -  Properties
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var menuButton: UIButton!
    @IBOutlet private weak var drawerView: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var columnStack: UIStackView!
    
    var viewControllers = [UIViewController]() {
        didSet {
            self.configureColumns()
        }
    }
    
    var viewModel: TodoListContainerViewModel?
    
    // MARK: -  Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.bind()
        self.viewModel?.fetchData()
    }

    // MARK: - UI Configuration
    private func configureColumns() {
        guard self.viewControllers.count != 0 else { return }
        
        for viewController in self.viewControllers {
            self.addChild(viewController)
            self.columnStack.addArrangedSubview(viewController.view)
        }
        
        // TODO: 새 컬럼 추가하는 View 만들기
        self.columnStack.addArrangedSubview(UIView())
    }
    
    private func configureUI() {
        self.drawerView.frame.origin.x = self.view.frame.maxX
        self.menuButton.addAction(UIAction(handler: self.toggleMenuButton(_:)), for: .touchUpInside)
        self.closeButton.addAction(UIAction(handler: self.toggleMenuButton(_:)), for: .touchUpInside)
    }
    
    private func toggleMenuButton(_ action: UIAction) {
        let x = self.drawerView.frame.origin.x
        let width = self.drawerView.frame.width
        var point = CGPoint(x: self.drawerView.frame.origin.x, y: 0)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            if x == self.view.frame.width {
                point.x = x - width
            } else {
                point.x = x + width
            }

            self.drawerView.frame.origin = point
        }
    }
    
    private func bind() {
        self.viewModel?.models.bind(listener: { [weak self] columns in
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "TodoListViewController", bundle: nil)
                
                let viewControllers: [TodoListViewController] = columns.compactMap({ column in
                    guard let todoListViewController = storyboard.instantiateInitialViewController() as? TodoListViewController else { return nil }
                    
                    let repository = TodoRepository()
                    let viewModel = TodoListViewModel(entity: column, repository: repository)
                    todoListViewController.viewModel = viewModel
                    
                    return todoListViewController
                })
                
                self?.viewControllers = viewControllers
            }
        })
    }
}

extension TodoListContainerViewController: TodoListViewControllerDelegate {
    func didStartDragging(from performer: TodoListViewController) {
        guard let performer = performer as? Performer else { return }
        self.viewModel?.performer = performer
    }
    
    func didEndDropping() {
        guard let performer = self.viewModel?.performer as? TodoListViewController else { return }
        performer.reset()
        
        self.viewModel?.performer = nil
    }
}
