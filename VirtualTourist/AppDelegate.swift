//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by André Brinkop on 12.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VirtualTourist")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                self.showErrorMessage(title: "Could not load persistent Store", message: error.localizedDescription)
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                self.showErrorMessage(title: "Could not save data", message: nserror.localizedDescription)
            }
        }
    }
    
    // MARK: Show error message
    
    private var currentlyShowingError: Bool = false
    func showErrorMessage(title: String, message: String? = nil) {
        // Don't flood the user with error messages
        if currentlyShowingError {
            return
        }
        
        currentlyShowingError = true
        DispatchQueue.main.async {
            let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {action in
                self.currentlyShowingError = false
            }))
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }

}

