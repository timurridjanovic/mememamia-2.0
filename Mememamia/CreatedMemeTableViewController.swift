//
//  CreatedMemeTableViewController.swift
//  Mememamia
//
//  Created by Timur Ridjanovic on 5/1/16.
//  Copyright © 2016 Timur Ridjanovic. All rights reserved.
//

import UIKit

private let reuseIdentifier = "memeTableViewCell"

class CreatedMemeTableViewController: UITableViewController, CreateMeme {
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    let cellHeight: Float = 100.0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
        tabBarController?.tabBar.hidden = false
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return memes.count
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(cellHeight)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MemeTableViewCell
        
        cell.topText?.text = memes[indexPath.section].topText!
        cell.bottomText?.text = memes[indexPath.section].bottomText!
        cell.memeImageView?.image = memes[indexPath.section].memedImage
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        navigationController?.pushViewController(selectMeme(memes[indexPath.section]), animated: true)
    }
    
    @IBAction func addMemeEvent(sender: UIBarButtonItem) {
        navigationController?.pushViewController(addMeme(), animated: true)
    }
}
