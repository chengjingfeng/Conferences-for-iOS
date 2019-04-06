//
//  SearchViewController.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 02/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

protocol TagButtonDelegate {
  func didSelectTag(_ tag: TagModel)
}

class TagButton: UIButton {
  
    private var delegate: TagButtonDelegate?
    private var tagModel: TagModel?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        setup()
        super.layoutSubviews()
     }
    
    func setTag(to tag: TagModel) {
        self.tagModel = tag
        setup()
    }
    
    func setDelegate(to: TagButtonDelegate?) {
        self.delegate = to
    }

    func setup() {
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth  = 1
        self.titleLabel?.font = .systemFont(ofSize: 13)
        self.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
       
        self.setTitle(tagModel?.title, for: .normal)
       
        self.addTarget(self, action: #selector(self.tap), for: .touchUpInside)
        
        setColors()
     }
  
    func setColors() {
        if let tm = self.tagModel {
            let textColor          = tm.isActive ?  UIColor.inactiveButton : UIColor.primaryText
            self.backgroundColor   = tm.isActive ? UIColor.primaryText : UIColor.inactiveButton
            self.layer.borderColor = textColor.cgColor
            self.setTitleColor(textColor, for: .normal)
        }
    }
  
    @objc func tap() {
        self.tagModel?.isActive.toggle()
        self.setColors()
      
        if let t = self.tagModel {
            delegate?.didSelectTag(t)
        }
    }

}
