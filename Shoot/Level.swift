//
//  GameScene.swift
//  Shoot
//
//  Created by Ben Sutherland on 7/07/2015.
//  Copyright (c) 2015 BlenderSleuth Graphics. All rights reserved.
//

import SpriteKit

class Level: SKScene, SKPhysicsContactDelegate {
    
    override func didMoveToView(view: SKView) {
        initGun()
    }
    
    func initGun() {
        let gun = self.childNodeWithName("gun") as! SKSpriteNode
        gun.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame) + self.frame.size.height / 4)
        gun.size = CGSizeMake(CGRectGetWidth(self.frame) / 5, CGRectGetWidth(self.frame) / 5)
    }
    func initBullet()  -> SKSpriteNode {
        let bulletTexture = SKTexture(imageNamed: "bullet.png")
        let gun = self.childNodeWithName("gun") as! SKSpriteNode
        
        let bullet = SKSpriteNode(texture: bulletTexture)
        bullet.size = CGSizeMake(gun.size.width / 4, gun.size.height / 4)
        bullet.name = "bullet"
        bullet.position = CGPointMake(gun.position.x, gun.position.y / 3 * 4)
        bullet.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(bullet.size.width / 5, bullet.size.height))
        bullet.zPosition = 5
        return bullet
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in touches {
            let bullet = initBullet()
            self.addChild(bullet)
            bullet.physicsBody?.applyImpulse(CGVectorMake(0, 15))
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let UITouches = touches as? Set<UITouch> {
            for touch in UITouches {
                let location = touch.locationInNode(self)
                let touchedNode = nodeAtPoint(location)
                let gunNode = childNodeWithName("gun")
                
                if touchedNode == gunNode {
                    gunNode?.position.x = location.x
                }
            }
        }
    }

}
