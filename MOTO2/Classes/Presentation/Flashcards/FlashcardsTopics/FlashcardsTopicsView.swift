//
//  FlashcardsTopicsView.swift
//  CDL
//
//  Created by Andrey Chernyshev on 10.06.2021.
//

import UIKit

final class FlashcardsTopicsView: UIView {
    lazy var titleLabel = makeTitleLabel()
    lazy var tableContainer = makeTableContainer()
    lazy var tableView = makeTableView()
    lazy var preloader = makePreloader()
    
    private lazy var tableContainerHeight = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension FlashcardsTopicsView {
    func setup(flashcards: [FlashcardTopic]) {
        tableView.setup(flashcards: flashcards)
        
        tableView.layoutIfNeeded()
        
        let maxHeight = bounds.height
                    - (ScreenSize.isIphoneXFamily ? 111.scale : 83.scale)
                    - 16.scale
        let allCellsHeight = (CGFloat(flashcards.count) * FlashcardsTopicsTableCell.Constants.height)
                    + tableView.contentInset.top
                    + tableView.contentInset.bottom
        tableContainerHeight.constant = min(maxHeight, allCellsHeight)
    }
}

// MARK: Private
private extension FlashcardsTopicsView {
    func initialize() {
        backgroundColor = Appearance.main100
    }
}

// MARK: Make constraints
private extension FlashcardsTopicsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.scale),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 58.scale : 30.scale)
        ])
        
        tableContainerHeight = tableContainer.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            tableContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            tableContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            tableContainer.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 111.scale : 83.scale),
            tableContainerHeight
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: tableContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableContainer.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: tableContainer.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableContainer.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension FlashcardsTopicsView {
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.bold(size: 24.scale))
            .lineHeight(28.8.scale)
            .letterSpacing(-0.44.scale)
        
        let view = UILabel()
        view.attributedText = "FlashcardsTopics.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.mono100
        view.layer.cornerRadius = 12.scale
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 6.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> FlashcardsTopicsTableView {
        let view = FlashcardsTopicsTableView()
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = false
        view.contentInset = UIEdgeInsets(vertical: 16.scale)
        view.setContentOffset(CGPoint(x: 0, y: -16.scale), animated: false)
        view.separatorStyle = .none
        view.translatesAutoresizingMaskIntoConstraints = false
        tableContainer.addSubview(view)
        return view
    }
    
    func makePreloader() -> Spinner {
        let view = Spinner(size: CGSize(width: 60.scale, height: 60.scale))
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
