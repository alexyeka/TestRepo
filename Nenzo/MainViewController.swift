//
//  ViewController.swift
//  Nenzo
//
//  Created by sloot on 5/27/15.
//
//

import UIKit
import AddressBookUI
class MainViewController: UIViewController {

    var sharedBottom:TabSharedBottomBarView!
    
    var tab1:Tab1!
    var tab2:Tab2!
    var tab3:Tab3!
    var tab4:Tab4!
    var tab5:Tab5!
    
    var previousTab:Int = 1
    
    var currentTab:Int = 1
    
    var tabs:[UIView] = []
    
    var isTutorial:Bool = true
    
    var myParams:NSMutableDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Tool.sharedInstance.myViewController = self
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        showBackgroundView()
        checkLoginStatus()
        //test()
        //showSignUpView()
        //setUp()
    }
    
    var didAppear:Bool = false
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !didAppear {
            didAppear = true
            //backgroundView!.setup()
        }
        loadBGImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkLoginStatus(){
        if setUpCookie() {
            loginSuccess()
        } else {
            showLoginView()
        }
    }
    
    var backgroundView:BackgroundView?
    var loginView:LoginView?
    var signUpView:SignUpView?
    var signUpPreviewView:SignUpPreviewView?
    var varificationView:VarificationView?
    
    func showBackgroundView(){
        backgroundView = "BackgroundView".loadNib() as? BackgroundView
        backgroundView!.frame = self.view.frame
        backgroundView!.layoutIfNeeded()
        view.addSubview(backgroundView!)
    }
    
    func loadBGImage(){
        if let bg_photo_url:String = NSUserDefaults.standardUserDefaults().objectForKey("bg_photo") as? String, bgv = backgroundView {
            bgv.layoutIfNeeded()
            bgv.ownBGImageView.smartLoad(bg_photo_url)
            bgv.darkOverlayView.hidden = false
        }
    }
    
    func showLoginView(){
        loginView = "LoginView".loadNib() as? LoginView
        loginView!.frame = self.view.frame
        loginView!.delegate = self
        view.addSubview(loginView!)
    }
    
    func showSignUpView(){
        signUpView = "SignUpView".loadNib() as? SignUpView
        signUpView!.frame = self.view.frame
        signUpView!.delegate = self
        signUpView!.place(SlidePosition.Right)
        view.addSubview(signUpView!)
    }
    
    func showSignUpPreviewView(){
        signUpPreviewView = "SignUpPreviewView".loadNib() as? SignUpPreviewView
        signUpPreviewView!.frame = self.view.frame
        signUpPreviewView!.delegate = self
        signUpPreviewView!.place(SlidePosition.Right)
        view.addSubview(signUpPreviewView!)
    }
    
    func showVarificationView(){
        varificationView = "VarificationView".loadNib() as? VarificationView
        varificationView!.frame = self.view.frame
        varificationView!.delegate = self
        varificationView!.place(SlidePosition.Right)
        view.addSubview(varificationView!)
    }
    
    var cameraView:CameraView?
    func showCameraView(dgt:CameraViewDelegate, type:CameraViewType) -> CameraView {
        if cameraView == nil {
            createCameraView()
        }
        cameraView!.delegate = dgt
        cameraView!.place(SlidePosition.Middle)
        view.addSubview(cameraView!)
        cameraView!.show(type)
        return cameraView!
    }
    
    func createCameraView(){
        cameraView = "CameraView".loadNib() as? CameraView
        cameraView!.frame = self.view.frame
        cameraView!.place(SlidePosition.Right)
        cameraView!.setup()
    }
    
    func setUpArray(){
        tabs = [tab1, tab2, tab3, tab4, tab5]
    }

    func setUp(){
        view.addSubview(backgroundView!)
        sharedBottom = "TabSharedBottomBarView".loadNib() as! TabSharedBottomBarView
        sharedBottom.frame = CGRect(origin: CGPoint(x: 0, y: view.frame.height - 50.0), size: CGSize(width: view.frame.width, height:50))
        sharedBottom.delegate = self
        addTab1()
        addTab2()
        addTab3()
        addTab4()
        addTab5()
        setUpArray()
        if isTutorial {
            showTutorialView()
        } else {
            view.addSubview(tab1)
        }
        view.addSubview(sharedBottom)
    }
    
    func resetUp(){
        if let bgv = backgroundView {
            bgv.ownBGImageView.image = nil
            bgv.darkOverlayView.hidden = true
        }
        loginView?.removeFromSuperview()
        showLoginView()
        sharedBottom.removeFromSuperview()
        tab1.removeFromSuperview()
        tab2.removeFromSuperview()
        tab3.removeFromSuperview()
        tab4.removeFromSuperview()
        tab5.removeFromSuperview()
        varificationView?.removeFromSuperview()
        signUpView?.removeFromSuperview()
        signUpPreviewView?.removeFromSuperview()
    }
    
    // MARK: Tab Setup
    func addTab1(){
        tab1 = "Tab1".loadNib() as! Tab1
        tab1.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.width, height: view.frame.height - 50.0))
    }
    
    func addTab2(){
        tab2 = "Tab2".loadNib() as! Tab2
        tab2.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.width, height: view.frame.height - 50.0))
    }
    
    func addTab3(){
        tab3 = "Tab3".loadNib() as! Tab3
        tab3.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.width, height: view.frame.height))
    }
    
    func addTab4(){
        tab4 = "Tab4".loadNib() as! Tab4
        tab4.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.width, height: view.frame.height - 50.0))
    }
    
    func addTab5(){
        tab5 = "Tab5".loadNib() as! Tab5
        tab5.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.width, height: view.frame.height - 50.0))
        tab5.layoutIfNeeded()
        tab5.loadBGImage()
    }
    
    weak var tutorialView:TutorialView?
    func showTutorialView(){
        var newTV = "TutorialView".loadNib() as? TutorialView
        newTV!.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.width, height: view.frame.height - 50.0))
        view.addSubview(newTV!)
        tutorialView = newTV
        tutorialView!.layoutIfNeeded()
        tutorialView!.setUpScrollView()
    }
}
extension MainViewController: LoginViewDelegate {
    func signUpPressed() {
        if (signUpView == nil){
            showSignUpView()
            addSwipe("cancelSignUpPressed", selectorView: signUpView!)
        }
        loginView!.slide(SlidePosition.Left)
        signUpView!.slide(SlidePosition.Middle)
    }
    func loginSuccess() {
        setUp()
    }
}
extension MainViewController: SignUpViewDelegate {
    func cancelSignUpPressed() {
        if let privacyView = signUpView!.subviews.last as? PrivacyPolicyView {
            privacyView.removeFromSuperview()
        } else {
            signUpView!.phoneNumberTextField.resignFirstResponder()
            signUpView!.usernameTextField.resignFirstResponder()
            signUpView!.passwordTextField.resignFirstResponder()
            signUpView!.nameTextField.resignFirstResponder()
            signUpView!.slide(SlidePosition.Right)
            loginView!.slide(SlidePosition.Middle)
        }
    }
    
