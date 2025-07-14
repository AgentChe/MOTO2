//
//  FlashcardsTableCell.swift
//  CDL
//
//  Created by Andrey Chernyshev on 10.06.2021.
//

import UIKit
import Kingfisher

final class FlashcardsTopicsTableCell: UITableViewCell {
    enum Constants {
        static let height = 117.scale
    }
    
    lazy var pictureView = makeImageView()
    lazy var labelsContainer = makeLabelsContainer()
    lazy var nameLabel = makeLabel()
    lazy var countLabel = makeLabel()
    lazy var arrowView = makeArrowView()
    lazy var separator = makeSeparator()
    
    private lazy var nameAttrs = TextAttributes()
        .textColor(Appearance.mono200)
        .font(Fonts.Inter.semiBold(size: 15.scale))
        .lineHeight(18.scale)
        .textAlignment(.left)
        .letterSpacing(-0.44.scale)
    private lazy var countAttrs = TextAttributes()
        .textColor(Appearance.mono300)
        .font(Fonts.Inter.medium(size: 14.scale))
        .lineHeight(20.scale)
        .textAlignment(.left)
        .letterSpacing(-0.14.scale)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        pictureView.kf.cancelDownloadTask()
        pictureView.image = nil
    }
}

// MARK: Public
extension FlashcardsTopicsTableCell {
    func setup(flashcard: FlashcardTopic) {
        if let imageUrl = URL(string: flashcard.imageUrl) {
            pictureView.kf.setImage(with: imageUrl)
        }
        
        nameLabel.attributedText = flashcard.name.attributed(with: nameAttrs)
        countLabel.attributedText = String(format: "FlashcardsTopics.Count".localized, flashcard.count).attributed(with: countAttrs)
    }
}

// MARK: Private
private extension FlashcardsTopicsTableCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension FlashcardsTopicsTableCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            pictureView.widthAnchor.constraint(equalToConstant: 85.scale),
            pictureView.heightAnchor.constraint(equalToConstant: 85.scale),
            pictureView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            pictureView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            labelsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 113.scale),
            labelsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -56.scale),
            labelsContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: labelsContainer.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: labelsContainer.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: labelsContainer.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4.scale),
            countLabel.leadingAnchor.constraint(equalTo: labelsContainer.leadingAnchor),
            countLabel.trailingAnchor.constraint(equalTo: labelsContainer.trailingAnchor),
            countLabel.bottomAnchor.constraint(equalTo: labelsContainer.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: 24.scale),
            arrowView.heightAnchor.constraint(equalToConstant: 24.scale),
            arrowView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.scale),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension FlashcardsTopicsTableCell {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.layer.cornerRadius = 12.scale
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabelsContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        labelsContainer.addSubview(view)
        return view
    }
    
    func makeArrowView() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "FlashcardsTopics.Arrow")
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.mono300.withAlphaComponent(0.16)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
