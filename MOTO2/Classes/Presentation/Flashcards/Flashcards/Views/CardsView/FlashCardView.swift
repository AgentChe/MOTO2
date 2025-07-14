//
//  FlashCardView.swift
//  CDL
//
//  Created by Vitaliy Zagorodnov on 12.06.2021.
//

import UIKit
import AVFoundation

protocol FlashCardDelegate: AnyObject {
    func moved()
    func tapAction(id: Int, isKnew: Bool)
}

final class FlashCardView: UIView {
    weak var delegate: FlashCardDelegate?
    
    private var id: Int?
    private var player: AVPlayer?
    
    private lazy var contentView = makeContentView()
    private lazy var topicNameLabel = makeTopicNameLabel()
    private lazy var questionLabel = makeQuestionLabel()
    private lazy var answerLabel = makeAnswerLabel()
    private lazy var scrollView = makeScrollView()
    private lazy var stackView = makeStackView()
    private lazy var showAnswerButton = makeShowAnswerButton()
    private lazy var knowButton = makeKnowButton()
    private lazy var stillLearningButton = makeStillLearningButton()
    
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
extension FlashCardView {
    func setup(element: FlashCardModel) {
        id = element.id
        topicNameLabel.attributedText = element.topicName.attributed(with: .nameAttrs)
        questionLabel.attributedText = attributedString(for: element.question, attr: .questionAttrs, style: "semibold")
        answerLabel.attributedText = attributedString(for: element.answer, attr: .answerAttrs, style: "medium")
        
        configureContent(content: element.content)
    }
    
    func moveToThis() {
        showAnswerButton.isHidden = false
        
        player?.play()
    }
}

// MARK: UIGestureRecognizerDelegate
extension FlashCardView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    // Игнорим гестуру в области ответственности UIScrollView
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !scrollView.bounds.contains(touch.location(in: scrollView))
    }
}

// MARK: Private
private extension FlashCardView {
    enum Action {
        case left, right
    }
    
    func initialize() {
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeToLeft))
        leftSwipeGestureRecognizer.direction = .left
        leftSwipeGestureRecognizer.delegate = self
        addGestureRecognizer(leftSwipeGestureRecognizer)
        
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeToRight))
        rightSwipeGestureRecognizer.direction = .right
        rightSwipeGestureRecognizer.delegate = self
        addGestureRecognizer(rightSwipeGestureRecognizer)
        
        backgroundColor = UIColor.clear
    }
    
    func attributedString(for string: String, attr: TextAttributes, style: String) -> NSAttributedString? {
        guard let font = attr.font, !string.isEmpty else {
            return string.attributed(with: attr)
        }
        
        let htmlWithStyle = "<span style=\"font-family: \(font.fontName); font-style: \(style); font-size: \(font.pointSize); line-height: 27px;\">\(string)</span>"
        let data = Data(htmlWithStyle.utf8)
        
        let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil
        )
        
        return attributedString ?? string.attributed(with: attr)
    }
    
    func configureContent(content: FlashCardModel.Content) {
        var contentView: UIView?
        switch content {
        case let .image(url):
            let imageView = makeImageView()
            contentView = imageView
            let queue = DispatchQueue.global(qos: .utility)
                queue.async { [weak imageView] in
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            imageView?.image = UIImage(data: data)
                        }
                    }
                }
        case let .video(url):
            let videoView = makeVideoView()
            contentView = videoView
            let player = AVPlayer(url: url)
            self.player = player
            videoView.player = player
        case .none:
            contentView = nil
        }
        
        if let contentView = contentView {
            contentView.heightAnchor.constraint(equalToConstant: 160.scale).isActive = true
            stackView.insertArrangedSubview(contentView, at: 0)
        }
    }
    
    @objc
    func tapShowAnswer() {
        showAnswerButton.isHidden.toggle()
        knowButton.isHidden.toggle()
        stillLearningButton.isHidden.toggle()
        answerLabel.isHidden.toggle()
    }
    
    @objc
    func tapKnow() {
        if let id = id {
            selectedAnswer(know: true, id: id)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: { [weak self] in
            self?.cardMoved(action: .right)
        })
    }
    
    @objc
    func tapStillLearning() {
        if let id = id {
            selectedAnswer(know: false, id: id)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: { [weak self] in
            self?.cardMoved(action: .left)
        })
    }
    
    @objc
    func swipeToLeft() {
        if let id = id {
            selectedAnswer(know: false, id: id)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: { [weak self] in
            self?.cardMoved(action: .left)
        })
    }
    
    @objc
    func swipeToRight() {
        if let id = id {
            selectedAnswer(know: true, id: id)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: { [weak self] in
            self?.cardMoved(action: .right)
        })
    }
    
    func selectedAnswer(know: Bool, id: Int) {
        contentView.backgroundColor = know ? Appearance.system200.withAlphaComponent(0.2) : Appearance.system100.withAlphaComponent(0.2)
        contentView.layer.borderWidth = 1.scale
        contentView.layer.borderColor = know ? Appearance.system200.cgColor : Appearance.system100.cgColor
        
        knowButton.backgroundColor = know ? Appearance.system200.withAlphaComponent(0.2) : Appearance.main200
        knowButton.layer.borderWidth = know ? 1.scale : 0
        knowButton.layer.borderColor = know ? Appearance.system200.cgColor : UIColor.clear.cgColor
        
        stillLearningButton.backgroundColor = !know ? Appearance.system100.withAlphaComponent(0.2) : Appearance.main200
        stillLearningButton.layer.borderWidth = !know ? 1.scale : 0
        stillLearningButton.layer.borderColor = !know ? Appearance.system100.cgColor : UIColor.clear.cgColor
        
        knowButton.isUserInteractionEnabled = false
        stillLearningButton.isUserInteractionEnabled = false
        
        delegate?.tapAction(id: id, isKnew: know)
    }
    
    func cardMoved(action: Action) {
        player?.pause()
        
        let value: CGFloat = action == .left ? -1 : 1
        let finishPoint = CGPoint(x: value * frame.size.width * 2, y: frame.size.height)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.center = finishPoint
        }, completion: { [weak self] _ in
            self?.removeFromSuperview()
            
            self?.delegate?.moved()
        })
    }
}

