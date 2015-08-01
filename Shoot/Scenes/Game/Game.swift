//
//  GameScene.swift
//  Shoot
//
//  Created by Ben Sutherland on 7/07/2015.
//  Copyright (c) 2015 BlenderSleuth Graphics. All rights reserved.
//

import SpriteKit
import UIKit
import CoreMotion

//Collision Categories
let bulletCategory: UInt32 = 0x1 << 0
let enemyCategory: UInt32 = 0x1 << 1
let playerCategory: UInt32 = 0x1 << 2
let boundaryCategory: UInt32 = 0x1 << 3
let bonusBulletCategory: UInt32 = 0x1 << 4

class Game: SKScene, SKPhysicsContactDelegate {
    //MARK: Properties
    let playerName = "player"
    let backgroundSpeed: Double = 300
    var background: SKNode!
    
    //MARK: Time variables
    var delta = NSTimeInterval(0)
    var lastUpdateTime = NSTimeInterval(0)
    
    //MARK: HUD Variables
    var points = 0
    var lives = 1000
    var bulletCount = 50
    
    //MARK: Enemy properties
    let enemySpeed: NSTimeInterval = 6 //seconds to get to bottom of screen
    let enemyFrequency: NSTimeInterval = 3 //seconds between enemies
    
    //MARK: Motion Manager
    let motionManager: CMMotionManager = CMMotionManager()
    
    override func didMoveToView(view: SKView) {
        motionManager.startAccelerometerUpdates()
        physicsWorld.contactDelegate = self
        setupWorld()
        setupPlayer()
        setupHUD()
        startWave()
    }
    
