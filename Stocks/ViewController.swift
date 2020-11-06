//
//  ViewController.swift
//  Stocks
//
//  Created by Mikhail Artsiukh on 11/6/20.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var companyNameLabel: UILabel!
    
    @IBOutlet weak var companyPickerView: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        companyNameLabel.text = "Tinkoff"
    }


}


