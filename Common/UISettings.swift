//
//  UIViewSettings.swift
//  KFoodMenuScan
//
//  Created by yyjweber on 2022/08/18.
//
import UIKit
import NVActivityIndicatorView

//button dotted border setting
extension UIView {
    
    @discardableResult
    
    func addLineDashedStroke(pattern: [NSNumber]?, radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat, backGroundColor: UIColor) -> CALayer {
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        borderLayer.lineDashPattern = pattern
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.fillColor = backGroundColor.cgColor
        borderLayer.frame = bounds

        layer.addSublayer(borderLayer)
        return borderLayer
    }
}

extension UIView {
    
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
     
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
     
}

    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
    
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    
}

    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
    
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    
}

    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
    
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    
    }
    
 }

extension UIView {
    
    func setfdDetailScrollContentHight(selfView: UIView, guidelineLabel: UILabel) {
     
     translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: selfView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: guidelineLabel.frame.origin.y))
     
    }
    
}
/*
extension UIViewController {
    
    func setActivityIndicator() -> (NVActivityIndicatorView, UIView) {
        
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        bgView.backgroundColor = .white
        
        let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40),
                                                        type: .ballBeat,
                                                        color: .red,
                                                        padding: .zero)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(bgView)
        bgView.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()

        return (activityIndicator, bgView)
        
    }
        
    func removeActivityIndicator(indicator: NVActivityIndicatorView, bgView: UIView) {
        
        indicator.stopAnimating()
        bgView.removeFromSuperview()
        
    }
        

}*/

extension UINavigationController {
    
    func popToSpecificVC(storyboardID: String, viewControllerID: String, currentNavigationController: UINavigationController) {
        
        let storyBoard = UIStoryboard(name: storyboardID, bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: viewControllerID)
        currentNavigationController.setViewControllers([currentNavigationController.viewControllers[0], controller], animated:false)
        
    }

}

extension UILabel {
    
    func setfdDetailTitle(selfLabel: UILabel) {
        
        textAlignment = .center
        textColor = .white
        layer.masksToBounds = true
        layer.cornerRadius = 14
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: selfLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: selfLabel.frame.size.height + 8))
        addConstraint(NSLayoutConstraint(item: selfLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: selfLabel.frame.size.width + 20))
        
    }
    
}


extension UIImage {
    
    var orientationCorrectedImage: UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
        
    }
    
}


extension UIColor {
    
    static let basicRed = UIColor(red: 237/255, green: 27/255, blue: 36/255, alpha: 1)
    static let basicGreen = UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1)
    static let basicYellow = UIColor(red: 255/255, green: 208/255, blue: 104/255, alpha: 1)
    static let basicSkyBlue = UIColor(red: 112/255, green: 185/255, blue: 220/255, alpha: 1)
    static let basicPurple = UIColor(red: 183/255, green: 122/255, blue: 220/255, alpha: 1)

}


struct SetActivityIndicator {
    
    let bgView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), type: .ballBeat, color: .red, padding: .zero)

    func showIndicator(){
        
        bgView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        bgView.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: bgView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: bgView.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
      
    }
    
    func removeIndicator(){
        
        activityIndicator.stopAnimating()
        bgView.removeFromSuperview()
        
    }
    
}
