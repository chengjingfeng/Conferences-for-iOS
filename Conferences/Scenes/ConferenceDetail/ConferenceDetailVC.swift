//
//  ConferenceDetailVC.swift
//  Conferences
//
//  Created by Zagahr on 05/05/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

class ConferenceDetailVC: UIViewController {
    private var conference: ConferenceViewModel

    init(model: ConferenceViewModel) {
        self.conference = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureNavBar()
    }

    func configureView() {
        view.backgroundColor = .panelBackground
        title = conference.title
    }

    func configureNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationController?.navigationBar.barTintColor = UIColor.panelBackground
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        navigationController?.navigationBar.tintColor = UIColor.white
        //navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        //navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    @objc func dismissVC(){
        self.dismiss(animated: true)
    }
}
