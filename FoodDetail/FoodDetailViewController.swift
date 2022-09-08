//
//  FoodDetailViewController.swift
//  KFoodMenuScan
//
//  Created by yyjweber on 2022/08/26.
//

import UIKit
import Alamofire
import SDWebImage
import AVFoundation
import NVActivityIndicatorView

class FoodDetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var fdNameKR: UILabel!
    @IBOutlet weak var fdNameENP: UILabel!
    @IBOutlet weak var fdNameEN: UILabel!
    @IBOutlet weak var fdNameSound: UIButton!
    @IBOutlet weak var fdImage: UIImageView!
    
    @IBOutlet weak var fdDescriptTitle: UILabel!
    @IBOutlet weak var fdDescriptContents: UILabel!
    
    @IBOutlet weak var fdIngtsTitle: UILabel!
    @IBOutlet weak var fdIngtsContents: UILabel!

    @IBOutlet weak var bottomGuideline: UILabel!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tabBar: UIView!
    
    var pFdCode: String = ""
    var imgURL: String = ""
    
    var loadingIndicator = SetActivityIndicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitialLayout()
        getKFoodDetail(fdcode: pFdCode)
        
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
    
    private func setInitialLayout(){
        
        view.addSubview(loadingIndicator.bgView)
        loadingIndicator.showIndicator()
        
        addBackButton()
        
        tabBar.addTopBorderWithColor(color: UIColor.systemGray5, width: 1.0)
        
        fdNameKR.textColor = .clear
        fdNameENP.textColor = .clear
        fdNameEN.textColor = .clear
        
        fdNameSound.tintColor = .clear
        fdNameSound.isEnabled = false
        
        fdDescriptTitle.setfdDetailTitle(selfLabel: fdDescriptTitle)
        fdDescriptTitle.backgroundColor = .basicSkyBlue
        fdDescriptContents.textColor = .clear

        fdIngtsTitle.setfdDetailTitle(selfLabel: fdIngtsTitle)
        fdIngtsTitle.backgroundColor = .basicPurple
        fdIngtsContents.textColor = .clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(fdImageDetail))
        
        fdImage.layer.cornerRadius = self.fdImage.frame.width/8.0
        fdImage.layer.masksToBounds = true
        fdImage.isUserInteractionEnabled = true
        fdImage.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func fdImageDetail() {
        
        print("********** fdImage Click **********")
        
        let storyboard = UIStoryboard(name: "ImagePopup", bundle: nil)
        guard let imagePopup = storyboard.instantiateViewController(withIdentifier: "ImagePopup") as? ImagePopupViewController else {return}
        imagePopup.imgURL = imgURL
        
        imagePopup.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        imagePopup.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(imagePopup, animated: true, completion: nil)
        
    }
    
    
    @IBAction func fdNameSoundClick(_ sender: UIButton) {
        
        print("************ sound click ************")
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: fdNameKR.text ?? "")
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        utterance.rate = 0.4
        synthesizer.speak(utterance)
        
    }
    
    @IBAction func backToMain(_ sender: UIButton) {
        
        self.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func backToCameraScan(_ sender: UIButton) {
        
        self.navigationController?.popToSpecificVC(storyboardID: "CameraScan", viewControllerID: "CameraScan", currentNavigationController: self.navigationController!)
        
    }

    @IBAction func backToImageScan(_ sender: UIButton) {
        
        self.navigationController?.popToSpecificVC(storyboardID: "ImageScan", viewControllerID: "ImageScan", currentNavigationController: self.navigationController!)

    }
    
    func getKFoodDetail(fdcode: String) {
        
        let parameters = ["fdcode" : fdcode]
        let request = AF.request(EndPoint.getKFoodDetail.rawValue, parameters: parameters)
        
        request.validate(statusCode: 200..<300)
            //.validate(contentType: ["application/json"])
            .responseDecodable(of: KFoodDetail.self){ response in
                switch response.result {
                    
                case .success:
                    print("getKFoodList Validation Successful")
                    print(response.value!)
                    
                    self.imgURL = response.value!.fdpicurl
                    
                    switch self.imgURL {
                        
                    case "none", "":
                        print("No image available")
                        self.fdImage.tag = 0
                        self.fdImage.image = UIImage(named: "no_image")
                        
                    default :
                        self.fdImage.tag = 1
                        self.fdImage.sd_setImage(with: URL(string: self.imgURL)!)
                        
                    }
                    
                    self.fdNameKR.text = response.value?.fdnamekr
                    self.fdNameENP.text = response.value?.fdnameenp
                    self.fdNameEN.text = response.value?.fdnameen
                    
                    switch response.value?.fddescript {
                        
                    case "none", "":
                        self.fdDescriptContents.text = "\" There is no information available \""
                        
                    default :
                        self.fdDescriptContents.text = response.value?.fddescript
                        
                    }
                    
                    switch response.value?.fdingts {
                        
                    case "none", "":
                        self.fdIngtsContents.text = "\" There is no information available \""
                        
                    default :
                        self.fdIngtsContents.attributedText = self.bulletPointList(strings: (response.value?.fdingts.components(separatedBy: " // "))!)
                        
                    }
                    
                    DispatchQueue.main.async {
                        print(self.bottomGuideline.frame.origin.y)
                        self.contentView.setfdDetailScrollContentHight(selfView: self.contentView, guidelineLabel: self.bottomGuideline)
                    }
                    
                    self.fdNameKR.textColor = .black
                    self.fdNameENP.textColor = .black
                    self.fdNameEN.textColor = .black
                    self.fdNameSound.tintColor = .black
                    self.fdNameSound.isEnabled = true
                    self.fdDescriptContents.textColor = .black
                    self.fdIngtsContents.textColor = .black
                    
                    self.loadingIndicator.removeIndicator()
                    
                    
                case let .failure(error):
                    print(error)
                }
            }
        
    }
    
    func bulletPointList(strings: [String]) -> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 15
        paragraphStyle.minimumLineHeight = 20
        paragraphStyle.maximumLineHeight = 20
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 15)]

        let stringAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]

        let string = strings.map({ "•\t\($0)" }).joined(separator: "\n")

        return NSAttributedString(string: string,
                                  attributes: stringAttributes)
    }

}

struct KFoodDetail: Decodable {
    
    let fdcode: String
    let fdnamekr: String
    let fdnameen: String
    let fdnameenp: String
    let fddescript: String
    let fdnamevcurl: String
    let fdpicurl: String
    let fdingts: String
    
}
