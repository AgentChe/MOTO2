//
//  GetCountriesRequest.swift
//  CDL2
//
//  Created by Андрей Чернышев on 18.05.2025.
//

import Alamofire

struct GetCountriesRequest: APIRequestBody {
    var url: String {
        GlobalDefinitions.domain + "/api/courses/configuration"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey
        ]
    }
}
