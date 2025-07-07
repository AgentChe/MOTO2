//
//  LocaleTableViewElement.swift
//  CDL2
//
//  Created by Андрей Чернышев on 18.05.2025.
//

final class LocaleTableViewElement {
    enum Entity {
        case country(Country)
        case language(Language)
        case state(State)
    }
    
    var isSelected: Bool
    let name: String
    let entity: Entity
    
    init(
        isSelected: Bool,
        country: Country
    ) {
        self.isSelected = isSelected
        self.name = country.name
        self.entity = .country(country)
    }
    
    init(
        isSelected: Bool,
        language: Language
    ) {
        self.isSelected = isSelected
        self.name = language.name
        self.entity = .language(language)
    }
    
    init(
        isSelected: Bool,
        state: State
    ) {
        self.isSelected = isSelected
        self.name = state.name
        self.entity = .state(state)
    }
}
