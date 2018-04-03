//
//  OperationDataManager.swift
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 28.03.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

import UIKit


class AsyncOperation: Operation {

	// Определяем перечисление enum State со свойством keyPath
	enum State: String {
		case ready, executing, finished
		
		fileprivate var keyPath: String {
			return "is" + rawValue.capitalized
		}
	}
	
	// Помещаем в subclass свойство state типа State
	var state = State.ready {
		willSet {
			willChangeValue(forKey: newValue.keyPath)
			willChangeValue(forKey: state.keyPath)
		}
		didSet {
			didChangeValue(forKey: oldValue.keyPath)
			didChangeValue(forKey: state.keyPath)
		}
	}
	
	override var isReady: Bool {
		return super.isReady && state == .ready
	}
	
	override var isExecuting: Bool {
		return state == .executing
	}
	
	override var isFinished: Bool {
		return state == .finished
	}
	
	override var isAsynchronous: Bool {
		return true
	}
	
	override func start() {
		if isCancelled {
			state = .finished
			return
		}
		main()
		state = .executing
	}
	
	override func cancel() {
		state = .finished
	}
	
}
