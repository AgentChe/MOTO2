//
//  FlashcardsViewModel.swift
//  CDL
//
//  Created by Andrey Chernyshev on 10.06.2021.
//

import RxSwift
import RxCocoa

final class FlashcardsViewModel {
    enum Action {
        case close
        case finish(Int)
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private let flashcardTopic: Driver<FlashcardTopic>
    
    init(flashcardTopic: FlashcardTopic) {
        self.flashcardTopic = BehaviorRelay(value: flashcardTopic).asDriver()
    }
    
    private lazy var flashcardsManager = FlashcardsManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Public
extension FlashcardsViewModel {
    struct Input {
        let didSelectAnswer: Signal<(id: Int, answer: Bool)>
        let didTapClose: Signal<Void>
        let didFinish: Signal<Void>
        let didMovedCard: Signal<Void>
    }
    
    struct Output {
        let mark: Driver<Void>
        let flashcardsModels: Driver<[FlashCardModel]>
        let activity: Driver<Bool>
        let action: Driver<Action>
        let progress: Driver<String>
    }
    
    func configure(input: Input) -> Output {
        let activity = RxActivityIndicator()
        
        let flashcardModels = makeFlashcardModels(
            flashcardTopic: flashcardTopic,
            activity: activity
        )
        
        let knowSelectCount = makeKnowSelectCount(didSelectAnswer: input.didSelectAnswer)
        
        return Output(
            mark: makeMark(didSelectAnswer: input.didSelectAnswer),
            flashcardsModels: flashcardModels,
            activity: activity.asDriver(),
            action: makeAction(
                didTapClose: input.didTapClose,
                didFinish: input.didFinish,
                knowSelectCount: knowSelectCount
            ),
            progress: makeProgress(
                didMovedCard: input.didMovedCard,
                flashcardsModels: flashcardModels
            )
        )
    }
}

// MARK: Private
private extension FlashcardsViewModel {
    func makeProgress(
        didMovedCard: Signal<Void>,
        flashcardsModels: Driver<[FlashCardModel]>
    ) -> Driver<String> {
        let initial = flashcardsModels
            .map { String(format: "1/%i", $0.count) }
        
        let next = didMovedCard
            .asDriver(onErrorDriveWith: .never())
            .scan(1) { current, _ -> Int in current + 1 }
            .withLatestFrom(flashcardsModels) { ($0, $1.count) }
            .map { progress, count -> String in
                String(format: "%i/%i", progress, count)
            }
        
        return Driver
            .merge(initial, next)
    }
    
    func makeFlashcardModels(
        flashcardTopic: Driver<FlashcardTopic>,
        activity: RxActivityIndicator
    ) -> Driver<[FlashCardModel]> {
        flashcardTopic
            .flatMapLatest { [weak self] flashcardTopic -> Driver<[FlashCardModel]> in
                guard let self else { return .empty() }
                
                return flashcardsManager
                    .obtainFlashcards(flashcardTopicId: flashcardTopic.id)
                    .map { $0.map { FlashCardModel(model: $0, topicName: flashcardTopic.name) } }
                    .trackActivity(activity)
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makeMark(didSelectAnswer: Signal<(id: Int, answer: Bool)>) -> Driver<Void> {
        didSelectAnswer
            .flatMapFirst { [weak self] id, isKnew -> Driver<Void> in
                guard let self else { return .never() }
                
                func source() -> Single<Void> {
                    flashcardsManager
                        .mark(flashcardId: id, know: isKnew)
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    self.tryAgain?(error) ?? .empty()
                }
                
                return observableRetrySingle
                    .retry(
                        source: { source() },
                        trigger: { trigger(error: $0) }
                    )
                    .asDriver(onErrorDriveWith: .never())
            }
    }
    
    func makeAction(
        didTapClose: Signal<Void>,
        didFinish: Signal<Void>,
        knowSelectCount: Driver<Int>
    ) -> Driver<Action> {
        let close = didTapClose
            .map { Action.close }
            .asDriver(onErrorDriveWith: .never())
        
        let finish = didFinish
            .withLatestFrom(knowSelectCount)
            .map { Action.finish($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(close, finish)
    }
    
    func makeKnowSelectCount(didSelectAnswer: Signal<(id: Int, answer: Bool)>) -> Driver<Int> {
        didSelectAnswer
            .filter { $1 }
            .scan(0) { count, _ -> Int in count + 1 }
            .startWith(0)
            .asDriver(onErrorDriveWith: .never())
    }
}
