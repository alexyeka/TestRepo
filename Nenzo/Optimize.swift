//
//  Optimize.swift
//  Nenzo
//
//  Created by sloot on 7/9/15.
//
//

import Foundation
import AVFoundation

class VideoQueue {
    var videos:[OptimizedVideo] = []
}

class OptimizedVideo {
    var videoURL:String?
    weak var videoView:UIVideoView?
    weak var thumbnailImageView:UIImageView?
    var oldTag:Int?
}

var videoCollection:NSMutableDictionary = NSMutableDictionary()

class OptimizedImage {
    weak var imageView:UIImageView?
    var imageURL:String?
    var oldTag:Int?
}

class ImageQueue {
    var images:[OptimizedImage] = []
}

class FailedMediaQueue {
    var failedTime:NSTimeInterval?
}

var imageCollection:NSMutableDictionary = NSMutableDictionary()

var imageCache:NSCache = NSCache()

func smartSet(image:UIImage, url:String){
    imageCache.setObject(image, forKey: url, cost: 0)
}

class NUIImageView : UIImageView {
    weak var loadingView:UIView?
    
    weak var loadedView:UIView?
    
    weak var label1:UILabel?
    
    weak var label2:UILabel?
    
    weak var view1:UIView?
    
    weak var borderView1:UIView?
    
    class var loadingColor:UIColor {
        get {
            return UIColor.lightGrayColor()
        }
    }
    
    class var nonLoadingColor:UIColor {
        get {
            return UIColor.whiteColor()
        }
    }
    
    func showLoading(){
        loadingView?.hidden = false
        loadedView?.hidden = true
        label1?.textColor = NUIImageView.loadingColor
        label2?.textColor = NUIImageView.loadingColor
        view1?.backgroundColor = NUIImageView.loadingColor
        borderView1?.layer.borderColor = NUIImageView.loadingColor.CGColor
    }
    
    func hideLoading(){
        loadingView?.hidden = true
        loadedView?.hidden = false
        label1?.textColor = NUIImageView.nonLoadingColor
        label2?.textColor = NUIImageView.nonLoadingColor
        view1?.backgroundColor = NUIImageView.nonLoadingColor
        borderView1?.layer.borderColor = NUIImageView.nonLoadingColor.CGColor
    }
}

extension UIImageView {
    func smartLoad(imgurl:String){
        smartLoad(imgurl, blur: false)
    }
    
