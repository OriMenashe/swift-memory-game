//
//  ViewController.swift
//  MemGame
//
//  Created by Ori Menashe on 3/18/16.
//  Copyright © 2016 Ori Menashe. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collView: UICollectionView!
    
    @IBOutlet weak var start: UIButton!
    
    @IBOutlet weak var stop: UIButton!
    
    var playerLbl: UILabel!
    
    let screenSize = UIScreen.mainScreen().bounds
    
    let DIMENTION = 4
    
    var images: [String] = []
    
    var shuffeledBoardImages: [String] = []
    
    var boardElements: [Card] = []
    
    var availableCardsCounter: Int = 0
    
    var match:[Card] = []
    
    var currentPlayer: Player?
    
    let players:[Player] = [Player(name: "Player 1"), Player(name: "Player 2")]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let list_size = pow(Double(self.DIMENTION), 2.0) / 2
        for i in 0 ..< Int(list_size){
            self.images.append("card\(i+1)")
        }
        self.view.layer.contents = UIImage(named: "background")!.CGImage
        self.collView.backgroundColor = UIColor(white: 1, alpha: 0.0)
        self.stop(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.DIMENTION
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.DIMENTION
    }

    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: Card = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! Card
        
        cell.prepare(self.shuffeledBoardImages[indexPath.row + indexPath.section * self.DIMENTION],
            indexPath: indexPath)
        boardElements.append(cell)
        return cell
    }

    func prepareBoardElements(images:[String]) -> [String] {
        var mixed_table: [String] = images + images
        for i in 0..<(mixed_table.count - 1) {
            var j = i
            while j == i {
                j = (Int(arc4random_uniform(UInt32(mixed_table.count - i))) + i)
            }
            swap(&mixed_table[i], &mixed_table[j])
        }
        return mixed_table
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! Card
        
        if self.match.count == 1 && cell.indexPath == match[0].indexPath {
            return
        }
        
        cell.select()
        self.match.append(cell)
        
        if (self.match.count == 2) {
            if match[0] != match[1]{
                self.switchTurnsWithDelay([match[0], match[1]])
            }else{
                self.availableCardsCounter -= 2
                self.currentPlayer!.updateCardsFound()
                if self.availableCardsCounter == 0{
                    self.declareWinner()
                }
            }
            self.match.removeAll()
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView: UICollectionReusableView!
        
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView: BoardHeader =
            collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "BoardHeader" , forIndexPath: indexPath) as! BoardHeader
            if (indexPath.section == 0){
                for player in players{
                    player.setUiLable(headerView.playerLbl)
                }
            }
            reusableView = headerView
        }
        return reusableView!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
    func switchTurnsWithDelay(cells:[Card]){
        
        //wait 2 secs
        let seconds = 1.0
        let delay = seconds * Double(NSEC_PER_SEC)
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        self.collView.userInteractionEnabled = false
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.switchTurns()
            cells[0].deSelect()
            cells[1].deSelect()
            self.collView.userInteractionEnabled = true
        })
    }

    func switchTurns(){
        self.currentPlayer!.pause()
        self.currentPlayer! = self.currentPlayer!.isEqual(players[0]) ? players[1] : players[0]
        self.currentPlayer!.start()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func declareWinner(){
        for player in players{
            player.pause()
        }
        self.collView.userInteractionEnabled = false
        let winner = players[0] > players[1] ? players[0] : players[1]
        let message = "\(winner.getPlayerName()) with \(winner.getScore()) points"
        let seconds = 1.0
        let delay = seconds * Double(NSEC_PER_SEC)
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            let alert = UIAlertController(title: "Winner!", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction = UIAlertAction(title: "Play again!", style: UIAlertActionStyle.Default)
                {
                    (UIAlertAction) -> Void in self.stop(self)
            }
            alert.addAction(alertAction)
            self.presentViewController(alert, animated: true)
                {
                    () -> Void in
            }
            self.collView.userInteractionEnabled = true
        })
    }
    
    @IBAction func stop(sender: AnyObject) {
        self.shuffeledBoardImages = self.prepareBoardElements(self.images)
        self.availableCardsCounter = self.shuffeledBoardImages.count
        for i in 0 ..< boardElements.count{
            let card = boardElements[i]
            card.prepare(shuffeledBoardImages[i], indexPath: card.indexPath)
            card.deSelect()
        }
        for player in players{
            player.clear()
        }
        players[0].updateUiLabel()
        self.collView.userInteractionEnabled = false
    }
    
    @IBAction func start(sender: AnyObject) {
        self.currentPlayer = self.players[0]
        self.collView.userInteractionEnabled = true
        self.currentPlayer!.start()
    }

}

func >(player1: Player, player2: Player) -> Bool {
    return player1.getScore() > player2.getScore()
}

func == (player1: Player, player2: Player) -> Bool {
    return player1.getCounter() == player2.getCounter()
}

func ==(card1: Card, card2: Card) -> Bool {
    return card1.getCardName() == card2.getCardName()
}

func !=(card1: Card, card2: Card) -> Bool {
    return card1.getCardName() != card2.getCardName()
}
