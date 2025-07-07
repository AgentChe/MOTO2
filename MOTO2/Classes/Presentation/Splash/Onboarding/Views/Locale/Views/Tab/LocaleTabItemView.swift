//
//  LocaleTabItemView.swift
//  CDL2
//
//  Created by Андрей Чернышев on 04.07.2025.
//

import UIKit

final class LocaleTabItemView: UIView {
    lazy var label = makeLabel()
    lazy var grabberView = makeGrabberView()
    
    private lazy var selectedAttrs = TextAttributes()
        .textColor(Appearance.mono200)
        .font(Fonts.Inter.semiBold(size: 17.scale))
        .lineHeight(20.scale)
        .textAlignment(.center)
        .letterSpacing(-0.44.scale)
    private lazy var normalAttrs = TextAttributes()
        .textColor(Appearance.mono200.withAlphaComponent(0.4))
        .font(Fonts.Inter.semiBold(size: 17.scale))
        .lineHeight(20.scale)
        .textAlignment(.center)
        .letterSpacing(-0.44.scale)
    
    private let text: String
    
    init(text: String) {
        self.text = text
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension LocaleTabItemView {
    func update(selected: Bool) {
        let attrs = selected ? selectedAttrs : normalAttrs
        label.attributedText = text.attributed(with: attrs)
        
        grabberView.isHidden = !selected
    }
}

// MARK: Private
private extension LocaleTabItemView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension LocaleTabItemView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12.scale)
        ])
        
        NSLayoutConstraint.activate([
            grabberView.widthAnchor.constraint(equalToConstant: 16.scale),
            grabberView.heightAnchor.constraint(equalToConstant: 6.scale),
            grabberView.centerXAnchor.constraint(equalTo: centerXAnchor),
            grabberView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension LocaleTabItemView {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeGrabberView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 3.scale
        view.backgroundColor = Appearance.main500
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
