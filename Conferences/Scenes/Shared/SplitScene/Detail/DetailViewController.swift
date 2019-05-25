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
    private let watchlistButtom = UIBarButtonItem(image: UIImage(named: "watchlist"), style: .plain, target: nil, action: nil)
    private let watchedButton = UIBarButtonItem(image: UIImage(named: "watch"), style: .plain, target: nil, action: nil)
    private let fullscreenButton = UIBarButtonItem(image: UIImage(named: "fullscreen"), style: .plain, target: nil, action: nil)

    private weak var imageDownloadOperation: Operation?
    var talk: TalkModel?

    var wachlistAction: (() -> Void)?

    lazy var blockingView: UIView = {
        let view = UIView()

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
        previewImage.edgesToSuperview(excluding: [], insets: .bottom(20), usingSafeArea: true)
        playButton.centerInSuperview()

        previewImage.contentMode = .scaleAspectFit

        return v
    }()

    private lazy var previewImage = UIImageView()
    private var player: YTSwiftyPlayer?

    lazy var detailSummaryViewController = DetailSummaryViewController()

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

        setUpTheming()
        configureView()
        configureNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollView.setContentOffset(.zero, animated: false)

        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        guard let talk = talk else {
            return
        }

        configureView(with: talk)
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)

        let currentTheme = AppThemeProvider.shared.currentTheme
        navigationController?.navigationBar.barTintColor = currentTheme.backgroundColor
        navigationController?.navigationBar.tintColor = currentTheme.textColor 
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: currentTheme.textColor]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: currentTheme.textColor]
    }

    @objc func triggerFullscreen() {
        player?.evaluateJavaScript(###"document.getElementById("player").contentWindow.document.querySelector('video').webkitEnterFullscreen();"###, completionHandler: nil)
    }

    @objc func markAsWatched() {
        guard var talk = self.talk else { return }
        talk.watched.toggle()
        let icon = talk.watched ? UIImage(named: "watch_filled") : UIImage(named: "watch")
        watchedButton.image = icon
    }

    @objc func addToWatchlist() {
        guard let talk = self.talk else { return }

        Storage.shared.toggleWatchlist(talk, completion: { [weak self] (state) in
            self?.wachlistAction?()

            let icon = state ? UIImage(named: "watchlist_filled") : UIImage(named: "watchlist")
            self?.watchlistButtom.image = icon
        })
    }

    func configureNavigationBar() {
        var items = [watchedButton, watchlistButtom]

        if UIDevice.current.userInterfaceIdiom == .pad {
            fullscreenButton.isEnabled = false
            items.insert(fullscreenButton, at: 0)
        }

        navigationItem.setRightBarButtonItems(items, animated: false)
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    private func configureView() {
        extendedLayoutIncludesOpaqueBars = true
        hidesBottomBarWhenPushed = true
        watchlistButtom.target = self
        watchlistButtom.action = #selector(addToWatchlist)

        watchedButton.target = self
        watchedButton.action = #selector(markAsWatched)

        fullscreenButton.target = self
        fullscreenButton.action = #selector(triggerFullscreen)

        view.addSubview(scrollView)

        scrollView.edgesToSuperview()

        scrollView.addSubview(stackView)
        stackView.edgesToSuperview()
        stackView.width(to: view)
        addChild(detailSummaryViewController)
        playerContainer.height(to: view, offset: -view.frame.height * 0.4)

        if navigationController != nil {
            navigationController?.view.addSubview(blockingView)
            blockingView.edgesToSuperview()
        }
    }

    func configureView(with talk: TalkModel) {
        self.talk = talk
        let watchlistIcon = talk.onWatchlist ? UIImage(named: "watchlist_filled") : UIImage(named: "watchlist")
        watchlistButtom.image = watchlistIcon

        let watchedItem = talk.watched ? UIImage(named: "watch_filled") : UIImage(named: "watch")
        watchedButton.image = watchedItem

        fullscreenButton.isEnabled = false

        if blockingView.alpha == 1.0 {
            UIView.animate(withDuration: 0.2) {
                self.blockingView.alpha = 0
            }
        }

        detailSummaryViewController.configureView(with: talk)
        player?.clearVideo()
        player?.removeFromSuperview()
        player = nil

        previewImage.image = UIImage(named: "placeholder")
        guard let imageUrl = URL(string: talk.previewImage) else { return }

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

extension DetailViewController: Themed {
    func applyTheme(_ theme: AppTheme) {
        blockingView.backgroundColor = theme.backgroundColor
        view.backgroundColor = theme.backgroundColor
    }
}
