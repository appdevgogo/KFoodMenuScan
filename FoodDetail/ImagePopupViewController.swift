//
//  ImagePopupViewController.swift
//  KFoodMenuScan
//
//  Created by yyjweber on 2022/08/29.
//

import UIKit
import SDWebImage

class ImagePopupViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var imgURL: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showImagePopup()
        
    }
    
    @IBAction func imagePopupCloseClick(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func showImagePopup() {
        
        switch self.imgURL {
            
        case "none", "":
            print("No image available")
            
        default :
            self.imageView.sd_setImage(with: URL(string: self.imgURL)!)

        }
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        
    }
    
}

