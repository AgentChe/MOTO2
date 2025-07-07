//
//  LocaleTabView.swift
//  CDL2
//
//  Created by Андрей Чернышев on 04.07.2025.
//

import UIKit

final class LocaleTabView: UIView {
    enum Item {
        case country, language, state
    }
    
    enum DisplayItems {
        case countryLanguageState
        case countryLanguage
        case countryState
        case country
    }
    
    lazy var container = makeContainer()
     
    private var countryItemView: LocaleTabItemView?
    private var languageItemView: LocaleTabItemView?
    private var stateItemView: LocaleTabItemView?
    
    private var currentItem: Item?
    
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
extension LocaleTabView {
    func update(currentItem: Item) {
        self.currentItem = currentItem
        
        countryItemView?.update(selected: currentItem == .country)
        languageItemView?.update(selected: currentItem == .language)
        stateItemView?.update(selected: currentItem == .state)
    }
    
    func update(displayItems: DisplayItems) {
        container.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        countryItemView = nil
        languageItemView = nil
        stateItemView = nil
        
        switch displayItems {
        case .country:
            countryItemView = LocaleTabItemView(text: "Onboarding.Locale.Country.Tab".localized)
        case .countryLanguage:
            countryItemView = LocaleTabItemView(text: "Onboarding.Locale.Country.Tab".localized)
            languageItemView = LocaleTabItemView(text: "Onboarding.Locale.Language.Tab".localized)
        case .countryState:
            countryItemView = LocaleTabItemView(text: "Onboarding.Locale.Country.Tab".localized)
            stateItemView = LocaleTabItemView(text: "Onboarding.Locale.State.Tab".localized)
        case .countryLanguageState:
            countryItemView = LocaleTabItemView(text: "Onboarding.Locale.Country.Tab".localized)
            languageItemView = LocaleTabItemView(text: "Onboarding.Locale.Language.Tab".localized)
            stateItemView = LocaleTabItemView(text: "Onboarding.Locale.State.Tab".localized)
        }
        
        [countryItemView, languageItemView, stateItemView].compactMap { $0 }.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            container.addArrangedSubview(view)
            
            view.setContentHuggingPriority(.required, for: .horizontal)
            view.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: container.topAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        }
        
        if let currentItem {
            update(currentItem: currentItem)
        }
        
        layoutIfNeeded()
    }
}

// MARK: Private
private extension LocaleTabView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension LocaleTabView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension LocaleTabView {
    func makeContainer() -> UIStackView {
        let view = UIStackView()
        view.backgroundColor = UIColor.clear
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .equalSpacing
        view.alignment = .center
        view.spacing = 24.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
