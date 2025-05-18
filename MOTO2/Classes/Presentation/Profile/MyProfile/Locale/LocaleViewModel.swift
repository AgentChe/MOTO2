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
    
    private lazy var profileManager = ProfileManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Public
extension LocaleViewModel {
    struct Input {
        let didSave: Signal<ProfileLocale>
    }
    
    struct Output {
        let action: Driver<Action>
        let countries: Driver<[Country]>
        let activity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        Output(
            action: makeAction(didSave: input.didSave),
            countries: makeCountries(),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension LocaleViewModel {
    func makeCountries() -> Driver<[Country]> {
        profileManager
            .obtainCountries(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeAction(didSave: Signal<ProfileLocale>) -> Driver<Action> {
        didSave
            .flatMapLatest { [weak self] locale -> Driver<Action> in
                guard let self else { return .never() }
                
                func source() -> Single<Action> {
                    self.profileManager
                        .set(
                            country: locale.countryCode,
                            state: locale.stateCode,
                            language: locale.languageCode
                        )
                        .map { Action.close }
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    tryAgain?(error) ?? .empty()
                }
                
                return observableRetrySingle
                    .retry(
                        source: { source() },
                        trigger: { trigger(error: $0) }
                    )
                    .trackActivity(activity)
                    .asDriver(onErrorDriveWith: .never())
            }
    }
}
