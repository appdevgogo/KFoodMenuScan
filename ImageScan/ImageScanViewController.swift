//
//  ImageScanViewController.swift
//  KFoodMenuScan
//
//  Created by yyjweber on 2022/08/16.
//

import UIKit
import YPImagePicker

class ImageScanViewController: UIViewController, UINavigationControllerDelegate, SelectWordViewControllerDelegate {
    
    //var selectedImg: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        YPimagePicker()
    }
    
    private func YPimagePicker() {
        
        //ViewModel
        var config = YPImagePickerConfiguration()
        
        config.isScrollToChangeModesEnabled = false
        config.showsPhotoFilters = false
        config.hidesStatusBar = false
        config.hidesBottomBar = true
        config.startOnScreen = YPPickerScreen.library
        config.wordings.libraryTitle = "Albums"
        config.wordings.next = "Next"
        config.wordings.cancel = "Cencel"
        config.colors.tintColor = .black
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.systemGray2]
        
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            
            if let photo = items.singlePhoto {
                
                //self.selectedImg = photo.image
                
                print("Image Selected")
                
                let storyBoard = UIStoryboard(name: "SelectWord", bundle: nil)
                
                guard let controller = storyBoard.instantiateViewController(withIdentifier: "SelectWord") as? SelectWordViewController else {
                        return
                }
                controller.oriImage = photo.image
                controller.delegate = self
                
                self.navigationController?.pushViewController(controller, animated: true)
                
            }
            
            if cancelled {
                print("Picker was canceled")
                self.navigationController?.popViewController(animated: true)
                
            }
            picker.dismiss(animated: false, completion: nil)
        }
        present(picker, animated: true, completion: nil)
        
    }
    
    func didSelectImage(_ image: UIImage) {
        
        print(">>>> didSelectImage")
        
    }
    
}
