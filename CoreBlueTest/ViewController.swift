//
//  ViewController.swift
//  CoreBlueTest
//
//  Created by Jhen Mu on 2022/1/25.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        BlueTooth.instance.scanForPeripheralsWithService(<#T##serviceUUID: [CBUUID]?##[CBUUID]?#>, options: <#T##[String : AnyObject]?#>)
        
        BlueTooth.instance.stopScan()
        
        BlueTooth.instance.writeToPeripheral(<#T##data: Data##Data#>)
        
        // Do any additional setup after loading the view.
    }


}