    //MARK: Scene setup
    func setupHUD() {
        let pointLabel = childNodeWithName("pointLabel") as! SKLabelNode
        pointLabel.text = "Points: \(points)"
        
        
        let lifeLabel = childNodeWithName("lifeLabel") as! SKLabelNode
        lifeLabel.text = "Lives: \(lives)"
        
        let player = childNodeWithName(playerName) as! SKSpriteNode
        let bulletLabel = player.childNodeWithName("bulletLabel") as! SKLabelNode
        bulletLabel.text = "\(bulletCount)"
    }
    func setupWorld() {
        let point1 = CGPointMake(0, -CGRectGetWidth(frame) / 6)
        let point2 = CGPointMake(CGRectGetMaxX(frame), -CGRectGetWidth(frame) / 6)
        let point3 = CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame))
        let point4 = CGPointMake(0, CGRectGetMaxY(frame))
        
        let physicsBody1 = SKPhysicsBody(edgeFromPoint: point1, toPoint: point2)
        let physicsBody2 = SKPhysicsBody(edgeFromPoint: point1, toPoint: point4)
        let physicsBody3 = SKPhysicsBody(edgeFromPoint: point2, toPoint: point3)
        
        let bodies = [physicsBody1, physicsBody2, physicsBody3]
        
        physicsBody = SKPhysicsBody(bodies: bodies)
        physicsBody?.dynamic = false
        physicsBody?.categoryBitMask = boundaryCategory
        physicsBody?.collisionBitMask = bulletCategory
        physicsBody?.contactTestBitMask = enemyCategory
        setupBackground()
    }
    
    func setupBackground() {
        let backgroundTexture = SKTexture(imageNamed: "background")
        
        background = SKNode()
        addChild(background)

        for i in 0...2 {
            let tile = SKSpriteNode(texture: backgroundTexture)
            tile.anchorPoint = CGPointZero
            tile.position = CGPoint(x: 0, y: CGFloat(i) * backgroundTexture.size().height)
            tile.name = "bg"
            background.addChild(tile)
        }
    }
    func moveBackground() {
        let positionY = -backgroundSpeed * delta
        
        background.position = CGPoint(x: 0, y: background.position.y + CGFloat(positionY))
        
        background.enumerateChildNodesWithName("bg", usingBlock: {(node, stop) in
            let backgroundScreenPosition = self.background.convertPoint(node.position, toNode: self)
            
            if backgroundScreenPosition.y <= -node.frame.size.height {
                node.position = CGPointMake(node.position.x, node.position.y + (node.frame.size.height * 2))
            }
        })
    }
    
    func setupPlayer() {
        let player = childNodeWithName(playerName) as! SKSpriteNode
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = enemyCategory | bonusBulletCategory
        player.physicsBody?.collisionBitMask = boundaryCategory
        player.physicsBody?.mass = 0.01
    }
    func startWave() {
        var bulletFrequency: NSTimeInterval = 10
        let bulletActions = [
            SKAction.runBlock{
                bulletFrequency = NSTimeInterval(arc4random_uniform(100) + 100)
            },
            SKAction.runBlock{self.setupBonusbullet()},
            SKAction.waitForDuration(bulletFrequency)
        ]
        
        let action = [
            SKAction.runBlock{self.setupEnemy()},
            SKAction.waitForDuration(enemyFrequency)
        ]
        let release = SKAction.sequence(action)
        let releaseBullet = SKAction.sequence(bulletActions)
        
        self.runAction(SKAction.repeatActionForever(release))
        self.runAction(SKAction.repeatActionForever(releaseBullet))
    }
    
    func setupEnemy(){
        let size = CGSizeMake(CGRectGetWidth(frame) / 8, CGRectGetWidth(frame) / 8)
        
        let enemyPositionX = CGFloat(arc4random_uniform(UInt32(CGRectGetWidth(frame) - 200)) + 100)
        let enemyPosition = CGPointMake(enemyPositionX, CGRectGetHeight(frame) + size.height / 2)
        
        let enemy = EnemyNode(size: size, position: enemyPosition)
        self.addChild(enemy)
        
        let actionArray = [SKAction.moveToY(-enemy.size.height, duration: enemySpeed), SKAction.runBlock{enemy.removeFromParent()}]
        let sequence = SKAction.sequence(actionArray)
        
        enemy.runAction(sequence)
    }
    func setupBonusbullet() {
        let bonusBulletPositionX = CGFloat(arc4random_uniform(UInt32(CGRectGetWidth(frame) - 200)) + 100)
        let bonusBulletPosition = CGPointMake(bonusBulletPositionX, CGRectGetHeight(frame) + size.height / 2)
        
        let bonusBullet = SKSpriteNode(imageNamed: "bonusBullet")
        bonusBullet.size = CGSizeMake(CGRectGetWidth(frame) / 16, CGRectGetWidth(frame) / 16)
        bonusBullet.position = bonusBulletPosition
        
        bonusBullet.physicsBody = SKPhysicsBody(circleOfRadius: bonusBullet.size.width / 7 * 3)
        bonusBullet.physicsBody?.categoryBitMask = bonusBulletCategory
        bonusBullet.physicsBody?.collisionBitMask = enemyCategory
        bonusBullet.physicsBody?.contactTestBitMask = bulletCategory
        
        addChild(bonusBullet)
        
        let actionArray = [SKAction.moveToY(-bonusBullet.size.height, duration: enemySpeed - 3), SKAction.runBlock{bonusBullet.removeFromParent()}]
        bonusBullet.runAction(SKAction.sequence(actionArray))
    }
    
    //MARK: Gameover
    func gameOver() {
        let scene = GameOver(fileNamed: "GameOver")
        scene.points = self.points
        self.view?.presentScene(scene)
    }
    
    //MARK: Bullet setup
    func setupBullet()  -> SKSpriteNode {
        let player = childNodeWithName(playerName) as! SKSpriteNode
        
        let bulletSize = CGSizeMake(player.size.width / 16, player.size.height / 4)
        
        let bullet = SKSpriteNode(color: UIColor.purpleColor(), size: bulletSize)
        bullet.name = "bullet"
        bullet.position = CGPointMake(player.position.x, player.position.y / 3 * 4)
        bullet.zPosition = 5
        
        //Physics Body
        bullet.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(bullet.size.width, bullet.size.height))
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        //Collision Categories
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = enemyCategory
        bullet.physicsBody?.collisionBitMask = bulletCategory | enemyCategory
        return bullet
    }
    
    //MARK: Bullet fire
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if bulletCount != 0 {
            --bulletCount
            updateBullets()
            let bullet = setupBullet()
            addChild(bullet)
            bullet.physicsBody?.applyImpulse(CGVectorMake(0, 15))
        }
    }
    
    //MARK: Motion update
    override func update(currentTime: NSTimeInterval) {
        delta = (lastUpdateTime == 0) ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        moveBackground()
        
        processUserMotionForUpdate(currentTime)
    }
    
    //MARK: Motion controls
    func processUserMotionForUpdate(currentTime: CFTimeInterval) { 
        let circle = childNodeWithName(playerName) as! SKSpriteNode
        
        if let data = motionManager.accelerometerData {
            //if UIDevice.currentDevice().orientation == .LandscapeRight {
                if fabs(data.acceleration.y) > 0.15 {
                    circle.physicsBody?.applyForce(CGVectorMake(30 * CGFloat(data.acceleration.y), 0))
                }
            //} else if UIDevice.currentDevice().orientation == .LandscapeLeft {
                //if fabs(-data.acceleration.y) > 0.15 {
                  //  circle.physicsBody?.applyForce(CGVectorMake(30 * CGFloat(-data.acceleration.y), 0))
                //}
            //}
        }
    }
    
    //MARK: Contact
    func didBeginContact(contact: SKPhysicsContact) {
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == enemyCategory | bulletCategory {
            var enemy = contact.bodyA.node as? EnemyNode
            var bullet = contact.bodyB.node as! SKSpriteNode
            
            if contact.bodyB.categoryBitMask == enemyCategory {
                enemy = contact.bodyB.node as? EnemyNode
                bullet = contact.bodyA.node as! SKSpriteNode
            }
            let point = enemy!.convertPoint(contact.contactPoint, fromNode: self)
            
            enemyHit(enemy!, bullet: bullet, point: point)
        }
        if collision == enemyCategory | boundaryCategory {
            --lives
            updateLives()
            if lives == 0 {
                gameOver()
            }
        }
        
        if collision == bulletCategory | bonusBulletCategory {
            bulletCount += 5
            updateBullets()
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
        }
        if collision == playerCategory | bonusBulletCategory {
            bulletCount += 5
            updateBullets()
        }
    }
    
    //MARK: Enemy Helpers
    func enemyHit(enemy: EnemyNode, bullet: SKSpriteNode, point: CGPoint) {
        let fire = SKEmitterNode(fileNamed: "AlienFireDamage.sks")
        fire.position = point
        enemy.addChild(fire)
        switch enemy.health {
        case 4:
            enemy.texture = SKTexture(imageNamed: "circle_cracked1")
            --enemy.health
        case 3:
            enemy.texture = SKTexture(imageNamed: "circle_cracked2")
            --enemy.health
        case 2:
            enemy.texture = SKTexture(imageNamed: "circle_cracked3")
            --enemy.health
        case 1:
            enemy.texture = SKTexture(imageNamed: "circle_cracked4")
            enemySmoke(enemy)
            --enemy.health
        case 0:
            enemyExpode(enemy)
        default:
            break
        }
        bullet.removeFromParent()
        points++
        updatePoints()
    }
    func enemySmoke(enemy: EnemyNode) {
        let smoke = SKEmitterNode(fileNamed: "AlienDamageSmoke.sks")
        let position = CGPointMake(CGFloat(arc4random_uniform(80)) - 40, CGFloat(arc4random_uniform(80)) - 40)
        smoke.position = position
        enemy.addChild(smoke)
    }
    func enemyExpode(enemy: EnemyNode) {
        let explosion = SKEmitterNode(fileNamed: "AlienShipExplode")
        let position = convertPoint(enemy.position, toNode: self)
        explosion.position = position
        
        let actions = [
            SKAction.runBlock{enemy.removeAllActions()},
            SKAction.runBlock{self.addChild(explosion)},
            SKAction.waitForDuration(0.1),
            SKAction.runBlock{enemy.removeFromParent()}
        ]
        self.runAction(SKAction.sequence(actions))
    }
    
    //MARK: Update HUD
    func updateLives() {
        let lifeLabel = childNodeWithName("lifeLabel") as! SKLabelNode
        lifeLabel.text = "Lives: \(lives)"
    }
    func updatePoints() {
        let pointLabel = childNodeWithName("pointLabel") as! SKLabelNode
        pointLabel.text = "Points: \(points)"
    }
    func updateBullets() {
        let player = childNodeWithName(playerName) as! SKSpriteNode
        let bulletLabel = player.childNodeWithName("bulletLabel") as! SKLabelNode
        bulletLabel.text = "\(bulletCount)"
    }
}