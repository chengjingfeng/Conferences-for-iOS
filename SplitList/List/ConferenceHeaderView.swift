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

    override init(frame: CGRect) {
        super.init(frame: frame)

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

    private lazy var textStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.titleLabel, self.subtitleLabel])

        v.axis = .vertical
        v.alignment = .leading
        v.distribution = .fill

        return v
    }()

    private lazy var stackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.logo, self.textStackView])

        v.alignment = .center
        v.distribution = .fill
        v.spacing = 15

        return v
    }()

    private func configureView() {
        let containerView = UIView()
        backgroundColor = UIColor.panelBackground
        containerView.layer.cornerRadius = 10
        containerView.backgroundColor = UIColor.elementBackground
        addSubview(containerView)
        containerView.edgesToSuperview(insets: .init(top: 10, left: 10, bottom: 10, right: 10))
        containerView.addSubview(stackView)
        stackView.edgesToSuperview(insets: .init(top: 10, left: 10, bottom: 10, right: 10))
    }

    func configureView(with conference: ConferenceViewModel) {
        titleLabel.text = conference.title
        subtitleLabel.text = conference.location

        guard let imageUrl = URL(string: conference.image) else { return }

        self.imageDownloadOperation?.cancel()
        //self.logo.image = NSImage(named: "placeholder-square")
        self.imageDownloadOperation = ImageDownloadCenter.shared.downloadImage(from: imageUrl, thumbnailHeight: 60) { [weak self] url, _, thumb in
            guard url == imageUrl, thumb != nil else { return }
            self?.logo.isHidden = false
            self?.logo.image = thumb
        }
    }
}
