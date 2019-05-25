//
//  LoadingViewController.swift
//  Conferences
//
//  Created by Zagahr on 04/05/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

protocol LoadingDelegate: class {
    func didFinish()
}

final class LoadingViewController: UIViewController {

    internal var delegate: LoadingDelegate
    internal var loadingView: BlockingLoadingView

    init(delegate: LoadingDelegate) {
        self.delegate = delegate
        self.loadingView = BlockingLoadingView(image: UIImage(named: "play-frame")!, size: CGSize(width: 60, height: 60), backgroundColor: UIColor.panelBackground)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLoadingView()
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.setup), userInfo: nil, repeats: false)
    }

    @objc func setup() {
        let group = DispatchGroup()

        group.enter()
        APIClient.shared.fetchConferences { [weak self] (error) in
            if error != nil {
                self?.showRetryConnectAlertView()
                return
            }

            group.leave()
        }

        group.enter()
        Config.shared.fetchColudValues {
            group.leave()
        }

        group.notify(queue: .main) {
            self.delegate.didFinish()
        }
    }

    func configureLoadingView() {
        view.addSubview(loadingView)
        addLoadingIndicator()
    }

    func addLoadingIndicator() {
        let loadingIndcator = UIActivityIndicatorView(style: .white)
        loadingIndcator.startAnimating()
        view.addSubview(loadingIndcator)

        loadingIndcator.centerXToSuperview()
        loadingIndcator.centerInSuperview(offset: .init(x: 0, y: 70), priority: .defaultLow, isActive: true, usingSafeArea: true)
    }

    func showRetryConnectAlertView() {

        let alert = UIAlertController(title: "Keine Internetverbindung", message: "Bei der Einrichtung der App ist ein Fehler aufgetreten. Bitte stelle sicher, dass Du eine Internetverbindung hast und versuche es erneut", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Erneut versuchen", style: .default, handler: { (_) in
            self.setup()
        }))

        alert.addAction(UIAlertAction(title: "Einstellungen", style: .default, handler: { (_) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                self.setup()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
}

internal class BlockingLoadingView: UIView {

    public init(image: UIImage, size: CGSize, backgroundColor: UIColor) {
        super.init(frame: (UIScreen.main.bounds))
        let imageView = UIImageView(image: image)
        imageView.tintColor = UIColor.white
        imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.center = self.center

        self.addSubview(imageView)
        self.backgroundColor = backgroundColor
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

