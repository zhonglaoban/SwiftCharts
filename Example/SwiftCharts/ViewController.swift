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
    let dicts:[(String?, Float, UIColor)] = [
        ("11111", 0.1, UIColor.red),
        ("2", 0.2, UIColor.blue),
        ("3", 0.3, UIColor.yellow),
        ("4444456644", 0.4, UIColor.orange)
    ]
    let iconDicts:[(UIImage?, String?, Float, UIColor)] = [
        (UIImage(named:"moren"), "11111", 0.1, UIColor.red),
        (UIImage(named:"others"), "2", 0.2, UIColor.blue),
        (UIImage(named:"moren"), "3", 0.3, UIColor.yellow),
        (UIImage(named:"others"), "4444456644", 0.4, UIColor.orange)
    ]
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBAction func btn1Click(_ sender: Any) {
        pieView.showEmptyAnimation()
    }
    @IBAction func btn2Click(_ sender: Any) {
        pieView.drawPurePie(dicts)
    }
    @IBAction func btn3Click(_ sender: Any) {
        pieView.drawIconPie(iconDicts)
    }
    @IBOutlet weak var pieView: PieView!
    
    func initUI(){
        btn1.setTitle("占位动画", for: .normal)
        btn2.setTitle("圆点图例", for: .normal)
        btn3.setTitle("图标图例", for: .normal)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

