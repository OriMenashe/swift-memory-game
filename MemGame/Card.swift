//
//  colvwCell.swift
//  MemGame
//
//  Created by Ori Menashe on 3/22/16.
//  Copyright © 2016 Ori Menashe. All rights reserved.
//

import UIKit

class Card: UICollectionViewCell {
    
    
    @IBOutlet weak var cardView: UIView!
    
    private var front: UIImageView!
    private var back: UIImageView = UIImageView(image: UIImage(named: "back"))
    
    private var initialized: Bool = false
    private var cardName: String!
    var indexPath: NSIndexPath!
    
    
    func prepare(frontImageName:String, indexPath: NSIndexPath){
        self.cardName = frontImageName
        self.indexPath = indexPath
        self.front = UIImageView(image: UIImage(named: self.cardName))
        self.front.frame = cardView.bounds
        self.back.frame = cardView.bounds
        cardView.addSubview(back)
        initialized = true
    }
    
    func deSelect(){
        guard initialized else{
            return
        }
        UIView.transitionFromView(front, toView: back, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
        self.userInteractionEnabled = true
    }
    
    func select(){
        guard initialized else{
            return
        }
        UIImageView.transitionFromView(back, toView: front, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
        self.userInteractionEnabled = false
    }
    
    func getCardName() -> String{
        return self.cardName
    }
    
}
