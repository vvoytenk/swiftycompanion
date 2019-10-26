//
//  InfoPageViewController.swift
//  SwiftyCompanion
//
//  Created by Viktoriia Voitenko on 10/6/19.
//  Copyright © 2019 vvoy. All rights reserved.
//

import UIKit

class InfoPageViewController: UIViewController, UITableViewDataSource {

    struct UIDataSource {
        
        struct User {
            var photo: UIImage
            var name: String
            var login: String
            var lvl: Float
            var wallet: Int
        }
        
        var user: User
        
        struct Project {
            var name: String
            var score: Int
        }
        
        var projects: [Project]
        
        struct Skill {
            var skill: String
            var value: Float
        }
        
        var skills: [Skill]
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var projectsTableView: UITableView!
    @IBOutlet weak var skillsTableView: UITableView!
    
    public var dataSource: UIDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        projectsTableView.dataSource = self
        skillsTableView.dataSource = self
    }
    
    func updateUI() {
        guard let dataSource = dataSource else {
            return
        }
        
        userNameLabel.text = dataSource.user.name
        loginLabel.text = dataSource.user.login
        levelLabel.text = "Level: \(dataSource.user.lvl)"
        walletLabel.text = "Wallet: \(dataSource.user.wallet)"
        photoImageView.image = dataSource.user.photo
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == projectsTableView {
            return dataSource?.projects.count ?? 0
        }
        else if tableView == skillsTableView {
            return dataSource?.skills.count ?? 0
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataSource = dataSource else {
           return UITableViewCell()
        }
        
        if tableView == projectsTableView {
            let projectCell = tableView.dequeueReusableCell(withIdentifier: "ProjectLabelCell", for: indexPath)
            projectCell.textLabel?.text = dataSource.projects[indexPath.row].name
            projectCell.detailTextLabel?.text = "\(dataSource.projects[indexPath.row].score)"
            return projectCell
        }
        else if tableView == skillsTableView {
            let skillCell = tableView.dequeueReusableCell(withIdentifier: "SkillLabelCell", for: indexPath)
            skillCell.textLabel?.text = dataSource.skills[indexPath.row].skill
            skillCell.detailTextLabel?.text = "\(dataSource.skills[indexPath.row].value)"
            return skillCell
        }
        else {
            return UITableViewCell()
        }
    }
    
}
