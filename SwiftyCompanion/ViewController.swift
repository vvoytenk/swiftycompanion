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
        requestManager()
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
    
    struct TokenResponse: Decodable {
        var identity: String
        var token: String
    }
    
    func requestManager() {
        
        let key = "0b5c29cb49d82af313050fbafa127ab97044364e77072264a7690d8424f3b144"
        let secret = "b98b0a8b5dee76cb57fe57bf3dee5d0ee2dfc1a30bd5a4bcd1d92b1e35d5d35f"
        
        let decoder = JSONDecoder()
        
        let url = URL(string: "https://api.intra.42.fr/oauth/token")!
        
        var request = URLRequest(url: url)
        let params = "grant_type=client_credentials client_id=\(key) client_secret=\(secret)"
        request.httpBody = params.data(using: .utf8, allowLossyConversion: true)
        request.httpMethod = "POST"
       // request.addValue("\(key):\(secret)", forHTTPHeaderField: "Authorization")
      //  var token = ""
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let json = data {
                do {
                    let tokenResponse = try decoder.decode(TokenResponse.self, from: json)
                    print(tokenResponse.identity)
                    print(tokenResponse.token)
                } catch {
                    print(error)
                }
            }
                else { if let error = error {
                    print(error)
                    }
                }
            }
            task.resume()
          //  print(String(data : data, encoding: .utf8)!)
          //  if let httpResponse = response as? HTTPURLResponse {
           // token = httpResponse.allHeaderFields["access_token"] as! String
           // print(token)
        }
}