    func smartLoad(imgurl:String, blur:Bool){
        var newtag = Int(arc4random_uniform(1048575))
        tag = newtag
        if let img = imageCache.objectForKey(imgurl) as? UIImage {
            self.image = img
            (self as? NUIImageView)?.hideLoading()
        } else {
            image = nil
            (self as? NUIImageView)?.showLoading()
            //Nil out image in case the imageView is in a resuable cell
            if let queue = imageCollection[imgurl] as? ImageQueue {
                var newOptimizedImage = OptimizedImage()
                newOptimizedImage.imageURL = imgurl
                newOptimizedImage.imageView = self
                newOptimizedImage.oldTag = tag
                queue.images.append(newOptimizedImage)
            } else {
                if let fqueue = imageCollection[imgurl] as? FailedMediaQueue, ftime = fqueue.failedTime where NSDate().timeIntervalSince1970 - ftime < 10.0 {
                    //Should hit here when image loading is failing due to internet connection/availability
                    //Only retry if it has been more than 10 seconds since last time it failed
                } else {
                    var queue = ImageQueue()
                    imageCollection[imgurl] = queue
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
                        if let url = NSURL(string: imgurl) {
                            let request: NSURLRequest = NSURLRequest(URL: url)
                            NSURLConnection.sendAsynchronousRequest(
                                request, queue: NSOperationQueue(),
                                completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                                    if error == nil {
                                        if let rImage = UIImage(data: data), retrievedImage = rImage.applyDarkEffect() {
                                            imageCache.setObject(retrievedImage, forKey: imgurl, cost: 0)
                                            if self.tag == newtag {
                                                dispatch_async(dispatch_get_main_queue()){
                                                    self.image = retrievedImage
                                                    (self as? NUIImageView)?.hideLoading()
                                                }
                                            }
                                            for optimizedImage in queue.images {
                                                if let t = optimizedImage.oldTag, imgView = optimizedImage.imageView where imgView.tag == t {
                                                    dispatch_async(dispatch_get_main_queue()){
                                                        imgView.image = retrievedImage
                                                        (imgView as? NUIImageView)?.hideLoading()
                                                    }
                                                }
                                            }
                                            imageCollection.removeObjectForKey(imgurl)
                                        }
                                    } else {
                                        //Most likely internet error
                                        var failedQueue = FailedMediaQueue()
                                        failedQueue.failedTime = NSDate().timeIntervalSince1970
                                        imageCollection[imgurl] = failedQueue
                                    }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func smartVideoThumbLoad(vidurl:String){
        println(NSDate().timeIntervalSince1970)
        var newtag = Int(arc4random_uniform(1048575))
        tag = newtag
        image = nil
        if let loadedVideoData = videoCache.objectForKey(vidurl) as? NSData {
            if let img = loadedVideoData.retrieveThumbnailImage(vidurl) {
                self.image = img
            }
        } else {
            if let queue = videoCollection[vidurl] as? VideoQueue {
                var newOptimizedVideo = OptimizedVideo()
                newOptimizedVideo.videoURL = vidurl
                newOptimizedVideo.thumbnailImageView = self
                newOptimizedVideo.oldTag = tag
                queue.videos.append(newOptimizedVideo)
            } else {
                if let fqueue = videoCollection[vidurl] as? FailedMediaQueue, ftime = fqueue.failedTime where NSDate().timeIntervalSince1970 - ftime < 10.0 {
                    println("too soon")
                } else {
                    var queue = VideoQueue()
                    videoCollection[vidurl] = queue
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
                        if let url = NSURL(string: vidurl) {
                            let request: NSURLRequest = NSURLRequest(URL: url)
                            NSURLConnection.sendAsynchronousRequest(
                                request, queue: NSOperationQueue(),
                                completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                                    println(NSDate().timeIntervalSince1970)
                                    println(data.length)
                                    if error == nil {
                                        videoCache.setObject(data, forKey: vidurl, cost: 0)
                                        for optimizedVideo in queue.videos {
                                            if let t = optimizedVideo.oldTag, vidView = optimizedVideo.videoView where vidView.tag == t {
                                                dispatch_async(dispatch_get_main_queue()){
                                                    vidView.play(data)
                                                }
                                            }
                                        }
                                        if let retrievedImage = data.retrieveThumbnailImage(vidurl) {
                                            if self.tag == newtag {
                                                dispatch_async(dispatch_get_main_queue()){
                                                    self.image = retrievedImage
                                                }
                                            }
                                            for optimizedVideo in queue.videos {
                                                if let t = optimizedVideo.oldTag, imgView = optimizedVideo.thumbnailImageView where imgView.tag == t {
                                                    dispatch_async(dispatch_get_main_queue()){
                                                        imgView.image = retrievedImage
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        var failedQueue = FailedMediaQueue()
                                        failedQueue.failedTime = NSDate().timeIntervalSince1970
                                        videoCollection[vidurl] = failedQueue
                                    }
                            })
                        }
                    }
                }
            }
        }
    }
}

var videoCache:NSCache = NSCache()

protocol UIVideoViewDelegate : class {
    func videoShouldPlay(withDuration:Float64) -> Bool
}

class UIVideoView : UIView {
    var sharedAVPlayerLayer:AVPlayerLayer = AVPlayerLayer()
    
    var urlID:Int = Int(arc4random_uniform(1048575))
    
    weak var delegate:UIVideoViewDelegate?
    
    var hasObserver:Bool = false
    
    deinit {
        if let player = self.sharedAVPlayerLayer.player where self.hasObserver {
            player.removeObserver(self, forKeyPath: "status")
            hasObserver = false
        }
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func playerItemDidReachEnd(notification:NSNotification){
        if let p = notification.object as? AVPlayerItem {
            p.seekToTime(kCMTimeZero)
        }
    }
    
    func storeVideo(data:NSData) -> NSURL {
        //let outputPath:String = "\(NSTemporaryDirectory())\(urlID).mov"
        let outputPath:String = "\(NSTemporaryDirectory())output.mov"
        let outputURL:NSURL = NSURL(fileURLWithPath: outputPath)!
        let fileManager:NSFileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(outputPath) {
            if !fileManager.removeItemAtPath(outputPath, error: nil) {
            }
        }
        data.writeToFile(outputPath, atomically: true)
        return outputURL
    }
}

extension UIVideoView {
    
    func play(data:NSData) -> Int {
        var url = storeVideo(data)
        
        var avPlayer:AVPlayer = AVPlayer(URL: url)
        
        avPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        if let player = sharedAVPlayerLayer.player where hasObserver {
            player.removeObserver(self, forKeyPath: "status")
            hasObserver = false
        }
        sharedAVPlayerLayer.player = avPlayer
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: avPlayer.currentItem)
        
        var screenRect:CGRect = UIScreen.mainScreen().bounds
        
        sharedAVPlayerLayer.frame = CGRectMake(0, 0, screenRect.width, screenRect.height)
        
        avPlayer.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.allZeros, context: nil)
        hasObserver = true
        return 0
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if let player = sharedAVPlayerLayer.player {
            if (object as? AVPlayer == player) && (keyPath == "status") {
                if player.status == AVPlayerStatus.ReadyToPlay {
                    dispatch_async(dispatch_get_main_queue()){
                        if self.hasObserver {
                            player.removeObserver(self, forKeyPath: "status")
                            self.hasObserver = false
                        }
                        if let dgt = self.delegate {
                            if dgt.videoShouldPlay(CMTimeGetSeconds(player.currentItem.asset.duration)) {
                                self.layer.addSublayer(self.sharedAVPlayerLayer)
                                player.play()
                            }
                        } else {
                            self.layer.addSublayer(self.sharedAVPlayerLayer)
                            player.play()
                        }
                    }
                }
            }
        }
    }
    
    func stop(){
        if let player = sharedAVPlayerLayer.player {
            player.pause()
        }
    }
    
    func replay(){
        if let player = sharedAVPlayerLayer.player {
            player.currentItem.seekToTime(kCMTimeZero)
            player.play()
        }
    }
    
    class func isLoaded(vidurl:String) -> Bool {
        return videoCache.objectForKey(vidurl) as? NSData != nil
    }
    
    func smartVideoLoad(vidurl:String){
        var newtag = Int(arc4random_uniform(1048575))
        tag = newtag
        if let loadedVideoData = videoCache.objectForKey(vidurl) as? NSData {
            play(loadedVideoData)
        } else {
            if let queue = videoCollection[vidurl] as? VideoQueue {
                var newOptimizedVideo = OptimizedVideo()
                newOptimizedVideo.videoURL = vidurl
                newOptimizedVideo.videoView = self
                newOptimizedVideo.oldTag = tag
                queue.videos.append(newOptimizedVideo)
            } else {
                if let fqueue = videoCollection[vidurl] as? FailedMediaQueue, ftime = fqueue.failedTime where NSDate().timeIntervalSince1970 - ftime < 10.0 {
                    println("too soon")
                } else {
                    var queue = VideoQueue()
                    videoCollection[vidurl] = queue
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
                        if let url = NSURL(string: vidurl) {
                            let request: NSURLRequest = NSURLRequest(URL: url)
                            NSURLConnection.sendAsynchronousRequest(
                                request, queue: NSOperationQueue(),
                                completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                                    if error == nil {
                                        videoCache.setObject(data, forKey: vidurl, cost: 0)
                                        for optimizedVideo in queue.videos {
                                            if let t = optimizedVideo.oldTag, vidView = optimizedVideo.videoView where vidView.tag == t {
                                                dispatch_async(dispatch_get_main_queue()){
                                                    vidView.play(data)
                                                }
                                            }
                                        }
                                        self.play(data)
                                    } else {
                                        var failedQueue = FailedMediaQueue()
                                        failedQueue.failedTime = NSDate().timeIntervalSince1970
                                        videoCollection[vidurl] = failedQueue
                                    }
                            })
                        }
                    }
                }
            }
        }
    }
    
    static func preload(vidurl:String){
        if let loadedVideoData = videoCache.objectForKey(vidurl) as? NSData {
        } else {
            if let queue = videoCollection[vidurl] as? VideoQueue {

            } else {
                if let fqueue = videoCollection[vidurl] as? FailedMediaQueue, ftime = fqueue.failedTime where NSDate().timeIntervalSince1970 - ftime < 10.0 {
                    println("too soon")
                } else {
                    var queue = VideoQueue()
                    videoCollection[vidurl] = queue
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
                        if let url = NSURL(string: vidurl) {
                            let request: NSURLRequest = NSURLRequest(URL: url)
                            NSURLConnection.sendAsynchronousRequest(
                                request, queue: NSOperationQueue(),
                                completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                                    if error == nil {
                                        videoCache.setObject(data, forKey: vidurl, cost: 0)
                                        for optimizedVideo in queue.videos {
                                            if let t = optimizedVideo.oldTag, vidView = optimizedVideo.videoView where vidView.tag == t {
                                                dispatch_async(dispatch_get_main_queue()){
                                                    vidView.play(data)
                                                }
                                            }
                                        }
                                    } else {
                                        var failedQueue = FailedMediaQueue()
                                        failedQueue.failedTime = NSDate().timeIntervalSince1970
                                        videoCollection[vidurl] = failedQueue
                                    }
                            })
                        }
                    }
                }
            }
        }
    }
}

extension NSData{
    func retrieveThumbnailImage(vidurl:String) -> UIImage? {
        println(NSDate().timeIntervalSince1970)
        if let img = imageCache.objectForKey(vidurl) as? UIImage {
            return img
        } else {
            let outputPath:String = "\(NSTemporaryDirectory())thumbnail.mov"
            let outputURL:NSURL = NSURL(fileURLWithPath: outputPath)!
            let fileManager:NSFileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(outputPath) {
                if !fileManager.removeItemAtPath(outputPath, error: nil) {
                }
            }
            writeToFile(outputPath, atomically: true)
            var asset:AVURLAsset = AVURLAsset(URL: outputURL, options: nil)
            var imageGenerator = AVAssetImageGenerator(asset: asset)
            if let rimg = UIImage(CGImage: imageGenerator.copyCGImageAtTime(CMTimeMake(0, 1), actualTime: nil, error: nil)), img = rimg.applyDarkEffect() {
                imageCache.setObject(img, forKey: vidurl, cost: 0)
                if fileManager.fileExistsAtPath(outputPath) {
                    if !fileManager.removeItemAtPath(outputPath, error: nil) {
                    }
                }
                println(NSDate().timeIntervalSince1970)
                return img
            } else {
                imageCache.setObject(UIImage(), forKey: vidurl, cost: 0)
                return nil
            }
        }
    }
}