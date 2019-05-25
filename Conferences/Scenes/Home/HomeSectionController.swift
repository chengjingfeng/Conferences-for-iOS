//
//  HomeSectionController.swift
//  Conferences
//
//  Created by Zagahr on 22/05/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

protocol HomeSectionControllerDelegate: class {
    func handle(section: HomeSection, item: ListRepresentable)
}

final class HomeSectionController: UIViewController {
    private let homeSection: HomeSection
    private var collectionView: UICollectionView!
    private let topicTitleLabel = UILabel()
    weak var delegate: HomeSectionControllerDelegate?

    init(with section: HomeSection, delegate: HomeSectionControllerDelegate) {
        self.homeSection = section
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTheming()
        configureCollectionView()
        configureView()
        configureConstraints()
    }

    func configureView() {
        view.addSubview(topicTitleLabel)
        view.addSubview(collectionView)
    }

    func configureConstraints() {
        if homeSection.size == .l {
            collectionView.edgesToSuperview(excluding: [], insets: .bottom(40), usingSafeArea: true)
        } else {
            collectionView.edgesToSuperview(excluding: [.top], insets: .init(top: 0, left: 0, bottom: 30, right: 0), usingSafeArea: true)
            topicTitleLabel.edgesToSuperview(excluding: [.bottom], insets: .init(top: 20, left: 20, bottom: 0, right: 0), usingSafeArea: true)
            collectionView.topToBottom(of: topicTitleLabel, offset: 20)
        }

         collectionView.height(collectionViewSize().height)
    }

    func configureCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 30
        flowLayout.minimumLineSpacing = 30

        collectionView =  UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.register(HomeSectionCell.self, forCellWithReuseIdentifier: HomeSectionCell.identifier)
        collectionView.clipsToBounds = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear

        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension HomeSectionController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeSection.items.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = homeSection.items[indexPath.row]
        delegate?.handle(section: homeSection, item: item)
    }
}

extension HomeSectionController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionViewCell(for: indexPath)
    }

    func collectionViewCell(for indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSectionCell.identifier, for: indexPath) as? HomeSectionCell else {

            return UICollectionViewCell()
        }

        let item = homeSection.items[indexPath.row]
        cell.configure(withViewModel: HomeSectionCell.Model(item: item, section: homeSection))

        return cell
    }
}

extension HomeSectionController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionViewSize()
    }

    func collectionViewSize() -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            switch homeSection.size {
            case .s:
                return CGSize(width: 140, height: 130)
            case .m:
                return CGSize(width: 270, height: 220)
            case .l:
                return CGSize(width: 510, height: 250)
            }
        } else {
            switch homeSection.size {
            case .s:
                return CGSize(width: 140, height: 130)
            case .m:
                return CGSize(width: 220, height: 170)
            case .l:
                return CGSize(width: collectionView.frame.width - 40, height: 200)
            }
        }
    }
}


extension HomeSectionController: Themed {
    func applyTheme(_ theme: AppTheme) {
        let title = homeSection.size == .l ? "" : (homeSection.title ?? "")
        let attributedString = NSMutableAttributedString(string: title)

        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: theme.textColor, range:NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.medium, range: NSRange(location: 0, length: attributedString.length))

        topicTitleLabel.attributedText = attributedString
    }
}
