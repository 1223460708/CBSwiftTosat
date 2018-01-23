//
//  CBSwiftToast.swift
//  CBTosat
//
//  Created by mac on 2017/11/8.
//  Copyright © 2017年 lifepay. All rights reserved.
//

import UIKit

private let sn_topBar: Int = 1001

extension UIResponder {
    @discardableResult
    func noticeOnlyText(_ text: String) -> UIWindow{
        return CBSwiftToast.showText(text)
    }
    @discardableResult
    func noticeOnlyTextForPosition(_ text:String,positionType:ToastPosition)->UIWindow{
        return CBSwiftToast.showText(text, autoClearTime: 2, autoClear: true, type: positionType)
    }
    
    @discardableResult
    func showLoadingWithImages(_ imageNames: Array<UIImage>, timeInterval: Int) -> UIWindow{
        return CBSwiftToast.showLoading(imageNames, timeInterval: timeInterval)
    }
    @discardableResult
    func showLoading() -> UIWindow {
        return CBSwiftToast.showLoading()
    }
    
    
    func cancle(){
        return CBSwiftToast.clear()
    }
    
}


enum ToastPosition{
    case center
    case bottom
    case top
}

class CBSwiftToast: NSObject {

    static var windows = Array<UIWindow!>()
    static let rv = UIApplication.shared.keyWindow?.subviews.first as UIView!
    static var timer: DispatchSource!
    static var timerTimes = 0
    
    static func clear() {
        self.cancelPreviousPerformRequests(withTarget: self)
        if let _ = timer {
            timer.cancel()
            timer = nil
            timerTimes = 0
        }
        windows.removeAll(keepingCapacity: false)
    }
    
    //文字
    @discardableResult
    static func showText(_ text:String,autoClearTime:Int = 2,autoClear:Bool=true,type:ToastPosition = .center)->UIWindow{
        let window = UIWindow()
        window.backgroundColor = UIColor.clear
        
        let mainView = UIView()
        mainView.layer.cornerRadius = 12;
        mainView.backgroundColor = UIColor(red:0, green:0, blue:0, alpha: 0.8)
        
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.textColor = UIColor.white
        let size = label.sizeThatFits(CGSize(width: UIScreen.main.bounds.width-82, height: .greatestFiniteMagnitude))
        label.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        mainView.addSubview(label)
        
        if type == .center {
            let superFrame = CGRect(x: 0, y: 0, width: label.frame.width + 50 , height: label.frame.height + 30)
            window.frame = superFrame
            mainView.frame = superFrame
            
            label.center = mainView.center
            window.center = rv!.center
        }else if type == .bottom{
            let superFrame = CGRect(x: 0, y: 0, width: label.frame.width + 50 , height: label.frame.height + 30)
            window.frame = superFrame
            mainView.frame = superFrame
            
            label.center = mainView.center
            window.center = CGPoint(x: rv!.center.x, y: UIScreen.main.bounds.height - 40)
        }else {
            let superFrame = CGRect(x: 0, y: 0, width: label.frame.width + 50 , height: label.frame.height + 30)
            window.frame = superFrame
            mainView.frame = superFrame
            
            label.center = mainView.center
            window.center = CGPoint(x: rv!.center.x, y: 100)
        }
        

        if let version = Double(UIDevice.current.systemVersion),
            version < 9.0 {
            // change center
            window.center = getRealCenter()
            // change direction
            window.transform = CGAffineTransform(rotationAngle: CGFloat(degree * Double.pi / 180))
        }
        
        window.windowLevel = UIWindowLevelAlert
        window.isHidden = false
        window.addSubview(mainView)
        windows.append(window)
        
        if autoClear {
            self.perform(.hideNotice, with: window, afterDelay: TimeInterval(autoClearTime))
        }
        return window
        
    }
    
    
    static func showLoading(_ imageNames: Array<UIImage> = Array<UIImage>(), timeInterval: Int = 0)->UIWindow{
        let frame = CGRect(x: 0, y: 0, width: 78, height: 78)
        let window = UIWindow()
        window.backgroundColor = UIColor.clear
        let mainView = UIView()
        mainView.layer.cornerRadius = 12
        mainView.backgroundColor = UIColor(red:0, green:0, blue:0, alpha: 0.8)
        
        if imageNames.count > 0 {
            if imageNames.count > timerTimes {
                let iv = UIImageView(frame: frame)
                iv.image = imageNames.first!
                iv.contentMode = UIViewContentMode.scaleAspectFit
                mainView.addSubview(iv)
                timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: DispatchQueue.main) as! DispatchSource
                timer.scheduleOneshot(deadline: DispatchTime.now(), leeway: DispatchTimeInterval.milliseconds(timeInterval))
                timer.setEventHandler(handler: { () -> Void in
                    let name = imageNames[timerTimes % imageNames.count]
                    iv.image = name
                    timerTimes += 1
                })
                timer.resume()
            }
        } else {
            let ai = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            ai.frame = CGRect(x: 21, y: 21, width: 36, height: 36)
            ai.startAnimating()
            mainView.addSubview(ai)
        }
        
        window.frame = frame
        mainView.frame = frame
        window.center = rv!.center
        
        if let version = Double(UIDevice.current.systemVersion),
            version < 9.0 {
            // change center
            window.center = getRealCenter()
            // change direction
            window.transform = CGAffineTransform(rotationAngle: CGFloat(degree * Double.pi / 180))
        }
        
        window.windowLevel = UIWindowLevelAlert
        window.isHidden = false
        window.addSubview(mainView)
        windows.append(window)
        
        mainView.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {
            mainView.alpha = 1
        })
        return window
    }
    
    
    
    
    
    //8.0
    static func getRealCenter() -> CGPoint {
        if UIApplication.shared.statusBarOrientation.hashValue >= 3 {
            return CGPoint(x: rv!.center.y, y: rv!.center.x)
        } else {
            return rv!.center
        }
    }
    //8.0
    static var degree: Double {
        get {
            return [0, 0, 180, 270, 90][UIApplication.shared.statusBarOrientation.hashValue] as Double
        }
    }
    
    
}

fileprivate extension Selector {
    static let hideNotice = #selector(CBSwiftToast.hideNotice(_:))
}

extension CBSwiftToast {
    static func hideNotice(_ sender: AnyObject) {
        if let window = sender as? UIWindow {
            
            if let v = window.subviews.first {
                UIView.animate(withDuration: 0.2, animations: {
                    
                    if v.tag == sn_topBar {
                        v.frame = CGRect(x: 0, y: -v.frame.height, width: v.frame.width, height: v.frame.height)
                    }
                    v.alpha = 0
                }, completion: { b in
                    
                    if let index = windows.index(where: { (item) -> Bool in
                        return item == window
                    }) {
                        windows.remove(at: index)
                    }
                })
            }
            
        }
    }
}




