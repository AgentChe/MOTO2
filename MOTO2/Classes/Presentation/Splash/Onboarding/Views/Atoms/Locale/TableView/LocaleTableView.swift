//
//  LocaleTableView.swift
//  CDL2
//
//  Created by Андрей Чернышев on 18.05.2025.
//

import UIKit

final class LocaleTableView: UITableView {
    var tapped: (() -> Void)?
    
    lazy var elements = [LocaleTableViewElement]()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension LocaleTableView {
    func setup(elements: [LocaleTableViewElement]) {
        self.elements = elements
        
        reloadData()
    }
}

// MARK: UITableViewDataSource
extension LocaleTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: LocaleTableViewCell.self)) as! LocaleTableViewCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension LocaleTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        elements.enumerated().forEach { index, element in
            element.isSelected = index == indexPath.row
        }
        
        reloadData()
        
        tapped?()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: Private
private extension LocaleTableView {
    func initialize() {
        register(LocaleTableViewCell.self, forCellReuseIdentifier: String(describing: LocaleTableViewCell.self))
        
        dataSource = self
        delegate = self
    }
}
