//
//  FlashcardsTopicsViewModel.swift
//  CDL
//
//  Created by Andrey Chernyshev on 10.06.2021.
//

import RxSwift
import RxCocoa

final class FlashcardsTopicsViewModel {
    enum Action {
        case openFlashcards(FlashcardTopic)
        case openPaygate
    }
    
    private lazy var profileManager = ProfileManager()
    private lazy var flashcardsManager = FlashcardsManager()
}

// MARK: Public
extension FlashcardsTopicsViewModel {
    struct Input {
        let didSelect: Signal<FlashcardTopic>
    }
    
    struct Output {
        let action: Driver<Action>
        let flashcardsTopics: Driver<[FlashcardTopic]>
        let activity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        let activity = RxActivityIndicator()
        
        return Output(
            action: makeAction(didSelect: input.didSelect),
            flashcardsTopics: makeFlashcardsTopics(
                courseId: makeCourseId(),
                activity: activity
            ),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension FlashcardsTopicsViewModel {
    func makeAction(didSelect: Signal<FlashcardTopic>) -> Driver<Action> {
        didSelect
            .map { topic -> Action in
                let needPayment = topic.paid ? !SessionManager().hasActiveSubscriptions() : false
                return needPayment ? .openPaygate : .openFlashcards(topic)
            }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeFlashcardsTopics(courseId: Driver<Int>, activity: RxActivityIndicator) -> Driver<[FlashcardTopic]> {
        courseId
            .flatMapLatest { [weak self] courseId -> Driver<[FlashcardTopic]> in
                guard let self else { return .never() }
                
                return flashcardsManager
                    .obtainTopics(courseId: courseId)
                    .trackActivity(activity)
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makeCourseId() -> Driver<Int> {
        let initial = profileManager
            .obtainExamEnvironment()
            .compactMap { $0?.course.id }
            .asDriver(onErrorDriveWith: .never())
        
        let changed = ProfileMediator.shared
            .changedExamEnvironment
            .map { $0.course.id }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(initial, changed)
    }
}
