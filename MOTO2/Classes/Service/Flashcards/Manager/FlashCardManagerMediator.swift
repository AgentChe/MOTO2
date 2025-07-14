//
//  FlashCardManagerMediator.swift
//  CDL
//
//  Created by Vitaliy Zagorodnov on 12.06.2021.
//

import RxCocoa

final class FlashCardManagerMediator {
    static let shared = FlashCardManagerMediator()
    
    private let flashCardTrigger = PublishRelay<Void>()
    
    private init() {}
}

// MARK: API
extension FlashCardManagerMediator {
    func finishFlashCards() {
        DispatchQueue.main.async { [weak self] in
            self?.flashCardTrigger.accept(())
        }
    }
}

// MARK: Triggers(Rx)
extension FlashCardManagerMediator {
    var rxFlashCardFinished: Signal<Void> {
        flashCardTrigger.asSignal()
    }
}
