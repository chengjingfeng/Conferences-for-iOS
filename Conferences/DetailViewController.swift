
//
//  DetailViewController.swift
//  Conferences
//
//  Created by Zagahr on 23/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.panelBackground
        navigationController?.navigationBar.barTintColor = UIColor.elementBackground
        navigationController?.navigationBar.tintColor = UIColor.elementBackground

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
}

