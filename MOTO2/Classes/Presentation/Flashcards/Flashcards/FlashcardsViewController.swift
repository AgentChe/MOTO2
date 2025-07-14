//
//  FlashcardsViewController.swift
//  CDL
//
//  Created by Andrey Chernyshev on 10.06.2021.
//

import UIKit
import RxSwift

final class FlashcardsViewController: UIViewController {
    private lazy var mainView = FlashcardsView()
    
    private let viewModel: FlashcardsViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private init(topic: FlashcardTopic) {
        viewModel = FlashcardsViewModel(flashcardTopic: topic)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            self?.openError() ?? .empty()
        }
        
        let output = viewModel.configure(input: FlashcardsViewModel.Input(
            didSelectAnswer: mainView.flashCardContainer.selectedAnswer,
            didTapClose: mainView.closeButton.rx.tap.asSignal(),
            didFinish: mainView.flashCardContainer.finish,
            didMovedCard: mainView.flashCardContainer.didMovedCard
        ))
        
        output.mark
            .drive()
            .disposed(by: disposeBag)
        
        output.activity
            .drive(Binder(mainView.preloader) { base, activity in
                activity ? base.startAnimating() : base.stopAnimating()
            })
            .disposed(by: disposeBag)
        
        output.flashcardsModels
            .drive(Binder(mainView.flashCardContainer) { base, models in
                base.showCards(for: models)
            })
            .disposed(by: disposeBag)
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
        
        output.progress
            .drive(Binder(mainView) { base, progress in
                base.setup(progress: progress)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Make
extension FlashcardsViewController {
    static func make(topic: FlashcardTopic) -> NavigationController {
        let vc = FlashcardsViewController(topic: topic)
        
        let nc = NavigationController(rootViewController: vc)
        nc.setNavigationBarHidden(true, animated: false)
        nc.modalPresentationStyle = .fullScreen
        
        return nc
    }
}

// MARK: Private
private extension FlashcardsViewController {
    func action(_ action: FlashcardsViewModel.Action) {
        switch action {
        case .close:
            navigationController?.dismiss(animated: true)
        case .finish(let knowSelectCount):
            FlashCardManagerMediator.shared.finishFlashCards()
            
            let vc = FlashcardsFinishViewController.make(count: knowSelectCount)
            navigationController?.setViewControllers([vc], animated: true)
        }
    }
    
    func openError() -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                let vc = TryAgainViewController.make {
                    observe.onNext(())
                }
                self?.present(vc, animated: true)
                
                return Disposables.create()
            }
    }
}
