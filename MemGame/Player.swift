//
//  Player.swift
//  MemGame
//
//  Created by Ori Menashe on 3/24/16.
//  Copyright © 2016 Ori Menashe. All rights reserved.
//

import Foundation
import UIKit

class Player:NSObject {

    private var playerName: String
    private var cardsFound: Int
    private var counter: Int
    private var playTimer: NSTimer
    private var playerLable: UILabel?
    
    init(name: String) {
        playerName = name
        counter = 0
        cardsFound = 0
        playTimer = NSTimer()
    }
    
    func setUiLable(uiLable: UILabel) {
        playerLable = uiLable
    }
    
    func updateUiLabel(){
        if (playerLable != nil){
            playerLable!.text = "\(getPlayerName()) - \(getPlayTime())"
        }
    }
    
    func updateCounter() {
        counter++
        self.updateUiLabel()
    }
    
    func start() {
        playTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
    }
    
    func pause() {
        playTimer.invalidate()
    }
    
    func clear() {
        playTimer.invalidate()
        cardsFound = 0
        counter = 0
    }
    
    func getPlayTime() -> String{
        return self.timeFormatted(self.counter)
    }
    
    func getCounter() -> Int{
        return self.counter
    }
    
    func getPlayerName() -> String{
        return self.playerName
    }
    
    
    func getCardsFound() -> Int{
        return self.cardsFound
    }
    
    func updateCardsFound(){
        self.cardsFound += 2
    }
    
    func getScore() -> Int{
        guard self.cardsFound > 0 && self.counter > 0 else{
            return 0
        }
        let avg = Double(self.cardsFound) / Double(self.counter)
        return Int(avg*1000)
    }
    
    private func timeFormatted(totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? Player {
            return self.playerName == object.playerName
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return self.playerName.hashValue
    }
}