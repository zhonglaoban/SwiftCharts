//
//  ViewController.swift
//  SwiftCharts
//
//  Created by 1049056949@qq.com on 03/29/2018.
//  Copyright (c) 2018 1049056949@qq.com. All rights reserved.
//

import UIKit
import SwiftCharts

class ViewController: UIViewController {
    let dicts:[(String, Float, UIColor)] = [
        ("11111", 0.1, UIColor.red),
        ("2", 0.2, UIColor.blue),
        ("3", 0.3, UIColor.yellow),
        ("4444456644", 0.4, UIColor.orange)
    ]
    @IBOutlet weak var pieView: PieView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        pieView.showEmptyAnimation()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        pieView.drawSectors(dicts)
//        pieView.showEmptyAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

