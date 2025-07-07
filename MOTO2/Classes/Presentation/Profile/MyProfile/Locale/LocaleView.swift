//
//  LocaleView.swift
//  CDL2
//
//  Created by Андрей Чернышев on 18.05.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class LocaleView: UIView {
    enum Entity {
        case country, language, state
    }
    
    lazy var tabView = makeTabView()
    lazy var titleView = makeTitleView()
    lazy var tableView = makeTableView()
    lazy var nextButton = makeNextButton()
    lazy var preloader = makePreloader()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension LocaleView {
    func activity(_ activity: Bool) {
        nextButton.isHidden = activity
        activity ? preloader.startAnimating() : preloader.stopAnimating()
    }
}

// MARK: Private
private extension LocaleView {
    func initialize() {
        backgroundColor = Appearance.main100
    }
}

// MARK: Make constraints
private extension LocaleView {
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
private extension LocaleView {
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
