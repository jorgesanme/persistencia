//
//  SceneDelegate.swift
//  MyNoteBook
//
//  Created by Jorge Sanchez on 25/01/2021.
//

import UIKit

//TODO primera tarea integrar core data al pricnipio de nuestra app.
// crear un data controller que le vamos a pasar a nuestro ViewController
// instaciar nuestro ViewController, pasandole el dataController.
// seterar el rootViewController del window.

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var dataController: DataController!


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        dataController = DataController(modelName: "MyNoteBook",
                                        optionalStoreName: nil,
                                        completionHandler: { persistenContainer in
                                            // aqui debe estar nuestro core data Stack inicializado
                                            
                                            guard  persistenContainer != nil else {
                                                fatalError("the core data stack was not created")
                                            }
                                            self.preloadData()                                            
        })
        
        guard let tablenotebookViewController = UIStoryboard(name: "Main",
                                                             bundle: nil)
                .instantiateViewController(identifier: "NoteBookTableViewControllerID")
                as? NoteBookTableViewController
        else {
            fatalError("NoteBookTableViewController could not be created.")
        }
        
        
        tablenotebookViewController.dataController = dataController
        guard let windowScene  = (scene as? UIWindowScene) else { return }
        self.window =  UIWindow(windowScene: windowScene)
        self.window?.rootViewController = UINavigationController(rootViewController: tablenotebookViewController)
        self.window?.makeKeyAndVisible()
        
        
        
    }
    
    func preloadData(){
        // se almacena en la preferencias del usuario si se han cargado los datos
        // en las siguientes no se deben cargar
        // para eso utilizamos UserDefaults y comprobamos el key 
        guard !UserDefaults.standard.bool(forKey: "hasPreloadData") else {
            return
        }
        
        UserDefaults.standard.set(true, forKey: "hasPreloadData")
        dataController.loadNotesInBackground()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        dataController.save()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        dataController.save()
    }


}

