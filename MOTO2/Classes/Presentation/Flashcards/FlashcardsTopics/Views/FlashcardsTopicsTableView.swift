//
//  FlashcardsTableView.swift
//  CDL
//
//  Created by Andrey Chernyshev on 10.06.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class FlashcardsTopicsTableView: UITableView {
    private lazy var flashcards = [FlashcardTopic]()
    
    private lazy var didSelectTrigger = PublishRelay<FlashcardTopic>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension FlashcardsTopicsTableView {
    func setup(flashcards: [FlashcardTopic]) {
        self.flashcards = flashcards
        
        reloadData()
    }
    
    var didSelect: Signal<FlashcardTopic> {
        didSelectTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension FlashcardsTopicsTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        flashcards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: FlashcardsTopicsTableCell.self)) as! FlashcardsTopicsTableCell
        cell.setup(flashcard: flashcards[indexPath.row])
        cell.separator.isHidden = (indexPath.row) == (flashcards.count - 1)
        return cell
    }
}

// MARK: UITableViewDelegate
extension FlashcardsTopicsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        FlashcardsTopicsTableCell.Constants.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectTrigger.accept(flashcards[indexPath.row])
    }
}

// MARK: Private
private extension FlashcardsTopicsTableView {
    func initialize() {
        register(FlashcardsTopicsTableCell.self, forCellReuseIdentifier: String(describing: FlashcardsTopicsTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
