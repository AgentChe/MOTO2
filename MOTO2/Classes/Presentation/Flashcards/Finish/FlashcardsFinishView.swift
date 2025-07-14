//
//  FlashcardsFinishView.swift
//  CDL2
//
//  Created by Андрей Чернышев on 13.07.2025.
//

import UIKit

final class FlashcardsFinishView: UIView {
    lazy var closeButton = makeCloseButton()
    lazy var imageView = makeImageView()
    lazy var textLabel = makeTextLabel()
    lazy var finishButton = makeFinishButton()
    
    private let count: Int
    
    init(count: Int) {
        self.count = count
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension FlashcardsFinishView {
    func initialize() {
        backgroundColor = Appearance.main100
    }
}

// MARK: Make constraints
private extension FlashcardsFinishView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale),
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 240.scale),
            imageView.heightAnchor.constraint(equalToConstant: 231.scale),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 105.scale)
        ])
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 70.scale),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -70.scale),
            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 32.scale)
        ])
        
        NSLayoutConstraint.activate([
            finishButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            finishButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            finishButton.heightAnchor.constraint(equalToConstant: 48.scale),
            finishButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -38.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension FlashcardsFinishView {
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Flashcards.Close"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "FlashcardsFinish")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTextLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.semiBold(size: 19.scale))
            .lineHeight(27.scale)
            .letterSpacing(-0.44.scale)
            .textAlignment(.center)
        
        let text = String(format: "FlashcardsFinish.Text".localized, count)
        
        let view = UILabel()
        view.attributedText = text.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeFinishButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.semiBold(size: 17.scale))
        
        let view = UIButton()
        view.backgroundColor = Appearance.main300
        view.layer.cornerRadius = 8.scale
        view.setAttributedTitle("FlashcardsFinish.Button".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
