//
//  Tool.swift
//  Nenzo
//
//  Created by sloot on 5/27/15.
//
//

import UIKit
import CoreData
private let _ToolSharedInstance = Tool()
private let boundary : NSString = "---------------------------14737809831466499882746641449"
private let boundaryHeaderData = "--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding) as NSData!
private let boundaryFooterData = "\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) as NSData!
class Tool: NSObject {
    
    weak var myViewController:MainViewController?
    
    class var sharedInstance: Tool {
        return _ToolSharedInstance
    }
    
    class func callREST(params : NSDictionary?, path : String, method: String, completionHandler: ((NSDictionary?) -> Void)?, errorHandler:(() -> Void)?) {
        let urlString:String = "http://" + SERVER_DOMAIN + PORT + "/" + path
        var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = method
        if(params != nil){
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            var err: NSError?
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params!, options: nil, error: &err)
        }
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            Tool.handleRESTResponse(completionHandler, data: data, response: response, error: error,  errorHandler: errorHandler)
        })
        task.resume()
    }

    class func callMPREST(input:[MultiPartFormObject], path : String, method:String, completionHandler: ((NSDictionary?) -> Void)?, errorHandler:(() -> Void)?){
        let urlString:String = "http://" + SERVER_DOMAIN + PORT + "/" + path
        var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = method
        
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let bodyParams : NSMutableData = NSMutableData()
        
        for mobj in input {
            bodyParams.appendData(boundaryHeaderData)
            if(mobj.containsImage){
                let imageData = "Content-Disposition: attachment; name=\"\(mobj.key)\"; filename=\"photo\"\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                bodyParams.appendData(imageData!)
                
                let fileContentType = "Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                bodyParams.appendData(fileContentType!)
                
                bodyParams.appendData(mobj.data as! NSData)
            }
            else{
                if let arr = mobj.data as? NSArray {
                    var err: NSError?
                    var data = NSJSONSerialization.dataWithJSONObject(arr, options: nil, error: &err)
                    var key = "\(mobj.key)"
                    let stringData = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                    bodyParams.appendData(stringData!)
                    bodyParams.appendData(data!)
                } else {
                    let stringData = "Content-Disposition: form-data; name=\"\(mobj.key)\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                    bodyParams.appendData(stringData!)
                    let escapedData = (mobj.data as! NSString).stringByReplacingOccurrencesOfString("\n", withString: "\\n")
                    let formData2 = (escapedData as String).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                    bodyParams.appendData(formData2!)
                }
            }
            bodyParams.appendData(boundaryFooterData)
        }
        
        let boundaryDataEnd = "--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        bodyParams.appendData(boundaryDataEnd)
        
        request.HTTPBody = bodyParams
        let task = session.dataTaskWithRequest(request) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
            Tool.handleRESTResponse(completionHandler, data: data, response: response, error: error,  errorHandler: errorHandler)
        }
        task.resume()
    }
    
    
    class func handleRESTResponse(completionHandler: ((NSDictionary?) -> Void)?, data:NSData?, response:NSURLResponse?, error: NSError?, errorHandler:(() -> Void)?){
        var err: NSError?
        var json = NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves, error: &err) as? NSDictionary
        if let parseJSON = json {
            if let completion = completionHandler {
                dispatch_async(dispatch_get_main_queue(),{
                    completion(json)
                });
            }
        }
        else {
            if let completion = completionHandler {
                dispatch_async(dispatch_get_main_queue(),{
                    completion(nil)
                });
            }
        }
    }
}

func saveUserInfo(dict:NSDictionary){
    NSUserDefaults.standardUserDefaults().setObject(dict["name"] as? String, forKey: "name")
    NSUserDefaults.standardUserDefaults().setObject(dict["bg_photo"] as? String, forKey: "bg_photo")
    NSUserDefaults.standardUserDefaults().setObject(dict["username"] as? String, forKey: "username")
    NSUserDefaults.standardUserDefaults().setInteger(dict["gender"] as? Int ?? 0, forKey: "gender")
    NSUserDefaults.standardUserDefaults().setObject(dict["phone_number"] as? String, forKey: "phone_number")
    NSUserDefaults.standardUserDefaults().setInteger(dict["birthdate"] as? Int ?? Int(NSDate().timeIntervalSince1970), forKey: "birthdate")
    NSUserDefaults.standardUserDefaults().setObject(dict["country_code"] as? String, forKey: "country_code")
    NSUserDefaults.standardUserDefaults().synchronize()
    if let vc = Tool.sharedInstance.myViewController {
        vc.loadBGImage()
    }
}

func test(){
    //createUser()
    //login()
}

//func login(){
//    var inputDict = NSMutableDictionary()
//    
//    var sessionDict = NSMutableDictionary()
//    sessionDict["username"] = "😎😎😎😎😎😎😟😚😤😩😩😧"
//    sessionDict["password"] = "masasss"
//    
//    inputDict["session"] = sessionDict
//    Tool.callREST(inputDict, path: "login.json", method: "POST", completionHandler: { (json) -> Void in
//        println(json)
//        CoreDataTool.sharedInstance.saveCookies()
//        }, errorHandler: nil)
//}
//
//func createUser(){
//    var inputDict = NSMutableDictionary()
//    
//    var userDict = NSMutableDictionary()
//    userDict["name"] = "😎😎😎😎😎😎😟😚😤😩😩😧"
//    userDict["username"] = "koroketa"
//    userDict["password"] = "masasss"
//    userDict["phone_number"] = "6502817692"
//    
//    inputDict["user"] = userDict
//    Tool.callREST(inputDict, path: "users.json", method: "POST", completionHandler: { (json) -> Void in
//        println(json)
//        }, errorHandler: nil)
//}

func applyBlurEffect(blurImageView: UIImageView){
//    var imageToBlur = CIImage(image: blurImageView.image)
//    var blurfilter = CIFilter(name: "CIGaussianBlur")
//    blurfilter.setValue(imageToBlur, forKey: "inputImage")
//    var resultImage = blurfilter.valueForKey("outputImage") as! CIImage
//    var blurredImage = UIImage(CIImage: resultImage)
//    blurImageView.image = blurredImage

    var blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
    var effectView:UIVisualEffectView = UIVisualEffectView (effect: blur)
    effectView.frame = blurImageView.frame
    blurImageView.addSubview(effectView)
}

func setUpCookie() -> Bool {
    var cookieProperties:NSMutableDictionary = NSMutableDictionary()
    cookieProperties[NSHTTPCookieDomain] = SERVER_DOMAIN
    cookieProperties[NSHTTPCookiePath] = "/"
    
    if let cookieVal = NSUserDefaults.standardUserDefaults().objectForKey("nenzo_cookie") as? String {
        cookieProperties[NSHTTPCookieValue] = cookieVal
        cookieProperties[NSHTTPCookieName] = NENZO_COOKIE_NAME
        println(cookieVal)
        println(NENZO_COOKIE_NAME)
        if let cookie:NSHTTPCookie = NSHTTPCookie(properties: cookieProperties as [NSObject : AnyObject]) {
            NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie)
        } else {
            println("COOKIE ERR")
        }
        return true
    } else {
        return false
    }
}