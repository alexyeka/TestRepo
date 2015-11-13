//
//  CameraView.swift
//  Nenzo
//
//  Created by sloot on 6/4/15.
//
//

import UIKit
import AVFoundation
import AssetsLibrary
@objc(CameraViewDelegate)
protocol CameraViewDelegate{
    func didSelectCircularImage(img:UIImage, wholeImg:UIImage)
    func didSelectVideo(videourl:NSURL, img:UIImage)
    func didSelectImage(img:UIImage)
}
class CameraView: UISlideView {

    weak var delegate:CameraViewDelegate!
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var isBackCamera:Bool = true
    
    @IBOutlet var previewView: UIView!
    
    @IBOutlet var flashButton: UIButton!
    
    @IBOutlet var flashButtonSetView: UIView!
    
    @IBOutlet var flashAutoButton: UIButton!
    
    @IBOutlet var flashOnButton: UIButton!
    
    @IBOutlet var flashOffButton: UIButton!
    
    @IBOutlet var flashSelectedButton: UIButton!
    
    @IBOutlet var takePhotoButton: UIButton!
    
    @IBOutlet var videoProgressView: UIView!
    
    @IBOutlet var bodyView: UIView!
    
    @IBOutlet var multipleOutputContainerView: UIView!
    
    @IBOutlet var chooseOutputView: UIView!
    
    @IBOutlet var takeVideoView: UIView!
    
    @IBOutlet var timerLabel: UILabel!
    
    @IBOutlet var backButton: UIButton!
    
    @IBOutlet var switchCameraButton: UIButton!
    
    @IBOutlet var galleryButton: UIButton!
    
    @IBOutlet var galleryBottomConstraint: NSLayoutConstraint!
    
    var supportVideo:Bool = false
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    var stillImageOutput: AVCaptureStillImageOutput?
    
    var myType:CameraViewType!
    
    @IBAction func takePhotoPressed(sender: AnyObject) {
        takePhotoGeneric()
    }
    
    var focusView:UIImageView?
    
