//
//  Country.swift
//  CDL2
//
//  Created by Андрей Чернышев on 18.05.2025.
//

struct Country: Codable, Hashable {
    let name: String
    let code: String
    let preSelected: Bool
    let sort: Int
    let languages: [Language]
}
