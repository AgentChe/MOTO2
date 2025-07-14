//
//  FlashcardsManagerCore.swift
//  CDL
//
//  Created by Andrey Chernyshev on 10.06.2021.
//

import RxSwift

protocol FlashcardsManagerProtocol: AnyObject {
    func obtainTopics(courseId: Int) -> Single<[FlashcardTopic]>
    func obtainFlashcards(flashcardTopicId: Int) -> Single<[Flashcard]>
    func mark(flashcardId: Int, know: Bool) -> Single<Void>
}

final class FlashcardsManager {
    private lazy var sessionManager = SessionManager()
    
    private lazy var restAPITransport = RestAPITransport()
}

// MARK: FlashcardsManagerProtocol
extension FlashcardsManager: FlashcardsManagerProtocol {
    func obtainTopics(courseId: Int) -> Single<[FlashcardTopic]> {
        let request = GetFlashcardsTopicsRequest(
            userToken: sessionManager.internalId,
            courseId: courseId
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .map(GetFlashcardsTopicsResponseMapper.map(from:))
    }
    
    func obtainFlashcards(flashcardTopicId: Int) -> Single<[Flashcard]> {
        let request = GetFlashcardsRequest(
            userToken: sessionManager.internalId,
            flashcardTopicId: flashcardTopicId,
            activeSubscription: SessionManager().hasActiveSubscriptions()
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .map(GetFlashcardsResponseMapper.map(from:))
    }
    
    func mark(flashcardId: Int, know: Bool) -> Single<Void> {
        let request = MarkFlashcardRequest(
            userToken: sessionManager.internalId,
            flashcardId: flashcardId,
            know: know
        )
        
        return restAPITransport
            .callServerApi(requestBody: request)
            .map { _ in Void() }
    }
}
