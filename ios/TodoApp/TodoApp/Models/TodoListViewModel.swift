//
//  TodoListViewModel.swift
//  TodoApp
//
//  Created by 송태환 on 2022/04/13.
//

import Foundation

protocol TodoListViewModelProtocol {
    func fetchData()
    func remove(at index: Int)
    func getHeaderTitle() -> String
    var count: Int { get }
}

final class TodoListViewModel: TodoListViewModelProtocol {
    private let repository: TodoRepositoryProtocol
    private let column: Column
    private(set) var models = Observable(value: [Todo]())
    
    var selection: Int?
    
    subscript(index: Int) -> Todo? {
        get {
            guard index < self.models.value.count && index >= self.models.value.startIndex else {
                return nil
            }
            
            return self.models.value[index]
        }
    }
    
    var count: Int {
        return self.models.value.count
    }
    
    init(entity column: Column, repository: TodoRepositoryProtocol) {
        self.column = column
        self.repository = repository
    }
    
    func remove(at index: Int) {
        // TODO: 서버에 삭제 요청
        self.models.value.remove(at: index)
    }
    
    func insert(data: Todo, at index: Int) {
        if self.models.value.isEmpty {
            self.models.value.append(data)
            return
        }
        
        self.models.value.insert(data, at: index)
    }
    
    func fetchData() {
        self.repository.fetchTodo(from: self.column) { [weak self] models in
            DispatchQueue.main.async {
                self?.models.value = models
            }
        }
    }
    
    func getHeaderTitle() -> String {
        return self.column.name
    }
}
