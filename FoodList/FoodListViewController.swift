//
//  FoodListViewController.swift
//  KFoodMenuScan
//
//  Created by yyjweber on 2022/08/16.
//

import UIKit
import Alamofire
import SDWebImage

class FoodListViewController: UIViewController, UIScrollViewDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabBar: UIView!
    
    var kFoodList: [KFoodList] = []
    var kFoodListTemp: [KFoodList] = []
    
    //var fdCode: String = ""
    var pFdName: String = ""
    var mPageNum: Int = 1
    var totalCount: Int = 0
    
    var loadingIndicator = SetActivityIndicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitialLayout()
        getKFoodList(fdnamekr: pFdName, page: String(mPageNum))
        
    }
    
    private func setInitialLayout() {
        
        view.addSubview(loadingIndicator.bgView)
        loadingIndicator.showIndicator()
        
        addBackButton()
        
        tabBar.addTopBorderWithColor(color: UIColor.systemGray5, width: 1.0)
        
        tableView.rowHeight = 185.0
        
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
    
    @IBAction func backToMain(_ sender: UIButton) {
        
        self.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func backToCameraScan(_ sender: UIButton) {
        
        self.navigationController?.popToSpecificVC(storyboardID: "CameraScan", viewControllerID: "CameraScan", currentNavigationController: self.navigationController!)
        
    }

    @IBAction func backToImageScan(_ sender: UIButton) {
        
        self.navigationController?.popToSpecificVC(storyboardID: "ImageScan", viewControllerID: "ImageScan", currentNavigationController: self.navigationController!)

    }
    
    func getKFoodList(fdnamekr: String, page: String) {
        
        let parameters = ["fdnamekr" : fdnamekr, "page" : page]
        let request = AF.request(EndPoint.getKFoodList.rawValue, parameters: parameters)
        
        request.validate(statusCode: 200..<300)
            //.validate(contentType: ["application/json"])
            .responseDecodable(of: KFoodInfo.self){ response in
                switch response.result {
                    
                case .success:
                    print("getKFoodList Validation Successful")
                    //print(response.value?.records ?? [])
                    self.totalCount = response.value?.totalcount ?? 1
                    self.kFoodListTemp = response.value?.records ?? []
                    self.kFoodList.append(contentsOf: self.kFoodListTemp)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.loadingIndicator.removeIndicator()
                    }
                    
                case let .failure(error):
                    print(error)
                }
            }
        
    }

}

extension FoodListViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("--->> tableView numberOfRowsInSection")
        
        return kFoodList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("--->> tableView cellForRowAt")
        
        print("------------->> IndexPath")
        print(indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodListCustomCell", for: indexPath) as! FoodListCustomCell
        
        let hFdnamekr = kFoodList[indexPath.row].fdnamekr
        let attrString : NSMutableAttributedString = NSMutableAttributedString(string: hFdnamekr)
        let range = (hFdnamekr as NSString).range(of: pFdName, options: .caseInsensitive)
        attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red , range: range)
        
        let imgURL = kFoodList[indexPath.row].fdpicurl
        
        switch imgURL {
            
        case "none", "":
            print("No image available")
            cell.fdImage.image = UIImage(named: "no_image")
            
        default :
            cell.fdImage.sd_setImage(with: URL(string: imgURL)!)
            
        }
        
        //fdCode = kFoodList[indexPath.row].fdcode
        //cell.fdNameKR.text = kFoodList[indexPath.row].fdnamekr
        cell.fdNameKR.attributedText = attrString
        cell.fdNameENP.text = kFoodList[indexPath.row].fdnameenp
        cell.fdNameEN.text = kFoodList[indexPath.row].fdnameen
        
        if kFoodList.count == (indexPath.row + 1) && totalCount != (indexPath.row + 1) {
            
            mPageNum += 1
            getKFoodList(fdnamekr: pFdName, page: String(mPageNum))
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("--->> tableView didSelectRowAt")
            
        let storyBoard = UIStoryboard(name: "FoodDetail", bundle: nil)
        guard let controller = storyBoard.instantiateViewController(withIdentifier: "FoodDetail") as? FoodDetailViewController else {return}
        
        controller.pFdCode = kFoodList[indexPath.row].fdcode
        self.navigationController?.pushViewController(controller, animated: true)

    }
    
}

struct KFoodInfo : Decodable {
    
    let totalcount: Int
    let currentpage: Int
    let lastpage: Int
    let records: [KFoodList]
    
}

struct KFoodList : Decodable{
    
    let fdcode: String
    let fdnamekr: String
    let fdnameenp: String
    let fdnameen: String
    let fdpicurl: String
    
}