    func continueSignUpPressed(params:NSMutableDictionary) {
        myParams = params
        if (varificationView == nil){
            showVarificationView()
            addSwipe("cancelVarificationViewPressed", selectorView: varificationView!)
        }
        signUpView!.slide(SlidePosition.Left)
        varificationView!.slide(SlidePosition.Middle)
        varificationView!.setup()
    }
}
extension MainViewController: VarificationViewDelegate {
    func cancelVarificationViewPressed() {
        varificationView!.hiddenInput.resignFirstResponder()
        varificationView!.slide(SlidePosition.Right)
        signUpView!.slide(SlidePosition.Middle)
    }
    
    func didVerify() {
        if (signUpPreviewView == nil){
            showSignUpPreviewView()
            addSwipe("cancelSignUpPreviewPressed", selectorView: signUpPreviewView!)
        }
        varificationView!.slide(SlidePosition.Left)
        signUpPreviewView!.slide(SlidePosition.Middle)
        signUpPreviewView!.params = myParams
        signUpPreviewView!.setup()
    }
}
extension MainViewController: SignUpPreviewViewDelegate {
    func cancelSignUpPreviewPressed() {
        signUpPreviewView!.slide(SlidePosition.Right)
        varificationView!.slide(SlidePosition.Middle)
        varificationView!.hiddenInput.becomeFirstResponder()
    }
    
    func finishSignUpPreviewPressed() {
        setUp()
    }
}
extension MainViewController: TabSharedBottomBarViewDelegate {
    func tabChanged(from: Int, to: Int) {
        if isTutorial {
            if let tv = tutorialView {
                if to < 5 {
                    tv.switchToSlide(to - 1)
                } else {
                    tv.removeFromSuperview()
                    isTutorial = false
                    tabs[from - 1].removeFromSuperview()
                    view.addSubview(tabs[to - 1])
                    if let slideTab = tabs[to - 1] as? TabDelegate {
                        slideTab.showSlide()
                    }
                    if let slideTab = tabs[from - 1] as? TabDelegate {
                        slideTab.removeSlide()
                    }
                    previousTab = from
                    if to != 3 {
                        view.addSubview(sharedBottom)
                    } else {
                        sharedBottom.removeFromSuperview()
                    }
                }
            }
        } else {
            currentTab = to
            tabs[from - 1].removeFromSuperview()
            view.addSubview(tabs[to - 1])
            if let slideTab = tabs[to - 1] as? TabDelegate {
                slideTab.showSlide()
            }
            if let slideTab = tabs[from - 1] as? TabDelegate {
                slideTab.removeSlide()
            }
            previousTab = from
            if to != 3 {
                view.addSubview(sharedBottom)
            } else {
                sharedBottom.removeFromSuperview()
            }
        }
    }
}

@objc(TabDelegate)
protocol TabDelegate{
    func showSlide()
    func removeSlide()
}

extension MainViewController {
    //Adds functionality of swicthing boards by swiping to the left or right
    func addSwipe(action:String, selectorView:UIView){
        var rightSwipe:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector(action))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        selectorView.addGestureRecognizer(rightSwipe)
    }
}

extension UIView {
    func addLeftSwipe(action:String){
        var leftSwipe:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector(action))
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        addGestureRecognizer(leftSwipe)
    }
    
    func addRightSwipe(action:String){
        var rightSwipe:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector(action))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        addGestureRecognizer(rightSwipe)
    }
}

func upOrientImage(image:UIImage?) -> UIImage?{
    if(image != nil){
        if(image!.imageOrientation == UIImageOrientation.Up){
            return image!
        }
        else{
            UIGraphicsBeginImageContextWithOptions(image!.size, false, image!.scale)
            image!.drawInRect(CGRect(origin: CGPointZero, size: image!.size))
            var fixedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return fixedImage
        }
    }
    else{
        return image
    }
}

enum CameraViewType:Int {
    case Profile = 1,
    Multiple = 0
}

extension MainViewController {

}