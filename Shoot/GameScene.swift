//
//  GameScene.swift
//  Shoot
//
//  Created by Ben Sutherland on 7/07/2015.
//  Copyright (c) 2015 BlenderSleuth Graphics. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //basescene? or levels
    
    let gun = SKSpriteNode(imageNamed: "spaceship.png")
    
    override func didMoveToView(view: SKView) {
        initGun()
        self.backgroundColor = UIColor.purpleColor()
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        //self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size, center: CGPointMake(self.frame.width/2, self.frame.height / 2))
    }
    
    func initGun() {
        gun.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame) + self.frame.size.height / 4)
        gun.size = CGSizeMake(CGRectGetWidth(self.frame) / 5, CGRectGetWidth(self.frame) / 5)
        gun.zPosition = 10
        gun.name = "gun"
        self.addChild(gun)
    }
    
    func initBullet()  -> SKSpriteNode {
        let bulletTexture = SKTexture(imageNamed: "bullet.png")
        
        let bullet = SKSpriteNode(texture: bulletTexture)
        bullet.size = CGSizeMake(gun.size.width / 4, gun.size.height / 4)
        bullet.name = "bullet"
        bullet.position = CGPointMake(gun.position.x, gun.position.y + gun.size.height / 3)
        bullet.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(bullet.size.width / 5, bullet.size.height))
        bullet.zPosition = 5
        return bullet
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in touches {
            let bullet = initBullet()
            self.addChild(bullet)
            bullet.physicsBody?.applyImpulse(CGVectorMake(0, 20))
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
