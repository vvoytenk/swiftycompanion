//
//  ViewController.swift
//  SwiftyCompanion
//
//  Created by Viktoriia Voitenko on 9/19/19.
//  Copyright © 2019 vvoy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBAction func tapButton(_ sender: Any) {
        if validation() {
            
        }
        else {
            let message = "Incorrect login!"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Try again", style: .default, handler: {
                action in
                self.textField.text = ""
            })
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide keyboard before search
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        //add events for show/hide keyboard on screen
        NotificationCenter.default.addObserver(self, selector: #selector(keybordIsShown(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keybordIsHiden(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    func validation() -> Bool {
        return false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keybordIsShown(notification : NSNotification) {
        scrollView.setContentOffset(CGPoint.init(x:0, y:60), animated: true)
    }
    
    @objc func keybordIsHiden(notification : NSNotification) {
        scrollView.setContentOffset(CGPoint.init(x:0, y:0), animated: true)
    }
}

