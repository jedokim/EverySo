//
//  Clock.swift
//  EverySo
//
//  Created by Jeremy Kim on 5/30/25.
//

import Foundation
import Combine

class Clock: ObservableObject {
    @Published var now: Date = Date()
    
    private var timer: AnyCancellable?
    
    init() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.now = Date()
            }
    }
    
    deinit {
        timer?.cancel()
    }
}