// MARK: Make constraints
private extension FlashCardView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale),
            contentView.bottomAnchor.constraint(equalTo: knowButton.topAnchor, constant: -24.scale)
        ])
        
        NSLayoutConstraint.activate([
            topicNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24.scale),
            topicNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topicNameLabel.bottomAnchor, constant: 2.scale),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.scale),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24.scale),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2.scale)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            showAnswerButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            showAnswerButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            showAnswerButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -40.scale),
            showAnswerButton.heightAnchor.constraint(equalToConstant: 48.scale)
        ])
        
        NSLayoutConstraint.activate([
            knowButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            knowButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            knowButton.bottomAnchor.constraint(equalTo: stillLearningButton.topAnchor, constant: -12.scale),
            knowButton.heightAnchor.constraint(equalToConstant: 48.scale)
        ])
        
        NSLayoutConstraint.activate([
            stillLearningButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16.scale),
            stillLearningButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            stillLearningButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            stillLearningButton.heightAnchor.constraint(equalToConstant: 48.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension FlashCardView {
    func makeContentView() -> UIView {
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
    
    func makeTopicNameLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeQuestionLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(view)
        return view
    }
    
    func makeAnswerLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(view)
        return view
    }
    
    func makeShowAnswerButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.semiBold(size: 17.scale))
            .letterSpacing(-0.44.scale)
        
        let view = UIButton()
        view.isHidden = true
        view.setAttributedTitle("Flashcards.ShowAnswer".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.main200
        view.layer.cornerRadius = 8.scale
        view.addTarget(self, action: #selector(tapShowAnswer), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeKnowButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.semiBold(size: 17.scale))
            .letterSpacing(-0.44.scale)
        
        let view = UIButton()
        view.isHidden = true
        view.setAttributedTitle("Flashcards.Know".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.main200
        view.layer.cornerRadius = 8.scale
        view.addTarget(self, action: #selector(tapKnow), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeStillLearningButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.semiBold(size: 17.scale))
            .letterSpacing(-0.44.scale)
        
        let view = UIButton()
        view.isHidden = true
        view.setAttributedTitle("Flashcards.StillLearning".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.main200
        view.layer.cornerRadius = 8.scale
        view.addTarget(self, action: #selector(tapStillLearning), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeVideoView() -> AVPlayerView {
        let view = AVPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.contentInset = UIEdgeInsets(vertical: 24.scale)
        view.setContentOffset(CGPoint(x: 0, y: -24.scale), animated: false)
        view.bounces = false
        view.alwaysBounceHorizontal = false
        view.isDirectionalLockEnabled = true 
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.alignment = .fill
        view.distribution = .fill
        view.axis = .vertical
        view.spacing = 8.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
}

// MARK: Additional
private extension TextAttributes {
    static let questionAttrs = TextAttributes()
        .textColor(Appearance.mono200)
        .font(Fonts.Inter.semiBold(size: 19.scale))
        .lineHeight(27.scale)
        .textAlignment(.center)
        .letterSpacing(-0.44.scale)
    
    static let answerAttrs = TextAttributes()
        .textColor(Appearance.mono300)
        .font(Fonts.Inter.medium(size: 19.scale))
        .lineHeight(27.scale)
        .textAlignment(.center)
        .letterSpacing(-0.44.scale)
    
    static let nameAttrs = TextAttributes()
        .textColor(Appearance.mono300)
        .font(Fonts.Inter.medium(size: 14.scale))
        .lineHeight(20.scale)
        .textAlignment(.center)
        .letterSpacing(-0.14.scale)
}
