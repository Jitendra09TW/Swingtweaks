//
//  UIView+Extension.swift
//  musicplayer3_tabs
//

import Foundation
import UIKit
import Photos

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            clipsToBounds = true
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var leftCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            roundedLeft(radius: newValue)
        }
    }
    
    @IBInspectable var rightCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            roundedRight(radius: newValue)
        }
    }
    
    func roundedLeft(radius: CGFloat) {
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topLeft , .bottomLeft],
                                     cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
        self.layoutIfNeeded()
    }
    
    func roundedRight(radius: CGFloat){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topRight , .bottomRight],
                                     cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
        self.layoutIfNeeded()
    }
    
    @IBInspectable var topCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            clipsToBounds = true
            layer.cornerRadius = newValue
            layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    
    @IBInspectable var bottomCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            clipsToBounds = true
            layer.cornerRadius = newValue
            layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var topBorderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            if let colorValue = newValue {
                
                layer.addBorder(edge: .top, color: colorValue, thickness: 1)
            }
            
        }
    }
    
    @IBInspectable var bottomBorderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            if let colorValue = newValue {
                
                layer.addBorder(edge: .bottom, color: colorValue, thickness: 1)
            }
            
        }
    }
    
    @IBInspectable var leftBorderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            if let colorValue = newValue {
                
                layer.addBorder(edge: .left, color: colorValue, thickness: 1)
            }
            
        }
    }
    
    @IBInspectable var rightBorderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            if let colorValue = newValue {
                
                layer.addBorder(edge: .right, color: colorValue, thickness: 1)
            }
            
        }
    }
    
    @IBInspectable var hBorderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            if let colorValue = newValue {
                
                layer.addCentreHorizontalBorder(color: colorValue, thickness: 1)
            }
            
        }
    }
    
    @IBInspectable var vBorderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            if let colorValue = newValue {
                
                layer.addCentreVerticalBorder(color: colorValue, thickness: 1)
            }
            
        }
    }
    
    @IBInspectable var bottomSpaceBorderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            if let colorValue = newValue {
                
                layer.addSPaceBorder(edge: .bottom, color: colorValue, thickness: 1, space: 17)
            }
            
        }
    }
    
    @IBInspectable var topSpaceBorderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            if let colorValue = newValue {
                
                layer.addSPaceBorder(edge: .top, color: colorValue, thickness: 1, space: 17)
            }
            
        }
    }
    
    @IBInspectable var leftSpaceBorderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            if let colorValue = newValue {
                
                layer.addSPaceBorder(edge: .left, color: colorValue, thickness: 1, space: 17)
            }
            
        }
    }
    
    @IBInspectable var rightSpaceBorderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            if let colorValue = newValue {
                
                layer.addSPaceBorder(edge: .right, color: colorValue, thickness: 1, space: 17)
            }
            
        }
    }
    
    func loadNibFile() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func bounce(duration: Double = 0.5) {
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 0.1,
                       options: .beginFromCurrentState,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: nil)
        
        
    }
    
    static var className: String {
        return "\(self)"
    }
}

extension UIView {
    
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}
extension CGSize {
    
    func aspectRatio(newWidth: CGFloat) -> CGSize {
        
        let oldWidth:CGFloat  = self.width
        let scaleFactor:CGFloat = newWidth / oldWidth
        
        let newHeight:CGFloat = self.height * scaleFactor
        let newWidth:CGFloat = oldWidth * scaleFactor
        
        return CGSize(width: newWidth, height: newHeight)
        
    }
    
    func aspectRatio(newHeight: CGFloat) -> CGSize {
        
        let oldHeight:CGFloat  = self.height
        let scaleFactor:CGFloat = newHeight / oldHeight
        
        let newWidth:CGFloat = self.width * scaleFactor
        let newHeight:CGFloat = oldHeight * scaleFactor
        
        return CGSize(width: newWidth, height: newHeight)
        
    }
}

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        addSublayer(border)
    }
    
    func addCentreHorizontalBorder(color: UIColor, thickness: CGFloat) {
        AppDelegate.shared.window?.frame.size
        let border = CALayer()
        border.frame = CGRect(x: (AppDelegate.shared.window?.frame.size.width)!/2, y: 0, width: thickness, height: frame.height)
        border.backgroundColor = color.cgColor;
        
        addSublayer(border)
    }
    
    func addCentreVerticalBorder(color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        border.frame = CGRect(x: 0, y: frame.height/2, width: (AppDelegate.shared.window?.frame.size.width)!, height: thickness)
        border.backgroundColor = color.cgColor;
        
        addSublayer(border)
    }
    
    func addSPaceBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat, space: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case .top:
            border.frame = CGRect(x: space, y: 0, width: ((AppDelegate.shared.window?.frame.size.width)!-(2*space)), height: thickness)
        case .bottom:
            border.frame = CGRect(x: space, y: frame.height - thickness, width: ((AppDelegate.shared.window?.frame.size.width)!-(2*space)), height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: space, width: thickness, height: (frame.height-(2*space)))
        case .right:
            border.frame = CGRect(x: (AppDelegate.shared.window?.frame.size.width)! - thickness, y: space, width: thickness, height: (frame.height-(2*space)))
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        addSublayer(border)
    }
}


extension UIViewController {
  func showAlertView(_ title : String?, message : String?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .cancel,
                   handler: nil))
    self.present(alert, animated: true, completion:{
    })
  }
 func saveVideoToLibrary(exportedURL: URL) {
       PHPhotoLibrary.shared().performChanges( {
        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exportedURL)
       }) { [weak self] (isSaved, error) in
        if isSaved {
          LoadingView.unlockView()
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self?.showAlertView("Saved", message: "Video saved in gallery")
          }
        } else {
         print("Cannot save video.")
        }
       }
      }
}
