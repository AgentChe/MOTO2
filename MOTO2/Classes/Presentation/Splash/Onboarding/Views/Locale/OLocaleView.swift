//
//  OLocaleView.swift
//  CDL2
//
//  Created by Андрей Чернышев on 18.05.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class OLocaleView: OSlideView {
    enum Entity {
        case country, language, state
    }
    
    weak var vc: UIViewController?
    
    lazy var tabView = makeTabView()
    lazy var titleView = makeTitleView()
    lazy var tableView = makeTableView()
    lazy var nextButton = makeNextButton()
    lazy var preloader = makePreloader()
    
    private lazy var viewModel = OLocaleViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override init(step: OnboardingView.Step) {
        super.init(step: step)
        
        makeConstraints()
        initialize()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension OLocaleView {
    func initialize() {
        backgroundColor = Appearance.main100
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            self?.openError() ?? .never()
        }
        
        let output = viewModel.configure(input: OLocaleViewModel.Input(
            didTapNext: nextButton.rx.tap.asSignal(),
            didSelect: tableView.didSelect
        ))
        
        output.elements
            .drive(Binder(tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.currentEntity
            .drive(Binder(self) { base, entity in
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
            .drive(Binder(tabView) { base, displayItemsTab in
                base.isHidden = displayItemsTab == .country
                base.update(displayItems: displayItemsTab)
            })
            .disposed(by: disposeBag)
        
        output.activity
            .drive(Binder(self) { base, activity in
                base.nextButton.isHidden = activity
                activity ? base.preloader.startAnimating() : base.preloader.stopAnimating()
            })
            .disposed(by: disposeBag)
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
    }
    
    func action(_ action: OLocaleViewModel.Action) {
        switch action {
        case .next:
            onNext()
        }
    }
    
    func openError() -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                let vc = TryAgainViewController.make {
                    observe.onNext(())
                }
                self?.vc?.present(vc, animated: true)

                return Disposables.create()
            }
    }
}

// MARK: Make constraints
private extension OLocaleView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            tabView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24.scale),
            tabView.heightAnchor.constraint(equalToConstant: 32.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 54.scale),
            titleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -54.scale),
            titleView.topAnchor.constraint(equalTo: tabView.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 2.scale),
            tableView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -2.scale)
        ])
        
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28.scale),
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28.scale),
            nextButton.heightAnchor.constraint(equalToConstant: 48.scale),
            nextButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -60.scale : -30.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: nextButton.centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: nextButton.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension OLocaleView {
    func makeTabView() -> LocaleTabView {
        let view = LocaleTabView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleView() -> LocaleTitleView {
        let view = LocaleTitleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> LocaleTableView {
        let view = LocaleTableView()
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = false
        view.separatorStyle = .none
        view.contentInset = UIEdgeInsets(vertical: 8.scale)
        view.setContentOffset(CGPoint(x: 0, y: -8.scale), animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeNextButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.semiBold(size: 17.scale))
            .letterSpacing(-0.44.scale)
        
        let view = UIButton()
        view.setAttributedTitle("Next".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.main300
        view.layer.cornerRadius = 8.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> Spinner {
        let view = Spinner(size: CGSize(width: 45.scale, height: 45.scale))
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
