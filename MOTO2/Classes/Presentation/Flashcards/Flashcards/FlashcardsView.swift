//
//  FlashcardsView.swift
//  CDL
//
//  Created by Andrey Chernyshev on 10.06.2021.
//

import UIKit

final class FlashcardsView: UIView {
    lazy var closeButton = makeCloseButton()
    lazy var progressLabel = makeProgressLabel()
    lazy var flashCardContainer = makeFlashCardContainer()
    lazy var preloader = makePreloader()
    
    private lazy var progressAttrs = TextAttributes()
        .textColor(Appearance.mono200)
        .font(Fonts.Inter.semiBold(size: 17.scale))
        .lineHeight(20.scale)
        .textAlignment(.center)
        .letterSpacing(-0.44.scale)
    
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
extension FlashcardsView {
    func setup(progress: String) {
        progressLabel.attributedText = progress.attributed(with: progressAttrs)
    }
}

// MARK: Private
private extension FlashcardsView {
    func initialize() {
        backgroundColor = Appearance.main100
    }
}

// MARK: Make constraints
private extension FlashcardsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale),
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            flashCardContainer.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 8.scale),
            flashCardContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            flashCardContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            flashCardContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension FlashcardsView {
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Flashcards.Close"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeProgressLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeFlashCardContainer() -> FlashCardContainerView {
        let view = FlashCardContainerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> Spinner {
        let view = Spinner(size: CGSize(width: 60.scale, height: 60.scale))
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
