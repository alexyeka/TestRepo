//
//  CoreDataTool.swift
//  Nenzo
//
//  Created by sloot on 6/3/15.
//
//

import UIKit
import CoreData
private let _CoreDataToolSharedInstance = CoreDataTool()
class CoreDataTool: NSObject {
    class var sharedInstance: CoreDataTool {
        return _CoreDataToolSharedInstance
    }
        
    func retrieveManagedObject(entity:String) -> NSManagedObject? {
        let fetchRequest = NSFetchRequest(entityName:entity)
        var error: NSError?
        
        let fetchedResults = managedObjectContext!.executeFetchRequest(fetchRequest,
            error: &error) as! [NSManagedObject]?
        
        if let results = fetchedResults {
            if(results.count > 0){
                return results[0] as NSManagedObject
            }
            else{
                return nil
            }
        }
        return nil
    }
        
    /*
    Checks all Cookies that is currently present and stores _papaly_session and remember_user_token Cookies
    inside of CoreData as part of Profile attributes. Should always be called when Cookies are recieved for the first time.
    */
    func saveCookies() {
        var storage:NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        var cookieArray:NSArray = storage.cookies!
        
//        let fetchRequest = NSFetchRequest(entityName:"Profile")
//        
//        var error: NSError?
        
        for cookie in cookieArray{
            if let name = cookie.name where name == NENZO_COOKIE_NAME {
                if let c = cookie as? NSHTTPCookie, v = c.value {
                    NSUserDefaults.standardUserDefaults().setObject(v, forKey: "nenzo_cookie")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
            }
            //                        if(cookie.name == "_papaly_session"){
            //                            _papaly_session = (cookie as! NSHTTPCookie).value!
            //                            userProfile.papaly_session = (cookie as NSHTTPCookie).value!
            //                        }
            //                        else if(cookie.name == "remember_user_token"){
            //                            remember_user_token = (cookie as! NSHTTPCookie).value!
            //                            userProfile.remember_user_token = (cookie as NSHTTPCookie).value!
            //                        }
        }
//        if !managedObjectContext!.save(&error) {
//            coreDataError()
//        }
        
        
//        let fetchedResults =
//        managedObjectContext!.executeFetchRequest(fetchRequest,
//            error: &error) as! [NSManagedObject]?
//        if let results = fetchedResults {
//            if(results.count>0){
//                var userProfile:Profile = results[0] as! Profile
//                
//                for cookie in cookieArray{
////                        if(cookie.name == "_papaly_session"){
////                            _papaly_session = (cookie as! NSHTTPCookie).value!
////                            userProfile.papaly_session = (cookie as NSHTTPCookie).value!
////                        }
////                        else if(cookie.name == "remember_user_token"){
////                            remember_user_token = (cookie as! NSHTTPCookie).value!
////                            userProfile.remember_user_token = (cookie as NSHTTPCookie).value!
////                        }
//                }
//                if !managedObjectContext!.save(&error) {
//                    coreDataError()
//                }
//                else{
//                    println("Saved")
//                }
//            }
//            else{
//                coreDataError()
//            }
//        } else {
//            coreDataError()
//        }
    }
        
    /*
    Generic Core Data Error. Call this function when handling errors from CoreData. Should almost never be called. If this method
    is called the user's CoreData is most likely corrupted
    */
    func coreDataError(){
        println("CORRUPTED CORE DATA")
    }
        
    /*
    Clears all Cookies. If Cookies are not present when making REST calls to the server you may get a redirection to the root_url
    and recieve HTML response instead of a JSON response. Thus, be extremely careful when calling this function.
    */
    func clearCookies(){
        var storage:NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        var cookieArray:NSArray = storage.cookies!
        for cookie in cookieArray{
            storage.deleteCookie(cookie as! NSHTTPCookie)
        }
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    /*
    Clears all Profiles. There should only be one Profile in CoreData at any given time but just for extra insurance it will delete
    all Profiles
    */
    func clearUserProfile(){
        clearEntity("Profile")
    }
    
    func clearUser(){
        clearEntity("User")
    }
    
    func clearEntity(entity:String){
        let fetchRequest = NSFetchRequest(entityName:entity)
        
        var error: NSError?
        
        let fetchedResults =
        managedObjectContext!.executeFetchRequest(fetchRequest,
            error: &error) as! [NSManagedObject]?
        
        if let results = fetchedResults {
            for profile in results {
                managedObjectContext!.deleteObject(profile)
            }
            managedObjectContext!.save(nil)
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Papaly", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        
        let directory:NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.Papaly")!
        let storeURL:NSURL = directory.URLByAppendingPathComponent("Papaly")
        var err:NSError?
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        let mOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true]
        
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: mOptions, error: &error) == nil{
            println("Attempting to resolve Core Data issue")
            //Corrupted Core Data, try to resolve by compeltely killing previous and replacing
            var fileManager : NSFileManager = NSFileManager.defaultManager()
            fileManager.removeItemAtURL(storeURL, error: &err)
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) == nil{
                println("Core Data resolving failed")
                coordinator = nil
                // Report any error we got.
                let dict = NSMutableDictionary()
                dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
                dict[NSLocalizedFailureReasonErrorKey] = failureReason
                dict[NSUnderlyingErrorKey] = error
                //                error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
                self.coreDataError()
            }
            else{
                //                self.managedObjectContext!.reset()
                //                println("Core Data successfully fixed")
            }
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = managedObjectContext {
            var error: NSError? = nil
            if !moc.save(&error) {
                coreDataError()
            }
        }
    }
}
