//
//  LocaleViewController.swift
//  CDL2
//
//  Created by Андрей Чернышев on 18.05.2025.
//

import UIKit
import RxSwift

final class LocaleViewController: UIViewController {
    private lazy var mainView = LocaleView()
    
    private lazy var viewModel = LocaleViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            self?.open(error: error) ?? .never()
        }
        
        let output = viewModel.configure(input: LocaleViewModel.Input(
            didTapNext: mainView.nextButton.rx.tap.asSignal(),
            didSelect: mainView.tableView.didSelect
        ))
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.currentEntity
            .drive(Binder(mainView) { base, entity in
                base.tabView.update(currentItem: {
                    switch entity {
                    case .country: return .country
                    case .language: return .language
                    case .state: return .state
                    }
                }())
                
                base.titleView.update(text: {
                    switch entity {
                    case .country:
                        return "Onboarding.Locale.Country.Title".localized
                    case .language:
                        return "Onboarding.Locale.Language.Title".localized
                    case .state:
                        return "Onboarding.Locale.State.Title".localized
                    }
                }())
            })
            .disposed(by: disposeBag)
        
        output.displayItemsTab
            .drive(Binder(mainView.tabView) { base, displayItemsTab in
                base.isHidden = displayItemsTab == .country
                base.update(displayItems: displayItemsTab)
            })
            .disposed(by: disposeBag)
        
        output.activity
            .drive(Binder(mainView) { base, activity in
                base.activity(activity)
            })
            .disposed(by: disposeBag)
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension LocaleViewController {
    static func make() -> LocaleViewController {
        let vc = LocaleViewController()
        vc.modalPresentationStyle = .popover
        return vc
    }
}

// MARK: Private
private extension LocaleViewController {
    func action(_ action: LocaleViewModel.Action) {
        switch action {
        case .close:
            dismiss(animated: true)
        }
    }
    
    func open(error: Error) -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                let vc = TryAgainViewController.make() {
                    observe.onNext(())
                }
                self?.present(vc, animated: true)
                
                return Disposables.create()
            }
    }
}
