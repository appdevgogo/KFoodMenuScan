//
//  MainViewController.swift
//  KFoodMenuScan
//
//  Created by yyjweber on 2022/08/16.
//

import UIKit

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cameraScanClick(_ sender: Any) {
        
        let storyBoard = UIStoryboard(name: "CameraScan", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "CameraScan")
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    @IBAction func imageScanClick(_ sender: Any) {
        
        let storyBoard = UIStoryboard(name: "ImageScan", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "ImageScan")
        self.navigationController?.pushViewController(controller, animated: true)
    }

}

