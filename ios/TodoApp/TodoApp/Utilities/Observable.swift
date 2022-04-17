//
//  Observable.swift
//  TodoApp
//
//  Created by 송태환 on 2022/04/17.
//

import Foundation

final class Observable<T> {
    typealias Listener = (T) -> Void
    
    private var listener: Listener?
    var value: T {
        didSet {
            self.listener?(value)
        }
    }
    
    init(value: T) {
        self.value = value
    }
    
    func bind(listener: @escaping Listener) {
        self.listener = listener
        listener(self.value)
    }
}
