//
//  ConferenceHeaderView.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

class ConferenceHeaderView: UIView {

    private weak var imageDownloadOperation: Operation?
    private var leftSafeAreaInset: CGFloat = 0
    
    init(safeAreaInsets: UIEdgeInsets) {
        leftSafeAreaInset = safeAreaInsets.left
        
        super.init(frame: .zero)
        
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var logo: UIImageView = {
        let v = UIImageView(image: nil)
        v.layer.borderColor = UIColor.activeColor.cgColor
        v.layer.borderWidth = 2
        v.layer.cornerRadius = 30
        v.clipsToBounds = true

        v.height(60)
        v.width(60)

        return v
    }()

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .primaryText
        l.lineBreakMode = .byTruncatingTail
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return l
    }()

    private lazy var subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryText
        l.lineBreakMode = .byTruncatingTail

        return l
    }()

    private lazy var aboutLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .secondaryText

        l.lineBreakMode = .byWordWrapping
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        l.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        l.allowsDefaultTighteningForTruncation = true
        l.numberOfLines = 0

        return l
    }()

    private lazy var websiteButton: UIButton = {
        let b = UIButton(frame: .zero)
        b.height(20)
        b.width(20)
        b.tintColor = .white
        b.setImage(UIImage(named: "internet"), for: .normal)
        //b.addTarget(self, action: #selector(toggleWatchlist), for: .touchUpInside)

        return b
    }()

    private lazy var twitterButton: UIButton = {
        let b = UIButton(frame: .zero)
        b.height(20)
        b.width(20)
        b.tintColor = .white
        b.setImage(UIImage(named: "twitter"), for: .normal)
        //b.addTarget(self, action: #selector(toggleWatchlist), for: .touchUpInside)

        return b
    }()

    private lazy var eventButton: UIButton = {
        let b = UIButton(frame: .zero)
        b.height(20)
        b.width(20)
        b.tintColor = .white
        b.setImage(UIImage(named: "ticket"), for: .normal)
        //b.addTarget(self, action: #selector(toggleWatchlist), for: .touchUpInside)

        return b
    }()

    private lazy var socialMediaStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.websiteButton, self.twitterButton, self.eventButton])

        v.distribution = .fill
        v.spacing = 10

        return v
    }()

    private lazy var textStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.titleLabel, self.subtitleLabel])

        v.axis = .vertical
        v.alignment = .leading
        v.distribution = .fill

        return v
    }()

    private lazy var informationStackView: UIStackView = {
        let spacing = UIView()
        spacing.backgroundColor = UIColor.activeColor
        spacing.height(1)

        let v = UIStackView(arrangedSubviews: [self.textStackView, spacing, self.socialMediaStackView])

        spacing.widthToSuperview()
        v.axis = .vertical
        v.alignment = .leading
        v.spacing = 10

        return v
    }()

    private lazy var topStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.logo, self.informationStackView])

        v.alignment = .top
        v.distribution = .fill
        v.spacing = 15

        return v
    }()

    private lazy var stackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.topStackView, self.aboutLabel])

        self.topStackView.width(to: v)

        v.alignment = .top
        v.axis = .vertical
        v.distribution = .equalCentering
        v.spacing = 15

        return v
    }()

    private func configureView() {
        
        let containerView = UIView()
        backgroundColor = UIColor.panelBackground
        containerView.layer.cornerRadius = 10
        containerView.backgroundColor = UIColor.elementBackground
        addSubview(containerView)
        containerView.edgesToSuperview(insets: .init(top: 15, left: 15 + leftSafeAreaInset, bottom: 15, right: 15))
        containerView.addSubview(stackView)
        stackView.edgesToSuperview(insets: .init(top: 15, left: 15, bottom: 15, right: 15))
    }


    func configureView(with conference: ConferenceModel) {
        titleLabel.text = conference.name
        subtitleLabel.text = conference.location
        aboutLabel.text = conference.about

        guard let imageUrl = URL(string: conference.logo) else { return }

        self.imageDownloadOperation?.cancel()
        //self.logo.image = NSImage(named: "placeholder-square")
        self.imageDownloadOperation = ImageDownloadCenter.shared.downloadImage(from: imageUrl, thumbnailHeight: 100) { [weak self] url, _, thumb in
            guard url == imageUrl, thumb != nil else { return }
            self?.logo.isHidden = false
            self?.logo.image = thumb
        }
    }

}
