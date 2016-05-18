//
//  MemeDetailViewController.swift
//  Mememamia
//
//  Created by Timur Ridjanovic on 5/17/16.
//  Copyright © 2016 Timur Ridjanovic. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController, CreateMeme {
    @IBOutlet weak var imageView: UIImageView!
    var meme: Meme!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        imageView.image = meme.memedImage!
        self.tabBarController?.tabBar.hidden = true
    }
    
    @IBAction func editMemeEvent(sender: UIBarButtonItem) {
        navigationController?.pushViewController(editMeme(meme), animated: true)
    }

}