    func takePhotoGeneric(){
        if let imageOutput = stillImageOutput {
            var videoConnection: AVCaptureConnection?
            for connection in imageOutput.connections {
                let c = connection as! AVCaptureConnection
                for port in c.inputPorts {
                    let p = port as! AVCaptureInputPort
                    if p.mediaType == AVMediaTypeVideo {
                        videoConnection = c;
                        break
                    }
                }
                if videoConnection != nil {
                    break
                }
            }
            
            if videoConnection != nil {
                var error: NSError?
                imageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageSampleBuffer: CMSampleBufferRef!, error) -> Void in
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                    let image: UIImage? = UIImage(data: imageData!)!
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        //                            completed(image: image)
                        AudioServicesPlaySystemSound(1108)
                        var newImage:UIImage = image!
                        if !self.isBackCamera {
                            newImage = UIImage(CGImage: image!.CGImage!, scale: image!.scale, orientation: UIImageOrientation.LeftMirrored)!
                        }
                        self.displayImage(image)
                    }
                })
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.displayImage(nil)
                    //                        completed(image: nil)
                }
            }
        } else {
            //            completed(image: nil)
        }
    }
    
    @IBAction func videoViewTakePhotoPressed(sender: UIButton) {
        takePhotoGeneric()
    }
    
    @IBAction func videoViewTakeVideoPressed(sender: UIButton) {
        takeVideoView.hidden = false
        chooseOutputView.hidden = true
        startVideo()
    }
    
    @IBAction func videoViewEndVideoPressed(sender: UIButton) {
        stopVideo()
    }
    
    var isFlashExpanded = false
    
    @IBAction func flashButtonPressed(sender: UIButton) {
        toggleFlash()
    }
    
    @IBAction func flashSelectedButtonPressed(sender: AnyObject) {
        toggleFlash()
    }
    
    func toggleFlash(){
        if isFlashExpanded {
            unexpandFlashSection()
        } else {
            expandFlashSection()
        }
    }
    
    func expandFlashSection(){
        isFlashExpanded = true
        self.flashSelectedButton.hidden = true
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            let myFlashButton = self.flashButton
            myFlashButton.frame = CGRectMake(myFlashButton.frame.origin.x - 45.0, myFlashButton.frame.origin.y, myFlashButton.frame.width, myFlashButton.frame.height)
            }, completion: { (done) -> Void in
                if done {
                    self.flashButtonSetView.alpha = 1.0
                }
        })
    }
    
    func unexpandFlashSection(){
        isFlashExpanded = false
        self.flashButtonSetView.alpha = 0.0
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            let myFlashButton = self.flashButton
            myFlashButton.frame = CGRectMake(myFlashButton.frame.origin.x + 45.0, myFlashButton.frame.origin.y, myFlashButton.frame.width, myFlashButton.frame.height)
            }, completion: { (done) -> Void in
                if done {
                    self.flashSelectedButton.hidden = false
                }
        })
    }
    
    let FLASH_BUTTON_COLOR:UIColor = UIColor(red: 255.0/255.0, green: 168.0/255.0, blue: 0, alpha: 1)
    
    @IBAction func flashAutoSelected(sender: AnyObject) {
        changeFlash(AVCaptureFlashMode.Auto)
        flashSelectedButton.setTitle("Auto", forState: .Normal)
        flashAutoButton.setTitleColor(FLASH_BUTTON_COLOR, forState: .Normal)
        flashOnButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        flashOffButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        unexpandFlashSection()
    }
    
    @IBAction func flashOnSelected(sender: AnyObject) {
        changeFlash(AVCaptureFlashMode.On)
        flashSelectedButton.setTitle("On", forState: .Normal)
        flashAutoButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        flashOnButton.setTitleColor(FLASH_BUTTON_COLOR, forState: .Normal)
        flashOffButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        unexpandFlashSection()
    }
    
    @IBAction func flashOffSelected(sender: AnyObject) {
        changeFlash(AVCaptureFlashMode.Off)
        flashSelectedButton.setTitle("Off", forState: .Normal)
        flashAutoButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        flashOnButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        flashOffButton.setTitleColor(FLASH_BUTTON_COLOR, forState: .Normal)
        unexpandFlashSection()
    }
    
    var isSelfie:Bool = false
    
    @IBAction func reversePressed(sender: AnyObject) {
        if let currentCameraInput = captureSession.inputs.first as? AVCaptureInput {
            captureSession.beginConfiguration()
            captureSession.removeInput(currentCameraInput)
            
            for input in captureSession.inputs {
                if let currentCameraInput = input as? AVCaptureInput {
                    captureSession.removeInput(currentCameraInput)
                }
            }
            
            currentScale = 1.0
            
            var newCamera:AVCaptureDevice? = nil
            
            if ((currentCameraInput as! AVCaptureDeviceInput).device.position == AVCaptureDevicePosition.Back){
                isSelfie = true
                newCamera = cameraWithPosition(AVCaptureDevicePosition.Front)
                isBackCamera = false
                flashButton.alpha = 0.0
                if isFlashExpanded {
                    flashButtonSetView.alpha = 0.0
                } else {
                    flashSelectedButton.alpha = 0.0
                }
                flashButton.enabled = false
            } else {
                isSelfie = false
                newCamera = cameraWithPosition(AVCaptureDevicePosition.Back)
                isBackCamera = true
                flashButton.alpha = 1.0
                if isFlashExpanded {
                    flashButtonSetView.alpha = 1.0
                } else {
                    flashSelectedButton.alpha = 1.0
                }
                flashButton.enabled = true
            }
            
            var newVideoInput:AVCaptureDeviceInput? = AVCaptureDeviceInput(device: newCamera, error: nil)
            
            if let input = newVideoInput {
                captureSession.addInput(input)
            }
            
            captureSession.commitConfiguration()
        }
    }
    
    @IBAction func backPressed(sender: AnyObject) {
        self.exit()
    }
    
    @IBAction func galleryPressed(sender: AnyObject) {
        chooseImage()
    }
    
    var hasCamera:Bool = false
    
    func setup() {
        self.layoutIfNeeded()
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        
        if focusView == nil {
            createFocusView()
        }
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                hasCamera = true
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        println("Capture device found")
                        var pinch:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "didPinch:")
                        self.addGestureRecognizer(pinch)
                        beginSession()
                    }
                }
            }
        }
    }
    
    var currentScale:CGFloat = 1.0
    
    func didPinch(recognizer : UIPinchGestureRecognizer) {
        switch recognizer.state {
        case UIGestureRecognizerState.Began:
            focusView!.hidden = true
            recognizer.scale = currentScale
        case UIGestureRecognizerState.Changed:
            if recognizer.scale < 1.0 {
                recognizer.scale = 1.0
            }
            if recognizer.scale > 8.0 {
                recognizer.scale = 8.0
            }
            currentScale = recognizer.scale
            changeZoom()
        case UIGestureRecognizerState.Ended:
            if !isFocusing {
                focusView!.hidden = false
            }
            return
        default:
            return
        }
    }
    
    func setupForProfilePhoto(){
        galleryBottomConstraint.constant = 82.0
        galleryButton.layoutIfNeeded()
        supportVideo = false
        takePhotoButton.hidden = false
        multipleOutputContainerView.hidden = true
    }
    
    func setupForMultipleOutput(){
        galleryBottomConstraint.constant = 22.0
        galleryButton.layoutIfNeeded()
        supportVideo = true
        takeVideoView.hidden = true
        chooseOutputView.hidden = false
        switchToVideo()
        multipleOutputContainerView.hidden = false
        takePhotoButton.hidden = true
    }
    
    func cameraWithPosition(position:AVCaptureDevicePosition) -> AVCaptureDevice? {
        var devices:NSArray = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        
        for device in devices {
            if device.position == position {
                return device as? AVCaptureDevice
            }
        }
        
        return nil
    }
    
    func addStillImageOutput() {
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
    }
    
    
    var isFocusing:Bool = false
    
    func createFocusView(){
        var newFocusView = "FocusView".loadNib() as! UIImageView
        newFocusView.frame = CGRect(x: 0, y: 0, width: 100.0, height: 100.0)
        newFocusView.alpha = 0
        newFocusView.userInteractionEnabled = false
        focusView = newFocusView
        self.addSubview(newFocusView)
    }
    
    func showFocus(point:CGPoint){
        if !isFocusing && !isSelfie {
            isFocusing = true
            if focusView == nil {
                createFocusView()
                focusView!.layoutIfNeeded()
            }
            let fv = focusView!
            fv.frame.origin = CGPointMake(point.x - focusView!.frame.width/2.0, point.y - focusView!.frame.height/2.0)
            fv.layoutIfNeeded()
            UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.allZeros, animations: { () -> Void in
                fv.alpha = 1.0
            }, completion: { (done) -> Void in
                UIView.animateWithDuration(0.25, delay: 0.5, options: UIViewAnimationOptions.allZeros, animations: { () -> Void in
                    fv.alpha = 0.0
                }, completion: { (done) -> Void in
                    self.isFocusing = false
                    fv.hidden = false
                })
            })
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        if let point:CGPoint = (event.allTouches()?.first as? UITouch)?.locationInView(self.window){
            focus(point)
            showFocus(point)
        }
    }
    
    func focus(point:CGPoint){
        let y = point.x/frame.width
        let x = point.y/frame.height
        var focusPoint:CGPoint = CGPointMake(x, y)
        if let device = captureDevice {
            if device.focusPointOfInterestSupported && device.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) {
                if device.lockForConfiguration(nil) {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = AVCaptureFocusMode.AutoFocus
                    device.unlockForConfiguration()
                }
            }
        }
    }
    
    func changeFlash(newFlashMode:AVCaptureFlashMode) {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (device.hasFlash) {
            device.lockForConfiguration(nil)
            device.flashMode = newFlashMode
            device.unlockForConfiguration()
        }
    }
    
    func changeZoom() {
        if let device = captureDevice {
            if device.focusPointOfInterestSupported && device.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) {
                if device.lockForConfiguration(nil) {
                    device.videoZoomFactor = currentScale
                    device.unlockForConfiguration()
                }
            }
        }
    }

    //            if (device.torchMode == AVCaptureTorchMode.On) {
    //                device.torchMode = AVCaptureTorchMode.Off
    //                println("YES")
    //            } else {
    //                //device.setTorchModeOnWithLevel(1.0, error: nil)
    //                device.torchMode = AVCaptureTorchMode.Auto
    //                println("NO")
    //            }
    //            device.torchMode = AVCaptureTorchMode.Auto
    
    func configureDevice() {
        if let device = captureDevice {
            device.lockForConfiguration(nil)
            device.focusMode = .Locked
            device.unlockForConfiguration()
        }
        
    }
    
    func beginSession() {
        
        configureDevice()
        
        var err : NSError? = nil
        for input in captureSession.inputs {
            if let currentCameraInput = input as? AVCaptureInput {
                captureSession.removeInput(currentCameraInput)
            }
        }
        
        currentScale = 1.0
        
        if captureSession.canAddInput(AVCaptureDeviceInput(device: captureDevice, error: &err)) {
            captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
            
            if err != nil {
                println("error: \(err?.localizedDescription)")
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewView.layer.addSublayer(previewLayer)
            previewLayer!.frame = previewView.frame
            captureSession.startRunning()
            addStillImageOutput()
        } else {
            println("no")
        }
    }
    
    weak var mediaEditView:MediaEditView?

    func displayImage(image:UIImage?){
//        if let newImage = image {
//            if image != nil {
//                self.cameraStill.image = image;
//                
//                UIView.animateWithDuration(0.225, animations: { () -> Void in
//                    self.cameraStill.alpha = 1.0;
//                    self.cameraStatus.alpha = 0.0;
//                })
//                self.status = .Still
//            }
        if mediaEditView == nil {
            mediaEditView = "MediaEditView".loadNib() as? MediaEditView
            mediaEditView!.frame = frame
            mediaEditView!.cameraView = self
            mediaEditView!.cameraViewDelegate = delegate
            if myType == CameraViewType.Profile {
                mediaEditView!.circleBackgroundView.hidden = false
            }
            mediaEditView!.myType = myType
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.mediaEditView!.setup(image!, newFrame: self.frame)
            })
            self.mediaEditView!.alpha = 0.0
            self.addSubview(self.mediaEditView!)
        }
    }
    
    func displayVideo(url:NSURL){
        if mediaEditView == nil {
            mediaEditView = "MediaEditView".loadNib() as? MediaEditView
            mediaEditView!.frame = frame
            mediaEditView!.cameraView = self
            mediaEditView!.cameraViewDelegate = delegate
            mediaEditView!.myType = myType
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.mediaEditView!.setupVideo(url, newFrame: self.frame)
            })
            self.mediaEditView!.alpha = 0.0
            self.addSubview(self.mediaEditView!)
        }
    }
    
    func show(type:CameraViewType){
        myType = type
        if !hasCamera {
            bodyView.alpha = 0.0
            chooseImage()
        } else {
            switch type {
            case CameraViewType.Multiple :
                setupForMultipleOutput()
            case CameraViewType.Profile :
                setupForProfilePhoto()
            default:
                println("Invalid Camera View Type")
            }
        }
    }
    
    func exit(){
        self.place(SlidePosition.Right)
    }
    
    func switchToVideo(){
        captureSession.beginConfiguration()
        for input in captureSession.inputs {
            if let currentCameraInput = input as? AVCaptureInput {
                captureSession.removeInput(currentCameraInput)
            }
        }
        
        var videoDevice:AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var err : NSError? = nil
        if let videoInputDevice = AVCaptureDeviceInput.deviceInputWithDevice(videoDevice, error: &err) as? AVCaptureInput where err == nil {
            if captureSession.canAddInput(videoInputDevice) {
                captureSession.addInput(videoInputDevice)
            } else {
                println("Cant add input")
            }
        } else {
            println("coudnt create video")
        }
        
        var audioCaptureDevice:AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        var audioErr : NSError? = nil
        if let audioInputDevice = AVCaptureDeviceInput.deviceInputWithDevice(audioCaptureDevice, error: &audioErr) as? AVCaptureInput where audioErr == nil {
            captureSession.addInput(audioInputDevice)
        }
        captureSession.commitConfiguration()
    }
    
    var output:AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
    var isRecording:Bool = false
    func startVideo(){
        if !isRecording {
            if (!isSelfie) {
                flashButton.alpha = 0.0
                if isFlashExpanded {
                    flashButtonSetView.alpha = 0.0
                } else {
                    flashSelectedButton.alpha = 0.0
                }
                flashButton.enabled = false
                if let device = captureDevice where device.hasTorch {
                    device.lockForConfiguration(nil)
                    if (device.flashMode == AVCaptureFlashMode.On) {
                        device.torchMode = AVCaptureTorchMode.On
                    } else if (device.flashMode == AVCaptureFlashMode.Auto) {
                        device.torchMode = AVCaptureTorchMode.Auto
                    }
                    device.unlockForConfiguration()
                }
            }
            isRecording = true
            output.maxRecordedDuration = CMTimeMakeWithSeconds(11.0, 600)
            let outputPath:String = "\(NSTemporaryDirectory())output.mov"
            let outputURL:NSURL = NSURL(fileURLWithPath: outputPath)!
            let fileManager:NSFileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(outputPath) {
                if !fileManager.removeItemAtPath(outputPath, error: nil) {
                }
            }
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            } else {
                println("cant add video output")
            }
            output.startRecordingToOutputFileURL(outputURL, recordingDelegate: self)
            galleryButton.hidden = true
            switchCameraButton.hidden = true
            backButton.hidden = true
            startTimer()
        }
    }
    
    func stopVideo(){
        if isRecording {
            if (!isSelfie) {
                flashButton.alpha = 1.0
                if isFlashExpanded {
                    flashButtonSetView.alpha = 1.0
                } else {
                    flashSelectedButton.alpha = 1.0
                }
                flashButton.enabled = true
                if let device = captureDevice where device.hasTorch {
                    device.lockForConfiguration(nil)
                    device.torchMode = AVCaptureTorchMode.Off
                    device.unlockForConfiguration()
                }
            }
            isRecording = false
            output.stopRecording()
        }
    }
    
    var currentSeconds:Int = 0
    var progressAmount:CGFloat = 0.05
    var secondsTimer = NSTimer()
    var progressTimer = NSTimer()
    
    func startTimer(){
        timerLabel.hidden = false
        secondsTimer = NSTimer(timeInterval: 1.0, target: self, selector: "timeDidUpdate", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(secondsTimer, forMode: NSDefaultRunLoopMode)
        progressTimer = NSTimer(timeInterval: 0.05, target: self, selector: "progressTimeDidUpdate", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(progressTimer, forMode: NSDefaultRunLoopMode)
    }
    
    func endTimer(){
        secondsTimer.invalidate()
        progressTimer.invalidate()
        currentSeconds = 0
        progressAmount = 0.0
        timerLabel.hidden = true
        resetProgressBar()
    }
    
    func timeDidUpdate(){
        currentSeconds++
        if currentSeconds > 9 {
            timerLabel.text = "00:\(currentSeconds)"
        } else {
            timerLabel.text = "00:0\(currentSeconds)"
        }
    }
    
    func progressTimeDidUpdate(){
        progressAmount = progressAmount + 0.05
        videoProgressView.frame = CGRectMake(videoProgressView.frame.origin.x, videoProgressView.frame.origin.y, (frame.width * progressAmount) / 11.0, videoProgressView.frame.height)
    }
    
    
    func resetProgressBar(){
        videoProgressView.frame = CGRectMake(videoProgressView.frame.origin.x, videoProgressView.frame.origin.y, 0, videoProgressView.frame.height)
    }
}

extension CameraView : AVCaptureFileOutputRecordingDelegate {
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        isRecording = false
        takeVideoView.hidden = true
        chooseOutputView.hidden = false
        galleryButton.hidden = false
        switchCameraButton.hidden = false
        backButton.hidden = false
        endTimer()
        self.displayVideo(outputFileURL)
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
    }
}

extension CameraView {
    func chooseImage(){
        var imagePicker = UIImagePickerController()
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        Tool.sharedInstance.myViewController!.presentViewController(imagePicker, animated: true, completion: nil)
    }
}

extension CameraView:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var tempImage:UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        tempImage = upOrientImage(tempImage)!
        picker.dismissViewControllerAnimated(true, completion: nil)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.displayImage(tempImage)
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        if !hasCamera {
            exit()
        }
    }
}