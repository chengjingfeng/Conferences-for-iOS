//
//  DetailSummaryViewController.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

class DetailSummaryViewController: UIViewController {

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .bold)

        l.lineBreakMode = .byTruncatingTail
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        l.allowsDefaultTighteningForTruncation = true
        l.numberOfLines = 1

        return l
    }()

    private lazy var summaryLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)

        l.lineBreakMode = .byWordWrapping
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        l.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        l.allowsDefaultTighteningForTruncation = true
        l.numberOfLines = 0

        return l
    }()

    private lazy var contextLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .tertiaryText
        l.lineBreakMode = .byTruncatingTail
        l.allowsDefaultTighteningForTruncation = true

        return l
    }()

    lazy var speakerView: HighlightView = HighlightView()

    private lazy var labelStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.titleLabel, self.summaryLabel, self.contextLabel])

        v.axis = .vertical
        v.alignment = .leading
        v.spacing = 24

        return v
    }()

    private lazy var stackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.labelStackView, self.speakerView])

        v.axis = .vertical

        v.alignment = .top
        v.distribution = .fill
        v.spacing = 24
        return v
    }()


    override func viewDidLoad() {
        setUpTheming()
        view.addSubview(stackView)

        speakerView.widthToSuperview()
        stackView.edgesToSuperview(insets: .init(top: 20, left: 20, bottom: 120, right: 20))
    }

    func configureView(with talk: TalkModel) {
        titleLabel.text = talk.title
        summaryLabel.text = talk.details ?? ""
        contextLabel.text = talk.tags.filter { !$0.contains("2019") && !$0.contains("2018") && !$0.contains("2017") && !$0.contains("2016")}.joined(separator: " • ")

        contextLabel.isHidden = contextLabel.text?.isEmpty ?? true
        speakerView.configureView(with: talk.speaker)
    }
}

extension DetailSummaryViewController: Themed {
    func applyTheme(_ theme: AppTheme) {
        view.backgroundColor = theme.backgroundColor
        titleLabel.textColor = theme.textColor
        summaryLabel.textColor = theme.secondaryTextColor
    }
}
