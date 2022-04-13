//
//  TodoRepository.swift
//  TodoApp
//
//  Created by 송태환 on 2022/04/13.
//

import Foundation

protocol TodoRepositoryProtocol {
    func fetchTodo(_ completion: @escaping([Todo]) -> Void)
    func createTodo(with data: Any, _ completion: @escaping(Todo) -> Void)
    func moveTodo(with data: Todo, _ completion: @escaping(Todo) -> Void)
    func deleteTodo(with data: Todo, _ completion: @escaping(Bool) -> Void)
    func updateTodo(with data: Todo, _ completion: @escaping(Bool) -> Void)
}

class TodoRepository: TodoRepositoryProtocol {
    func createTodo(with data: Any, _ completion: @escaping (Todo) -> Void) {
        var request = URLRequest(url: API.baseURL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(
            withJSONObject: [
                "columnId": "data.id",
                "title": "data.id",
                "content": "data.id"
            ]
        )
        
        URLSession.shared.dataTask(with: API.baseURL) { data, response, error in
            guard let data = data, error == nil else {
                // TODO: response error handling
                return
            }
            
            guard let model = try? JSONDecoder().decode(Todo.self, from: data) else { return }
            completion(model)
        }.resume()
    }
    
    func fetchTodo(_ completion: @escaping([Todo])  -> Void) {
        URLSession.shared.dataTask(with: API.baseURL) { data, response, error in
            guard let data = data, error == nil else {
                // TODO: response error handling
                return
            }
            
            guard let models = try? JSONDecoder().decode([Todo].self, from: data) else { return }
            completion(models)
        }.resume()
    }
    
    func moveTodo(with data: Todo, _ completion: @escaping (Todo) -> Void) {
        var request = URLRequest(url: API.baseURL)
        request.httpMethod = "PATCH"
        request.httpBody = try? JSONSerialization.data(
            withJSONObject: [
                "cardId": data.id,
                "columnId": data.id
            ]
        )
        
        URLSession.shared.dataTask(with: API.baseURL) { data, response, error in
            guard let data = data, error == nil else {
                // TODO: response error handling
                return
            }
            
            guard let model = try? JSONDecoder().decode(Todo.self, from: data) else { return }
            completion(model)
        }.resume()
    }
    
    func updateTodo(with data: Todo, _ completion: @escaping (Bool) -> Void) {
        var request = URLRequest(url: API.baseURL)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONSerialization.data(
            withJSONObject: [
                "cardId": data.id,
                "title": data.title,
                "content": data.content
            ]
        )
        
        URLSession.shared.dataTask(with: API.baseURL) { _, response, error in
            guard error == nil else {
                // TODO: response error handling
                return
            }
            
            completion(true)
        }.resume()
    }
    
    func deleteTodo(with data: Todo, _ completion: @escaping(Bool) -> Void) {
        var request = URLRequest(url: API.baseURL)
        request.httpMethod = "DELETE"
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["cardId": data.id])
        
        URLSession.shared.dataTask(with: API.baseURL) { data, response, error in
            guard error == nil else {
                // TODO: response error handling
                return
            }
            
            // TODO: 응답받는 데이터 콜백에 전달해야할지? { "cardId": 1 }
            
            completion(true)
        }.resume()
    }
}
