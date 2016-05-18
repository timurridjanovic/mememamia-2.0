//
//  CreatedMeme.swift
//  Mememamia
//
//  Created by Timur Ridjanovic on 5/1/16.
//  Copyright © 2016 Timur Ridjanovic. All rights reserved.
//

import UIKit

protocol CreateMeme {
    func addMeme() -> UIViewController
    func selectMeme(meme: Meme) -> UIViewController
    func editMeme(meme: Meme) -> UIViewController
}

extension CreateMeme {
    func addMeme() -> UIViewController {
        let memeEditorVC: MemeEditorViewController = selectVC("MemeEditorViewController") as! MemeEditorViewController
        memeEditorVC.editMode = false
        return memeEditorVC
    }
    
    func selectMeme(meme: Meme) -> UIViewController {
        let memeDetailVC: MemeDetailViewController = selectVC("MemeDetailViewController") as! MemeDetailViewController
        memeDetailVC.meme = meme
        return memeDetailVC
    }
    
    func editMeme(meme: Meme) -> UIViewController {
        let memeEditorVC: MemeEditorViewController = selectVC("MemeEditorViewController") as! MemeEditorViewController
        memeEditorVC.editMode = true
        memeEditorVC.editModeMeme = meme
        return memeEditorVC
    }
    
    private func selectVC(viewControllerId: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(viewControllerId)
        return vc
    }
}
