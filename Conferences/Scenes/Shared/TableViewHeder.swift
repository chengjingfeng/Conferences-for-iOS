//
//  TableViewHeder.swift
//  Conferences
//
//  Created by Zagahr on 25/05/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

final class TableViewHeader: UIView {
    let highlightView = HighlightView()

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 200))

        configureView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureView() {
        addSubview(highlightView)
        highlightView.edgesToSuperview(excluding: [], insets: .init(top: 10, left: 10, bottom: 10, right: 10), usingSafeArea: false)
    }

    func configureView(with model: ListRepresentable?) {
        highlightView.configureView(with: model!)
    }
}

