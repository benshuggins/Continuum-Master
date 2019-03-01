//
//  UIViewControllerExtension.swift
//  Continuum
//
//  Created by Ben Huggins on 2/28/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentSimpleAlertWith(title: String, message: String?) {
        func presentSimpleAlertWith(title: String, message: String?) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertController.addAction(okayAction)
            present(alertController, animated: true)
         
    }
}
}
