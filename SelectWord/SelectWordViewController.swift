//
//  SelectWordViewController.swift
//  KFoodMenuScan
//
//  Created by yyjweber on 2022/08/16.
//

import UIKit
import MLKitTextRecognitionKorean
import MLKitVision


protocol SelectWordViewControllerDelegate {
    func didSelectImage(_ image: UIImage)
}

class SelectWordViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var currentImgView: UIImageView!
    @IBOutlet weak var selectedWord: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    
    var oriImage: UIImage!
    var delegate: SelectWordViewControllerDelegate?
    var wButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackButton()
        textRecognizer()
        setScollView()
        setSearchBtn()
        
    }
    
    private func addBackButton() {
            
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular, scale: .large)
        let imgObj = UIImage(systemName: "arrow.backward", withConfiguration: imgConfig)
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        let btnBack = UIButton(frame: CGRect(x: -15, y: 0, width: 60, height: 45))
        btnBack.setImage(imgObj, for: .normal)
        btnBack.tintColor = .black
        btnBack.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
        containerView.addSubview(btnBack)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: containerView)
        self.navigationController?.navigationBar.barTintColor = .white

    }
    
    @objc func backAction(_ sender: UIButton) {
        
       self.navigationController?.popViewController(animated: true)
    }
    
    private func setScollView(){
        
        scrollView.delegate = self
        scrollView.zoomScale = 1.0
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
    
        currentImgView.image = oriImage
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        print("--->> zoom in/out")
       
        return currentImgView
    }
    
    private func textRecognizer() {
        
        let koreanOptions = KoreanTextRecognizerOptions()
        let koreanTextRecognizer = TextRecognizer.textRecognizer(options: koreanOptions)
        let image = VisionImage(image: oriImage)
        
        koreanTextRecognizer.process(image) { result, error in
            guard error == nil, let result = result else {
                
                print("error")
                return
            }
            
            self.wButtons = []

            for block in result.blocks {
                
                print(block.frame)
                
                for line in block.lines {
                    for element in line.elements {
                        
                        print("element: \(element.text)")
                        let wBtnFrame = self.scaleOfSelectedWord(oriImgSize: self.oriImage.size, oriFeature: element.frame, crtViewSize: self.currentImgView.frame.size)
                        
                        let wButton = UIButton()
                        
                        wButton.tag = 0
                        wButton.setTitle(element.text, for: .normal)
                        wButton.setTitleColor(.clear, for: .normal)
                        wButton.frame = CGRect(x: wBtnFrame.origin.x, y: wBtnFrame.origin.y, width: wBtnFrame.size.width, height: wBtnFrame.size.height)
                        wButton.addLineDashedStroke(pattern: [4, 4], radius: 2, borderColor: UIColor.red, borderWidth: 1, backGroundColor: .clear)
                        wButton.addTarget(self, action: #selector(self.selectedWordClick), for: .touchUpInside)
                        self.currentImgView.addSubview(wButton)
                        
                        self.wButtons.append(wButton)
                        
                    }
               }
            }
        }
        
    }
    
    @objc func selectedWordClick(sender: UIButton) {
        
        switch sender.tag {
            
        case 1:
            sender.tag = 0
            sender.layer.sublayers?.filter{ $0 is CAShapeLayer }.forEach{ $0.removeFromSuperlayer() }
            sender.addLineDashedStroke(pattern: [4, 4], radius: 2, borderColor: UIColor.red, borderWidth: 1.5, backGroundColor: .clear)
            
            selectedWord.text = "\"Plese select a food name\""
            selectedWord.textColor = .lightGray
            selectedWord.font = UIFont.systemFont(ofSize: 17)
            
            searchBtn.isEnabled = false
            
        default:
            
            for item in wButtons {
                
                if item.tag == 1 {
                    
                    print("element: \(item.titleLabel!.text!)")
                    
                    item.tag = 0
                    item.layer.sublayers?.filter{ $0 is CAShapeLayer }.forEach{ $0.removeFromSuperlayer() }
                    item.addLineDashedStroke(pattern: [4, 4], radius: 2, borderColor: UIColor.red, borderWidth: 1.5, backGroundColor: .clear)
                    
                }
            }
            
            sender.tag = 1
            sender.layer.sublayers?.filter{ $0 is CAShapeLayer }.forEach{ $0.removeFromSuperlayer() }
            sender.addLineDashedStroke(pattern: [1, 0], radius: 2, borderColor: UIColor.red, borderWidth: 1.5, backGroundColor: UIColor.red.withAlphaComponent(0.4))
            
            selectedWord.text = sender.titleLabel?.text!
            selectedWord.textColor = .black
            selectedWord.font = UIFont.boldSystemFont(ofSize: 20)
            
            searchBtn.isEnabled = true
            
        }
        
    }
    
    private func scaleOfSelectedWord(oriImgSize: CGSize, oriFeature: CGRect, crtViewSize: CGSize) -> CGRect {
        
        let wOriImg = oriImgSize.width
        let hOriImg = oriImgSize.height
        
        let wCrtView = crtViewSize.width
        let hCrtView = crtViewSize.height
        
        var xcrtFeature: CGFloat
        var ycrtFeature: CGFloat
        var wcrtFeature: CGFloat
        var hcrtFeature: CGFloat
        
        if wOriImg < wCrtView {
            
            let wScale = wCrtView / wOriImg
            
            xcrtFeature = oriFeature.origin.x * wScale
            wcrtFeature = oriFeature.width * wScale

        } else {
            
            let wScale = wOriImg / wCrtView
            
            xcrtFeature = oriFeature.origin.x / wScale
            wcrtFeature = oriFeature.width / wScale
            
        }
        
        if hOriImg < hCrtView {
            
            let hScale = hCrtView / hOriImg
            
            ycrtFeature = oriFeature.origin.y * hScale
            hcrtFeature = oriFeature.height * hScale
            
        } else {
            
            let hScale = hOriImg / hCrtView
            
            ycrtFeature = oriFeature.origin.y / hScale
            hcrtFeature = oriFeature.height / hScale
            
        }
        
        return CGRect(x: xcrtFeature, y: ycrtFeature, width: wcrtFeature, height: hcrtFeature)
        
    }
    
    private func setSearchBtn () {
        
        searchBtn.addTarget(self, action: #selector(searchBtnClick(_:)), for: .touchUpInside)
        searchBtn.isEnabled = false
    
    }
    
    @objc func searchBtnClick(_ sender: UIButton) {
        
        print(selectedWord.text!)
        let storyBoard = UIStoryboard(name: "FoodList", bundle: nil)
        guard let controller = storyBoard.instantiateViewController(withIdentifier: "FoodList") as? FoodListViewController else {return}
                
        controller.pFdName = selectedWord.text!
        self.navigationController?.pushViewController(controller, animated: true)
        
    }

}



