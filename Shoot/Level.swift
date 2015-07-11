//
//  GameScene.swift
//  Shoot
//
//  Created by Ben Sutherland on 7/07/2015.
//  Copyright (c) 2015 BlenderSleuth Graphics. All rights reserved.
//

import SpriteKit

class Level: SKScene, SKPhysicsContactDelegate {
    
    //Collision Categories
    let bulletCategory: UInt32 = 0x1 << 0
    let wallCategory: UInt32 = 0x1 << 1
    let enemyCategory: UInt32 = 0x1 << 2
    
    var bulletCount = 20
    var enemyCount = 4
    var points = 0
    
    override func didMoveToView(view: SKView) {
        initGun()
        initLabels()
        //initWall()
        initOnslaught()
        self.physicsWorld.contactDelegate = self
    }

    func initGun() {
        let gun = self.childNodeWithName("gun") as! SKSpriteNode
        
        gun.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame) + self.frame.size.height / 4)
        gun.size = CGSizeMake(CGRectGetWidth(self.frame) / 5, CGRectGetWidth(self.frame) / 5)
    }
    func initWall() {
        let wall = childNodeWithName("wall") as! SKSpriteNode
        //wall.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) / 5 * 4)
        //wall.size = CGSizeMake(self.frame.width / 4, self.frame.width / 16)
        
        wall.physicsBody?.categoryBitMask = wallCategory
        wall.physicsBody?.contactTestBitMask = bulletCategory
        wall.physicsBody?.collisionBitMask = bulletCategory
    }

    func initLabels() {
        let bulletLabel = childNodeWithName("bulletLabel") as! SKLabelNode
        bulletLabel.position = CGPointMake(CGRectGetMidX(self.frame) / 3, CGRectGetMaxY(self.frame) / 4 * 3)
        bulletLabel.text = "Bullets: \(bulletCount)"
        
        let pointLabel = childNodeWithName("pointLabel") as! SKLabelNode
        pointLabel.position = CGPointMake(CGRectGetMaxX(self.frame) / 6 * 5, CGRectGetMaxY(self.frame) / 4 * 3)
        pointLabel.text = "Points: \(points)"
    }
    func initBullet()  -> SKSpriteNode {
        let gun = self.childNodeWithName("gun") as! SKSpriteNode
        
        let bullet = SKSpriteNode(imageNamed: "bullet.png")
        bullet.size = CGSizeMake(gun.size.width / 4, gun.size.height / 4)
        bullet.name = "bullet"
        bullet.position = CGPointMake(gun.position.x, gun.position.y / 3 * 4)
        bullet.zPosition = 5
        
        //Physics Body
        bullet.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(bullet.size.width / 5, bullet.size.height))
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        //Collision Categories
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = wallCategory | enemyCategory
        bullet.physicsBody?.collisionBitMask = wallCategory | bulletCategory | enemyCategory
        return bullet
    }
    
    func gameOver() {
        println("Game Over")
    }
    func initOnslaught() {
        let action = [SKAction.runBlock({self.initEnemySpaceship()}), SKAction.waitForDuration(3)]
        let release = SKAction.sequence(action)
        
        self.runAction(SKAction.repeatAction(release, count: enemyCount), completion: nil)
    }
    func initEnemySpaceship(){
        let enemySpaceshipTexture = SKTexture(imageNamed: "alien_spaceship")
        let enemySpaceship = SKSpriteNode(texture: enemySpaceshipTexture)
        let enemyPositionX = CGFloat(arc4random_uniform(UInt32(CGRectGetMaxX(self.frame))) + 10)
        
        enemySpaceship.position = CGPointMake(enemyPositionX, CGRectGetMaxY(self.frame) + enemySpaceship.size.height)
        enemySpaceship.size = CGSizeMake(CGRectGetWidth(self.frame) / 6, CGRectGetWidth(self.frame) / 6)
        
        enemySpaceship.physicsBody = SKPhysicsBody(texture: enemySpaceshipTexture, size: enemySpaceship.size)
        enemySpaceship.physicsBody?.mass = 0.2
        
        enemySpaceship.physicsBody?.categoryBitMask = enemyCategory
        enemySpaceship.physicsBody?.collisionBitMask = bulletCategory | wallCategory
        enemySpaceship.physicsBody?.contactTestBitMask = bulletCategory
        
        self.addChild(enemySpaceship)
        
        enemySpaceship.physicsBody?.applyImpulse(CGVectorMake(0, -15))
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if bulletCount != 0 {
            let bullet = initBullet()
            self.addChild(bullet)
            --bulletCount
            bullet.physicsBody?.applyImpulse(CGVectorMake(0, 15))
        }
    }
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in touches as! Set<UITouch> {
            let location = touch.locationInNode(self)
            
            let touchedNode = nodeAtPoint(location)
            let gun = childNodeWithName("gun") as! SKSpriteNode
                
            if touchedNode == gun {
                gun.position.x = location.x
            }
        }
    }
    override func update(currentTime: NSTimeInterval) {
        let bulletLabel = childNodeWithName("bulletLabel") as! SKLabelNode
        bulletLabel.text = "Bullets: \(bulletCount)"
        
        let pointLabel = childNodeWithName("pointLabel") as! SKLabelNode
        pointLabel.text = "Points: \(points)"
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == wallCategory | bulletCategory {
            println("Hit Wall")
        }
        if collision == enemyCategory | bulletCategory {
            println("Hit Enemy")
            points++
        }
    }
}