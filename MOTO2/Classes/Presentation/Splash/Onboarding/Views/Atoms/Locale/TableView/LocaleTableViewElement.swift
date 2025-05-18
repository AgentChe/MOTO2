//
//  LocaleTableViewElement.swift
//  CDL2
//
//  Created by Андрей Чернышев on 18.05.2025.
//

final class LocaleTableViewElement {
    var isSelected: Bool
    let name: String
    let code: String
    
    init(
        isSelected: Bool,
        name: String,
        code: String
    ) {
        self.isSelected = isSelected
        self.name = name
        self.code = code
    }
}
