//
//  TagListView.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 02/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

class TagListView: UIInputView {
    
    init() {
        super.init(frame: .zero, inputViewStyle: .default)
        configureView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var tags = TagSyncService.shared.tags
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.delegate = self
        cv.dataSource = self
        cv.register(TagCell.self, forCellWithReuseIdentifier: "TagViewCell")
        cv.allowsMultipleSelection = false
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.allowsSelection = true
        
        if let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: 50, height: 20)
            layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5)
        }
        
        return cv
    }()
    
    func configureView() {
        allowsSelfSizing = true
        addSubview(collectionView)
        
        collectionView.edgesToSuperview()
        
        height(35)
        collectionView.reloadData()
    }
}

extension TagListView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagViewCell", for: indexPath) as? TagCell else { return UICollectionViewCell() }
        
        let tag = tags[indexPath.row]
        cell.configureView(with: tag)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var tag = tags[indexPath.row]
        tag.isActive.toggle()
        
        TagSyncService.shared.handleTag(&tag)
        self.tags = TagSyncService.shared.tags
        collectionView.reloadData()
    }
}
