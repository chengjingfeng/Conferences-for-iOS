//
//  DetailViewController.swift
//  Conferences
//
//  Created by Zagahr on 23/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit
import YoutubeKit
import TinyConstraints

class DetailViewController: UIViewController {
    private let watchlistButtom = UIBarButtonItem(image: UIImage(named: "watchlist"), style: .plain, target: self, action: #selector(addToWatchlist))
    private let watchedButton = UIBarButtonItem(image: UIImage(named: "watch"), style: .plain, target: self, action: nil)
    private let fullscreenButton = UIBarButtonItem(image: UIImage(named: "fullscreen"), style: .plain, target: self, action: #selector(triggerFullscreen))

    private weak var imageDownloadOperation: Operation?
    private var talkItem: TalkItem?
    private var wachlistAction: ((TalkItem) -> Void)?

    private lazy var blockingView: UIView = {
        let view = UIView()
        view.backgroundColor = .panelBackground

        return view
    }()

    private lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.alwaysBounceHorizontal = false
        return v
    }()

    private lazy var playerContainer: UIView = {
        let v = UIView(frame: .zero)
        v.addSubview(previewImage)
        v.addSubview(playButton)
        v.backgroundColor = .black
        previewImage.edgesToSuperview()
        playButton.centerInSuperview()

        previewImage.contentMode = .scaleAspectFit

        return v
    }()

    private lazy var previewImage = UIImageView()
    private var player: YTSwiftyPlayer?

    private lazy var detailSummaryViewController = DetailSummaryViewController()

    private lazy var playButton: UIButton = {
        let b = UIButton()
        b.setTitle("Play", for: .normal)
        b.addTarget(self, action: #selector(didSelectPlay), for: .touchUpInside)
        b.backgroundColor = UIColor.elementBackground
        b.layer.cornerRadius = 7
        b.width(60)

        return b
    }()

    private lazy var stackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.playerContainer, self.detailSummaryViewController.view])

        v.axis = .vertical
        v.spacing = 20

        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        navigationItem.largeTitleDisplayMode = .never
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice.current.userInterfaceIdiom == .phone {
            navigationController?.navigationBar.barTintColor = .black
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(pop))
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            navigationController?.interactivePopGestureRecognizer?.delegate = self
        }

        scrollView.setContentOffset(.zero, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.navigationBar.barTintColor = .panelBackground
    }

    @objc func pop() {
        navigationController?.popViewController(animated: true)
    }

    @objc func triggerFullscreen() {
        player?.evaluateJavaScript(###"document.getElementById("player").contentWindow.document.querySelector('video').webkitEnterFullscreen();"###, completionHandler: nil)
    }

    @objc func addToWatchlist() {
        guard var talkItem = self.talkItem else { return }
       talk.onWatchlist.toggle()

        let icon = talk.onWatchlist ? UIImage(named: "watchlist_filled") : UIImage(named: "watchlist")
        watchlistButtom.image = icon
    }

    func configureNavigationBar() -> UINavigationBar? {
        var items = [watchedButton, watchlistButtom]

        guard UIDevice.current.userInterfaceIdiom == .pad else {
            navigationItem.setRightBarButtonItems(items, animated: false)

            return nil
        }

        fullscreenButton.isEnabled = false
        items.insert(fullscreenButton, at: 0)
        let bar = UINavigationBar()
        bar.isTranslucent = false
        bar.delegate = self
        bar.barTintColor = .black
        bar.tintColor = .white
        let navItem = UINavigationItem(title: "")
        navItem.setRightBarButtonItems(items, animated: false)
        bar.items = [navItem]
        view.addSubview(bar)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true

        return bar
    }

    private func configureView() {
        view.backgroundColor = .panelBackground
        view.addSubview(scrollView)

        if let navigationBar = configureNavigationBar() {
            scrollView.edgesToSuperview(excluding: .top)
            scrollView.topToBottom(of: navigationBar)
        } else {
            scrollView.edgesToSuperview()
        }

        scrollView.addSubview(stackView)
        stackView.edgesToSuperview()
        stackView.width(to: view)
        addChild(detailSummaryViewController)
        playerContainer.height(to: view, offset: -view.frame.height * 0.4)

        view.addSubview(blockingView)
        blockingView.edgesToSuperview()
    }

    func configureView(with talkItem: TalkItem) {
        self.talkItem = talkItem

        let icon = talkItem.talk.onWatchlist ? UIImage(named: "watchlist_filled") : UIImage(named: "watchlist")
        watchlistButtom.image = icon

        fullscreenButton.isEnabled = false
        if blockingView.alpha == 1.0 {
            UIView.animate(withDuration: 0.2) {
                self.navigationController?.navigationBar.barTintColor = .black
                self.blockingView.alpha = 0
            }
        }


        detailSummaryViewController.configureView(with: talkItem.talk)
        player?.clearVideo()
        player?.removeFromSuperview()
        player = nil
        guard let imageUrl = URL(string: talkItem.talk.previewImage) else { return }

        self.imageDownloadOperation?.cancel()

        self.imageDownloadOperation = ImageDownloadCenter.shared.downloadImage(from: imageUrl, thumbnailHeight: 150) { [weak self] url, original, _ in
            guard url == imageUrl, original != nil else { return }

            self?.previewImage.image = original
        }
    }

    @objc func didSelectPlay() {
        player = YTSwiftyPlayer(
            frame: .zero,
            playerVars: [.videoID(talk!.videoId), .playsInline(false), .showControls(.show), .autoplay(true), .showFullScreenButton(false)])

        guard let player = player else { return }
        playerContainer.addSubview(player)
        player.edgesToSuperview()
        player.autoplay = true
        player.delegate = self
        player.loadPlayer()
    }
}

extension DetailViewController: YTSwiftyPlayerDelegate {
    func playerReady(_ player: YTSwiftyPlayer) {
        player.playVideo()
    }

    func player(_ player: YTSwiftyPlayer, didUpdateCurrentTime currentTime: Double) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            fullscreenButton.isEnabled = true
        }
    }
}

extension DetailViewController: UIGestureRecognizerDelegate, UINavigationControllerDelegate {}

extension DetailViewController: UINavigationBarDelegate {
    public func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
