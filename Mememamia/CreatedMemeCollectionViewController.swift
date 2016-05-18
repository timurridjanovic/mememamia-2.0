//
//  CreatedMemeCollectionViewController.swift
//  Mememamia
//
//  Created by Timur Ridjanovic on 5/1/16.
//  Copyright © 2016 Timur Ridjanovic. All rights reserved.
//

import UIKit

class CreatedMemeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CreateMeme {
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    private let reuseIdentifier = "memeCollectionViewCell"
    private var screenWidth: CGFloat!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
        self.tabBarController?.tabBar.hidden = false
        setFlowLayout()
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MemeCollectionViewCell
        cell.memeImageView.image = memes[indexPath.item].memedImage!
    
        return cell
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        setFlowLayout()
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        navigationController?.pushViewController(selectMeme(memes[indexPath.row]), animated: true)
    }
    
    @IBAction func addMemeEvent(sender: UIBarButtonItem) {
        navigationController?.pushViewController(addMeme(), animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: screenWidth/3 - 1, height: screenWidth/3);
    }
    
    private func setFlowLayout() {
        screenWidth = UIScreen.mainScreen().bounds.width
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/3)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        collectionView?.setCollectionViewLayout(layout, animated: true)
    }
}
