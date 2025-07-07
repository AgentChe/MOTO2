//
//  LocaleViewModel.swift
//  CDL2
//
//  Created by Андрей Чернышев on 18.05.2025.
//

import RxSwift
import RxCocoa

final class LocaleViewModel {
    enum Action {
        case close
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var profileManager = ProfileManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Public
extension LocaleViewModel {
    struct Input {
        let didTapNext: Signal<Void>
        let didSelect: Signal<LocaleTableViewElement>
    }
    
    struct Output {
        let elements: Driver<[LocaleTableViewElement]>
        let currentEntity: Driver<LocaleView.Entity>
        let displayItemsTab: Driver<LocaleTabView.DisplayItems>
        let action: Driver<Action>
        let activity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        let selectedElementInListRelay = BehaviorRelay<LocaleTableViewElement?>(value: nil)
        let selectedElementInList = selectedElementInListRelay
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .never())
        
        let nextAction = makeNextAction(
            didTapNext: input.didTapNext,
            selectedElementInList: selectedElementInList
        )
        
        let countries = makeCountries()
        let profile = makeProfile()
        
        let elements = makeElements(
            countries: countries,
            profile: profile,
            nextAction: nextAction
        )
        
        makeSelectedElementInList(
            elements: elements,
            didSelect: input.didSelect
        )
        .drive(selectedElementInListRelay)
        .disposed(by: disposeBag)
        
