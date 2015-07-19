//
//  GameOver.swift
//  Shoot
//
//  Created by Benjamin Sutherland on 11/07/2015.
//  Copyright (c) 2015 BlenderSleuth Graphics. All rights reserved.
//

import SpriteKit

class GameOver: SKScene {
    
    var points = 0
    
    override func didMoveToView(view: SKView) {
        initScore()
    }
    
    func initScore() {
        let scoreLabel = childNodeWithName("scoreLabel") as! SKLabelNode
        scoreLabel.text = "Score: \(points)"
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let UITouches = touches as? Set<UITouch> {
            for touch in UITouches {
                let location = touch.locationInNode(self)
                let touchedNode = nodeAtPoint(location)
                
                if touchedNode == childNodeWithName("backButton") || touchedNode == childNodeWithName("mainMenu"){
                    let button = childNodeWithName("backButton") as! SKSpriteNode
                    button.color = UIColor.purpleColor()
                    let scene = MainMenu(fileNamed: "MainMenu")
                    self.view?.presentScene(scene)
                }
            }
        }
    }
}