//
//  FlashcardsFinishViewController.swift
//  CDL2
//
//  Created by Андрей Чернышев on 13.07.2025.
//

import UIKit
import RxSwift

final class FlashcardsFinishViewController: UIViewController {
    private let mainView: FlashcardsFinishView
    
    private lazy var disposeBag = DisposeBag()
    
    private init(count: Int) {
        mainView = FlashcardsFinishView(count: count)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Observable
            .merge(
                mainView.closeButton.rx.tap.asObservable(),
                mainView.finishButton.rx.tap.asObservable(),
            )
            .bind(to: Binder(self) { base, void in
                base.navigationController?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension FlashcardsFinishViewController {
    static func make(count: Int) -> FlashcardsFinishViewController {
        FlashcardsFinishViewController(count: count)
    }
}
