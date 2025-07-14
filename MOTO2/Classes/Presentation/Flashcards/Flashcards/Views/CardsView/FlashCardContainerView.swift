//
//  FlashCardContainerView.swift
//  CDL
//
//  Created by Vitaliy Zagorodnov on 12.06.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class FlashCardContainerView: UIView {
    private lazy var didSelectAnswer = PublishRelay<(id: Int, answer: Bool)>()
    private lazy var emptyCardsRelay = PublishRelay<Void>()
    private lazy var didMovedCardTrigger = PublishRelay<Void>()
    
    private lazy var index = 0
    
    private lazy var allCards: [FlashCardModel] = []
}

// MARK: Public
extension FlashCardContainerView {
    func showCards(for elements: [FlashCardModel]) {
        guard !elements.isEmpty else { return }
        
        allCards.append(contentsOf: elements)
        
        if let firstElement = elements.first {
            let cardView = createCard(for: firstElement)
            addSubview(cardView)
            
            cardView.moveToThis()
        }
    }
    
    var selectedAnswer: Signal<(id: Int, answer: Bool)> {
        didSelectAnswer.asSignal()
    }
    
    var finish: Signal<Void> {
        emptyCardsRelay.asSignal()
    }
    
    var didMovedCard: Signal<Void> {
        didMovedCardTrigger.asSignal()
    }
}

// MARK: FlashCardDelegate
extension FlashCardContainerView: FlashCardDelegate {
    func moved() {
        removeAndAddNewCard()
        
        didMovedCardTrigger.accept(Void())
    }
    
    func tapAction(id: Int, isKnew: Bool) {
        didSelectAnswer.accept((id, isKnew))
    }
}

// MARK: Private
private extension FlashCardContainerView {
    func createCard(for element: FlashCardModel) -> FlashCardView {
        let origin = CGPoint.zero
        let size = CGSize(width: bounds.width, height: bounds.height)
        
        let card = FlashCardView(frame: CGRect(origin: origin, size: size))
        card.delegate = self
        card.setup(element: element)
        return card
    }
    
    func removeAndAddNewCard() {
        subviews.forEach { $0.removeFromSuperview() }
        
        index += 1
        
        if let card = allCards[safe: index] {
            let cardView = createCard(for: card)
            addSubview(cardView)
            
            cardView.moveToThis()
        } else {
            emptyCardsRelay.accept(())
        }
    }
}