        return Output(
            elements: elements,
            currentEntity: makeEntity(selectedElementInList: selectedElementInList),
            displayItemsTab: makeDisplayItemsTab(
                selectedElementInList: selectedElementInList,
                countries: countries
            ),
            action: makeAction(
                nextAction: nextAction,
                locale: makeLocale(selectedElementInList: selectedElementInList)
            ),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension LocaleViewModel {
    typealias Locale = (Country?, Language?, State?)
    
    enum NextAction {
        case createElements(LocaleTableViewElement)
        case setupLocale
    }
    
    func makeNextAction(
        didTapNext: Signal<Void>,
        selectedElementInList: Driver<LocaleTableViewElement>
    ) -> Driver<NextAction> {
        didTapNext
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(selectedElementInList)
            .map { selectedElementInList -> NextAction in
                if let country = selectedElementInList.country {
                    if country.languages.count > 1 {
                        return .createElements(selectedElementInList)
                    } else if let language = country.languages.first, language.states.count > 1 {
                        return .createElements(selectedElementInList)
                    }
                    return .setupLocale
                } else if let language = selectedElementInList.language, language.states.count > 1 {
                    return .createElements(selectedElementInList)
                }
                
                return .setupLocale
            }
    }
    
    func makeAction(
        nextAction: Driver<NextAction>,
        locale: Driver<Locale>
    ) -> Driver<Action> {
        nextAction
            .filter { $0 == .setupLocale }
            .withLatestFrom(locale)
            .flatMapLatest { [weak self] locale -> Driver<Action> in
                guard let self else { return .never() }
                
                func source() -> Single<Void> {
                    profileManager
                        .set(
                            country: locale.0?.code,
                            state: locale.2?.code,
                            language: locale.1?.code
                        )
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    tryAgain?(error) ?? .empty()
                }
                
                return self.observableRetrySingle
                    .retry(
                        source: { source() },
                        trigger: { trigger(error: $0) }
                    )
                    .trackActivity(activity)
                    .asDriver(onErrorDriveWith: .never())
                    .map { Action.close }
            }
    }
    
    func makeLocale(selectedElementInList: Driver<LocaleTableViewElement>) -> Driver<Locale> {
        selectedElementInList
            .scan(Locale(nil, nil, nil)) { current, selectedElementInList -> Locale in
                if let country = selectedElementInList.country {
                    if country.languages.count > 1 {
                        return (country, nil, nil)
                    } else {
                        let language = country.languages.first
                        let states = language?.states ?? []
                        return (country, language, states.count > 1 ? nil : states.first)
                    }
                } else if let language = selectedElementInList.language {
                    if language.states.count > 1 {
                        return (current.0, language, nil)
                    } else {
                        return (current.0, language, language.states.first)
                    }
                } else if let state = selectedElementInList.state {
                    return (current.0, current.1, state)
                }
                
                return (nil, nil, nil)
            }
    }
    
    func makeElements(
        countries: Driver<[Country]>,
        profile: Driver<Profile?>,
        nextAction: Driver<NextAction>
    ) -> Driver<[LocaleTableViewElement]> {
        let initial = Driver
            .combineLatest(countries, profile)
            .map { countries, profile -> [LocaleTableViewElement] in
                countries.enumerated().map { index, country -> LocaleTableViewElement in
                    let isSelected: Bool = {
                        guard let code = profile?.locale?.countryCode else { return index == 0 }
                        return code == country.code
                    }()
                    
                    return LocaleTableViewElement(
                        isSelected: isSelected,
                        country: country
                    )
                }
            }
        
        let next = nextAction
            .compactMap { nextAction -> LocaleTableViewElement? in
                guard case let .createElements(selectedElementInList) = nextAction else { return nil }
                return selectedElementInList
            }
            .compactMap { selectedElementInList -> [LocaleTableViewElement]? in
                if let country = selectedElementInList.country {
                    if country.languages.count > 1 {
                        return country.languages.enumerated().map { index, language -> LocaleTableViewElement in
                            LocaleTableViewElement(
                                isSelected: index == 0,
                                language: language
                            )
                        }
                    } else if let language = country.languages.first, language.states.count > 1 {
                        return language.states.enumerated().map { index, state -> LocaleTableViewElement in
                            LocaleTableViewElement(
                                isSelected: index == 0,
                                state: state
                            )
                        }
                    } else {
                        return nil
                    }
                } else if let language = selectedElementInList.language, language.states.count > 1 {
                    return language.states.enumerated().map { index, state -> LocaleTableViewElement in
                        LocaleTableViewElement(
                            isSelected: index == 0,
                            state: state
                        )
                    }
                }
                
                return nil
            }
            .asDriver(onErrorJustReturn: [])
        
        return Driver
            .merge(initial, next)
    }
    
    func makeEntity(selectedElementInList: Driver<LocaleTableViewElement>) -> Driver<LocaleView.Entity> {
        selectedElementInList
            .map { element -> LocaleView.Entity in
                if element.country != nil {
                    return .country
                } else if element.language != nil {
                    return .language
                } else if element.state != nil {
                    return .state
                }
                
                return .country
            }
            .distinctUntilChanged()
    }
    
    func makeDisplayItemsTab(
        selectedElementInList: Driver<LocaleTableViewElement>,
        countries: Driver<[Country]>
    ) -> Driver<LocaleTabView.DisplayItems> {
        Driver
            .combineLatest(selectedElementInList, countries)
            .map { selectedElementInList, countries -> LocaleTabView.DisplayItems in
                if let country = selectedElementInList.country {
                    let languages = country.languages
                    
                    if languages.count > 1 {
                        return .countryLanguageState
                    } else if let language = languages.first {
                        return language.states.count > 1 ? .countryState : .country
                    } else {
                        return .country
                    }
                } else if let language = selectedElementInList.language {
                    return language.states.count > 1 ? .countryLanguageState : .countryLanguage
                } else if let state = selectedElementInList.state {
                    let country = countries.first(where: { country -> Bool in
                        country.languages.contains { language -> Bool in
                            language.states.contains(state)
                        }
                    })
                    guard let country else { return .countryLanguageState }
                    
                    return country.languages.count > 1 ? .countryLanguageState : .countryState
                }
                
                return .country
            }
    }
    
    func makeSelectedElementInList(
        elements: Driver<[LocaleTableViewElement]>,
        didSelect: Signal<LocaleTableViewElement>
    ) -> Driver<LocaleTableViewElement> {
        let initial = elements.compactMap { $0.first(where: { $0.isSelected }) }
        let selected = didSelect.asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(initial, selected)
    }
    
    func makeCountries() -> Driver<[Country]> {
        profileManager
            .obtainCountries(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeProfile() -> Driver<Profile?> {
        profileManager
            .obtainProfile(forceUpdate: false)
            .asDriver(onErrorJustReturn: nil)
    }
}

// MARK: Additional
private extension LocaleTableViewElement {
    var country: Country? {
        guard case let .country(country) = entity else {
            return nil
        }
        
        return country
    }
    
    var language: Language? {
        guard case let .language(language) = entity else {
            return nil
        }
        
        return language
    }
    
    var state: State? {
        guard case let .state(state) = entity else {
            return nil
        }
        
        return state
    }
}

// MARK: Additional
extension LocaleViewModel.NextAction: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.createElements, .createElements):
            return true
        case (.setupLocale, .setupLocale):
            return true
        default:
            return false
        }
    }
}
