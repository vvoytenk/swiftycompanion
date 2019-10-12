//
//  ViewController.swift
//  SwiftyCompanion
//
//  Created by Viktoriia Voitenko on 9/19/19.
//  Copyright © 2019 vvoy. All rights reserved.
//

import UIKit



class ViewController: UIViewController {
    
    struct requestProduct : Codable {
        var access_token: String!
        var token_type: String!
    }
    
    struct UserProduct : Codable {
        var id: Int
    }
    
    var login: String = ""
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    
    @IBAction func tapButton(_ sender: Any) {
        if process() {
            
        }
        else {
          //  errorMessage()
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
    
    func errorMessage(){
        let message = "Incorrect login!"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Try again", style: .default, handler: {
            action in
            self.textField.text = ""
        })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func process() -> Bool {
        login = textField.text ?? ""
        getToken(key: "0b5c29cb49d82af313050fbafa127ab97044364e77072264a7690d8424f3b144", secret: "b98b0a8b5dee76cb57fe57bf3dee5d0ee2dfc1a30bd5a4bcd1d92b1e35d5d35f")
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
    
    
    func getToken(key : String, secret : String) {
        
        let tokenRequest = createRequest(p_url: "https://api.intra.42.fr/oauth/token",
                                         p_body: "grant_type=client_credentials&client_id=\(key)&client_secret=\(secret)",
            p_method: "POST")
        
        
        let decoder = JSONDecoder()
        let task = URLSession.shared.dataTask(with: tokenRequest) { (data, response, error) in
            if let json = data {
                do {
                    let token = try decoder.decode(requestProduct.self, from: json)
                    self.createUserRequest(p_token: token.access_token, p_tokenType: token.token_type)
                    print(token.self)
                } catch {
                    print(error)
                }
            }
            else {if let error = error {
                print(error)
                }
            }
        }
        task.resume()
        
    }
    
    func createRequest(p_url: String, p_body: String, p_method: String) -> URLRequest{
        
        let url = URL(string: p_url)!
        
        var request = URLRequest(url: url)
        request.httpBody = p_body.data(using: .utf8)
        request.httpMethod = p_method
        return request
    }
    
    
    func createUserRequest (p_token : String, p_tokenType: String){
        
        let decoder = JSONDecoder()
        
        let url = URL(string: "https://api.intra.42.fr/v2/users/\(login)")!
        
        var userRequest = URLRequest(url: url)
        userRequest.httpMethod = "GET"
        // userRequest.httpBody = ("login=vvoytenk").data(using: .utf8)
        userRequest.setValue("Bearer \(p_token)", forHTTPHeaderField: "Authorization")
        
        
        let task = URLSession.shared.dataTask(with: userRequest) { (data, response, error) in
            if let json = data {
                do {
                    print(String(data: json, encoding: .utf8) as Any)
                    let user = try decoder.decode(UserProduct.self, from: json)
                   // print(user.self)
                } catch {
                    self.errorMessage()
                }
            }
            else {if error != nil {
                self.errorMessage()
                }
            }
        }
        task.resume()
        
        
    }
}

