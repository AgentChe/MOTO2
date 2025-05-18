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
    lazy var countryView = makeCountryView()
    lazy var languageView = makeLanguageView()
    lazy var stateView = makeStateView()
    lazy var preloader = makePreloader()
    
    private lazy var completeTrigger = PublishRelay<ProfileLocale>()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var countries = [Country]()
    
    private lazy var countryLeadingConstraint = NSLayoutConstraint()
    
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
    func setup(countries: [Country]) {
        self.countries = countries
        
        countryView.setup(countries: countries)
        
        if countries.isEmpty {
            complete()
        } else if countries.count == 1 {
            countrySelected()
        }
    }
    
    func activity(_ activity: Bool) {
        countryView.button.isHidden = activity
        languageView.button.isHidden = activity
        stateView.button.isHidden = activity
        
        activity ? preloader.startAnimating() : preloader.stopAnimating()
    }
    
    var didSave: Signal<ProfileLocale> {
        completeTrigger.asSignal()
    }
}

// MARK: Private
private extension LocaleView {
    enum Content {
        case country
        case language
        case state
    }
    
    func initialize() {
        backgroundColor = Appearance.main100
        
        countryView.onNext = { [weak self] in self?.countrySelected() }
        languageView.onNext = { [weak self] in self?.languageSelected() }
        stateView.onNext = { [weak self] in self?.stateSelected() }
    }
    
    func countrySelected() {
        guard
            let countryCode = getSelectedCountry(),
            let languages = countries.first(where: { $0.code == countryCode })?.languages
        else {
            return
        }
        
        languageView.setup(languages: languages)
        
        if languages.isEmpty {
            complete()
        } else if languages.count == 1 {
            languageSelected()
        } else {
            scroll(to: .language)
        }
    }
    
    func languageSelected() {
        guard
            let countryCode = getSelectedCountry(),
            let languages = countries.first(where: { $0.code == countryCode })?.languages,
            let languageCode = getSelectedLanguage(),
            let states = languages.first(where: { $0.code == languageCode })?.states
        else {
            return
        }
        
        stateView.setup(states: states)
        
        if states.isEmpty {
            complete()
        } else if states.count == 1 {
            stateSelected()
        } else {
            scroll(to: .state)
        }
    }
    
    func stateSelected() {
        complete()
    }
    
    func getSelectedCountry() -> String? {
        let elements = countryView.tableView.elements
        if elements.isEmpty {
            return nil
        } else if elements.count == 1 {
            return elements.first?.code
        } else {
            return elements.first(where: { $0.isSelected })?.code
        }
    }
    
    func getSelectedLanguage() -> String? {
        let elements = languageView.tableView.elements
        
        if elements.isEmpty {
            return nil
        } else if elements.count == 1 {
            return elements.first?.code
        } else {
            return elements.first(where: { $0.isSelected })?.code
        }
    }
    
    func getSelectedState() -> String? {
        let stats = stateView.states
        
        if stats.isEmpty {
            return nil
        } else if stats.count == 1 {
            return stats.first?.code
        } else {
            let row = stateView.pickerView.selectedRow(inComponent: 0)
            guard stats.indices.contains(row) else {
                return nil
            }
            return stats[row].code
        }
    }
    
    func scroll(to content: Content) {
        countryLeadingConstraint.isActive = false
        countryLeadingConstraint.constant = {
            switch content {
            case .country:
                return 0
            case .language:
                return -bounds.width
            case .state:
                return -bounds.width * 2
            }
        }()
        countryLeadingConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.layoutIfNeeded()
        })
    }
    
    func complete() {
        let locale = ProfileLocale(
            countryCode: getSelectedCountry(),
            languageCode: getSelectedLanguage(),
            stateCode: getSelectedState()
        )
        
        completeTrigger.accept(locale)
    }
}

// MARK: Make constraints
private extension LocaleView {
    func makeConstraints() {
        countryLeadingConstraint = countryView.leadingAnchor.constraint(equalTo: leadingAnchor)
        NSLayoutConstraint.activate([
            countryLeadingConstraint,
            countryView.topAnchor.constraint(equalTo: topAnchor),
            countryView.bottomAnchor.constraint(equalTo: bottomAnchor),
            countryView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            languageView.leadingAnchor.constraint(equalTo: countryView.trailingAnchor),
            languageView.topAnchor.constraint(equalTo: topAnchor),
            languageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            languageView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stateView.leadingAnchor.constraint(equalTo: languageView.trailingAnchor),
            stateView.topAnchor.constraint(equalTo: topAnchor),
            stateView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stateView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -85.scale : -55.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension LocaleView {
    func makeCountryView() -> LocaleCountryView {
        let view = LocaleCountryView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLanguageView() -> LocaleLanguageView {
        let view = LocaleLanguageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeStateView() -> LocaleStateView {
        let view = LocaleStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> Spinner {
        let view = Spinner(size: CGSize(width: 24.scale, height: 24.scale), color: .white)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
