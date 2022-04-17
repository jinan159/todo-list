//
//  TodoListContainerViewModel.swift
//  TodoApp
//
//  Created by 송태환 on 2022/04/16.
//

import Foundation

protocol Performer: AnyObject {
    func reset()
}

class TodoListContainerViewModel {
    private let repository: ColumnRepositoryProtocol
    private(set) var models = Observable(value: [Column]())
    
    var performer: Performer?
    
    init(repository: ColumnRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchData() {
        self.repository.fetchColumn { [weak self] models in
            self?.models.value = models
        }
    }
}
