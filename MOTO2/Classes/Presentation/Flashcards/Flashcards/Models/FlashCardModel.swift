//
//  FlashCardModel.swift
//  CDL
//
//  Created by Vitaliy Zagorodnov on 12.06.2021.
//

import Foundation

struct FlashCardModel {
    enum Content {
        case image(URL)
        case video(URL)
        case none
    }
    
    let id: Int
    let content: Content
    let question: String
    let answer: String
    let knew: Bool
    let topicName: String
}

// MARK: Public
extension FlashCardModel {
    init(model: Flashcard, topicName: String) {
        id = model.id
        content = model.image.flatMap { URL(string: $0) }.map { .image($0) }
            ?? model.video.flatMap { URL(string: $0) } .map { .video($0) }
            ?? .none
        question = model.front
        answer = model.back
        knew = model.knew
        self.topicName = topicName
    }
}
