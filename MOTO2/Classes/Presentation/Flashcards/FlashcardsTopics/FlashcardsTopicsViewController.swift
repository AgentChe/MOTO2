//
//  FlashcardsTopicsViewController.swift
//  CDL
//
//  Created by Andrey Chernyshev on 10.06.2021.
//

import UIKit
import RxSwift

final class FlashcardsTopicsViewController: UIViewController {
    private lazy var mainView = FlashcardsTopicsView()
    
    private lazy var viewModel = FlashcardsTopicsViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: FlashcardsTopicsViewModel.Input(
            didSelect: mainView.tableView.didSelect
        ))
        
        output.activity
            .drive(Binder(mainView) { base, activity in
                base.tableContainer.isHidden = activity
                
                activity ? base.preloader.startAnimating() : base.preloader.stopAnimating()
            })
            .disposed(by: disposeBag)
        
        output.flashcardsTopics
            .drive(Binder(mainView) { base, flashcards in
                base.setup(flashcards: flashcards)
            })
            .disposed(by: disposeBag)
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Make
extension FlashcardsTopicsViewController {
    static func make() -> FlashcardsTopicsViewController {
        let vc = FlashcardsTopicsViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension FlashcardsTopicsViewController {
    func action(_ action: FlashcardsTopicsViewModel.Action) {
        switch action {
        case .openFlashcards(let flashcardTopic):
            let vc = FlashcardsViewController.make(topic: flashcardTopic)
            present(vc, animated: true)
        case .openPaygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        }
    }
}
