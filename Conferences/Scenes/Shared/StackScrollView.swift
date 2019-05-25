//
//  StackScrollView.swift
//  Conferences
//
//  Created by Zagahr on 22/05/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

class StackScrollView : UIScrollView {
    private let stackView = UIStackView()

    init() {
        super.init(frame: .zero)

        configureView()
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        stackView.axis = .vertical
        keyboardDismissMode = .onDrag

        addSubview(stackView)
    }

    func configureConstraints() {
        stackView.centerX(to: self)
        stackView.edgesToSuperview(excluding: [], insets: .top(30), usingSafeArea: false)
    }

    func addArrangedSubview(view: UIView) {
        stackView.addArrangedSubview(view)
    }
}

class StackView: UIView {
    private var backgroundView = UIView()
    private var stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.distribution = .fillProportionally

        addSubview(backgroundView)
        backgroundView.edgesToSuperview()
        addSubview(stackView)
        stackView.edgesToSuperview(excluding: [], insets: .init(top: 0, left: 10, bottom: 10, right: 0), usingSafeArea: true)
    }

    func addArrangedSubview(view: UIView) {
        stackView.addArrangedSubview(view)
    }

    func addBackgroundColor(_ color: UIColor) {
        backgroundView.backgroundColor = color
        backgroundView.alpha = 0.7
    }
}
