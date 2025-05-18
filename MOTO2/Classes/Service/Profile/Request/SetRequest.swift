//
//  SetRequest.swift
//  FNP
//
//  Created by Andrey Chernyshev on 09.07.2021.
//

import Alamofire

struct SetRequest: APIRequestBody {
    private let userToken: String
    private let country: String?
    private let state: String?
    private let language: String?
    private let level: Int?
    private let testMode: Int?
    private let examDate: String?
    private let testMinutes: Int?
    private let courseId: Int?
    private let pushToken: String?
    
    init(
        userToken: String,
        country: String? = nil,
        state: String? = nil,
        language: String? = nil,
        level: Int? = nil,
        testMode: Int? = nil,
        examDate: String? = nil,
        testMinutes: Int? = nil,
        courseId: Int? = nil,
        pushToken: String? = nil
    ) {
        self.userToken = userToken
        self.country = country
        self.state = state
        self.language = language
        self.level = level
        self.testMode = testMode
        self.examDate = examDate
        self.testMinutes = testMinutes
        self.courseId = courseId
        self.pushToken = pushToken
    }
    
    var url: String {
        GlobalDefinitions.domain + "/api/users/set"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        var params: [String: Any] = [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "platform": 3
        ]
        
        if let country = self.country {
            params["country"] = country
        }
        
        if let state = self.state {
            params["state"] = state
        }
        
        if let language = self.language {
            params["language"] = language
        }
        
        if let level = self.level {
            params["level"] = level
        }
        
        if let testMode = self.testMode {
            params["test_mode"] = testMode
        }
        
        if let examDate = self.examDate {
            params["exam_date"] = examDate
        }
        
        if let testMinutes = self.testMinutes {
            params["test_minutes"] = testMinutes
        }
        
        if let courseId = courseId {
            params["current_application_course_id"] = courseId
        }
        
        if let pushToken = pushToken {
            params["notification_key"] = pushToken
        }
        
        return params
    }
}
