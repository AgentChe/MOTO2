//
//  GlobalDefinitions.swift
//  Nursing
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

import Foundation

final class GlobalDefinitions {
    static let domain = "https://bank4.apps-by-konstantin.com"
    static let apiKey = "prKt7q9LtwZUBq5a"
    
    static let otterScaleHost = "https://api.korrekted.com"
    static let otterScaleApiKey = "O8I4nXWKfi6BWZZN"
    
    static let applicationTag = "EXAMS_MOTO"
    static let amplitudeApiKey = "8b5138249711d65974423b54fed13562"
    
    static let termsOfServiceUrl = URL(string: "https://apps-by-konstantin.com/terms")!
    static let privacyPolicyUrl = URL(string: "https://apps-by-konstantin.com/policy")!
    static let contactUsUrl = URL(string: "https://apps-by-konstantin.com/contact")!
    
    enum Paygate {
        static let lifetime = "prep.exams.moto.lifetime"
        static let subscription = "prep.exams.moto.monthly"
    }
}
