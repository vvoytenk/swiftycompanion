//
//  ViewController.swift
//  SwiftyCompanion
//
//  Created by Viktoriia Voitenko on 9/19/19.
//  Copyright © 2019 vvoy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    struct RequestProduct : Codable {
        var access_token: String
        var token_type: String
    }
    
    struct ParsingData : Codable {
        
        struct Cursus : Codable {
            var id: Int
        }
        
        struct CursusUsers : Codable {
            
            var level: Float
            var grade: String?
            var skills: [Skills]
            var cursus: Cursus
        }
        
        struct Skills : Codable {
            var name: String
            var level: Float
        }
        
        struct Project : Codable{
            var slug: String
        }
        
        struct Projects : Codable {
            var project: Project
            var final_mark: Int?
        }
        
        var login: String
        var displayname: String
        var wallet: Int
        var image_url: String
        var cursus_users: [CursusUsers]
        var projects_users : [Projects]
    }

    var login: String = ""
    var token: RequestProduct?
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
 
    @IBAction func tapButton(_ sender: Any) {
        process()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide keyboard before search
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        //add events for show/hide keyboard on screen
        /*NotificationCenter.default.addObserver(self, selector: #selector(keybordIsShown(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keybordIsHiden(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)*/
    }
    
    func errorMessage() {
        DispatchQueue.main.async {
            let message = "Incorrect login!"
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Try again", style: .default, handler: {
                action in
                self.textField.text = ""
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func process()  {
        login = textField.text ?? ""
        
        guard let token = self.token else {
            return getToken(key: "723f085b50e4eaaaeee26c2a28169fad566481af02bb211a4a78f8532fce77de",
                            secret: "6a1041ae669d61c965ef254e089320106ed6d92053de75d3dea426077c57cf31")
        }
        getUser(p_token: token.access_token, p_tokenType: token.token_type)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /*@objc func keybordIsShown(notification : NSNotification) {
        scrollView.setContentOffset(CGPoint.init(x:0, y:60), animated: true)
    }
    
    @objc func keybordIsHiden(notification : NSNotification) {
        scrollView.setContentOffset(CGPoint.init(x:0, y:0), animated: true)
    }*/
    
    func getToken(key : String, secret : String) {
        
        let tokenRequest = createRequest(p_url: "https://api.intra.42.fr/oauth/token",
                                         p_body: "grant_type=client_credentials&client_id=\(key)&client_secret=\(secret)",
                                         p_method: "POST")
        
        let task = URLSession.shared.dataTask(with: tokenRequest) { (data, response, error) in
            if let json = data {
                guard let token = try? JSONDecoder().decode(RequestProduct.self, from: json) else {
                    return self.errorMessage()
                }
                self.token = token
                self.getUser(p_token: token.access_token, p_tokenType: token.token_type)
            }
            else {
                self.errorMessage()
            }
        }
        task.resume()
    }
    
    func getUser(p_token : String, p_tokenType: String) {
        
        var userRequest = createRequest(p_url: "https://api.intra.42.fr/v2/users/\(login)",
                                        p_body: "",
                                        p_method: "GET")
        userRequest.setValue("\(p_tokenType) \(p_token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: userRequest) { (data, response, error) in
            if let json = data {
                do {
                    let userInfo = try JSONDecoder().decode(ParsingData.self, from: json)
                    guard let info = self.convertToSourceData(data: userInfo) else {
                        return self.errorMessage()
                    }

                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "SegueToInfoPage", sender: info)
                        self.textField.text = ""
                    }
                } catch {
                    self.errorMessage()
                }
            }
            else {
                self.errorMessage()
            }
        }
        
        task.resume()
    }
    
    func createRequest(p_url: String, p_body: String, p_method: String) -> URLRequest {
        
        var url = URL(string: "https://api.intra.42.fr/")!
         
        if let tmp_url = URL(string: p_url.trimmingCharacters(in: CharacterSet(charactersIn: " "))) {
            url = tmp_url
        }

        var request = URLRequest(url: url)
        request.httpBody = p_body.data(using: .utf8)
        request.httpMethod = p_method
        return request
    }
    
    func convertToSourceData(data: ParsingData) -> InfoPageViewController.UIDataSource? {
        
        guard let url = URL(string: data.image_url), let image = try? Data(contentsOf: url), let photo = UIImage(data: image) else {
            return nil
        }
        
        guard let cursus42 = data.cursus_users.filter({ (cursusUser) -> Bool in
            return (cursusUser.cursus.id == 1)
        }).first else {
            return nil
        }
        
        let user = InfoPageViewController.UIDataSource.User(photo: photo, name: data.displayname, login: data.login,
                                                            lvl: cursus42.level, wallet: data.wallet)
        
        let projects = data.projects_users.map { (project) -> InfoPageViewController.UIDataSource.Project in
            InfoPageViewController.UIDataSource.Project(name: project.project.slug, score: project.final_mark ?? 0)
        }
        
        let skills = cursus42.skills.map { (skill) -> InfoPageViewController.UIDataSource.Skill in
            InfoPageViewController.UIDataSource.Skill(skill: skill.name, value: skill.level)
        }
        
        return InfoPageViewController.UIDataSource(user: user, projects: projects, skills: skills)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "SegueToInfoPage" else {
            return
        }
        
        guard let dataSource = sender as? InfoPageViewController.UIDataSource else {
            return
        }
        
        (segue.destination as? InfoPageViewController)?.dataSource = dataSource
    }

}
