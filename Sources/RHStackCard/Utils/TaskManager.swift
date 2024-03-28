//
//  SlideActionManager.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/24.
//

import Foundation

class TaskManager: NSObject {
    typealias Task = () -> Void
    private var tasks: [Task] = []
    private let actionSemaphore = DispatchSemaphore(value: 1)
    
    var isAbleToRunNextTask = true {
        didSet {
            if isAbleToRunNextTask {
                executeNextTaskAction()
            }
        }
    }
    
    // 將動作添加到隊列中
    func addSlideOutAction(_ action: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            self?.actionSemaphore.wait()
            self?.tasks.append(action)
            self?.actionSemaphore.signal()
            
            if (self?.isAbleToRunNextTask ?? true) {
                self?.executeNextTaskAction()
            }
        }
    }
    
    // 嘗試執行下一個存儲的動作
    private func executeNextTaskAction() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            self.actionSemaphore.wait()
            defer { self.actionSemaphore.signal() }
            
            guard self.isAbleToRunNextTask, !self.tasks.isEmpty else {
                return
            }
            
            self.isAbleToRunNextTask = false
            
            DispatchQueue.main.async {
                if let action = self.tasks.first {
                    action()
                }
            }
        }
    }
    
    // 為了簡化外部調用結束當前任務的方法
    func markCurrentTaskAsFinished() {
        if let _ = tasks.first {
            tasks.removeFirst()
        }
        isAbleToRunNextTask = true
    }
    
    func reset() {
        tasks.removeAll()
        isAbleToRunNextTask = true
    }
}
