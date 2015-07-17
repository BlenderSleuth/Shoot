//
//  GameScene.swift
//  Shoot
//
//  Created by Ben Sutherland on 7/07/2015.
//  Copyright (c) 2015 BlenderSleuth Graphics. All rights reserved.
//

import SpriteKit
import CoreMotion

//Collision Categories
let bulletCategory: UInt32 = 0x1 << 0
let enemyCategory: UInt32 = 0x1 << 1
let shipCategory: UInt32 = 0x1 << 2
let boundaryCategory: UInt32 = 0x1 << 3

class Game: SKScene, SKPhysicsContactDelegate {
    
    let motionManager: CMMotionManager = CMMotionManager()
    
    var bulletCount = 100
    var enemyCount = 15
    var points = 0
    var lives = 10
    
    let enemySpeed: NSTimeInterval = 6 //seconds to get to bottom of screen
    let enemyFrequency: NSTimeInterval = 3 //seconds between enemies
    
    override func didMoveToView(view: SKView) {
        motionManager.startAccelerometerUpdates()
        self.physicsWorld.contactDelegate = self
        setupHUD()
        startWave()
        setupWorld()
        setupShip()
    }
    
    func setupBullet()  -> SKSpriteNode {
        let ship = self.childNodeWithName("ship") as! SKSpriteNode
        
        let bullet = SKSpriteNode(imageNamed: "bullet.png")
        bullet.size = CGSizeMake(ship.size.width / 4, ship.size.height / 4)
        bullet.name = "bullet"
        bullet.position = CGPointMake(ship.position.x, ship.position.y / 3 * 4)
        bullet.zPosition = 5
        
        //Physics Body
        bullet.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(bullet.size.width / 5, bullet.size.height))
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        //Collision Categories
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = enemyCategory
        bullet.physicsBody?.collisionBitMask = bulletCategory | enemyCategory
        return bullet
    }
    
    func setupHUD() {
        let bulletLabel = childNodeWithName("bulletLabel") as! SKLabelNode
        bulletLabel.text = "Bullets: \(bulletCount)"
        
        let pointLabel = childNodeWithName("pointLabel") as! SKLabelNode
        pointLabel.text = "Points: \(points)"
        
        let lifeLabel = childNodeWithName("lifeLabel") as! SKLabelNode
        lifeLabel.text = "Lives: \(lives)"
        
        let enemyLabel = childNodeWithName("enemyLabel") as! SKLabelNode
        enemyLabel.text = "Enemies to go: \(enemyCount)"
    }
    func setupWorld() {
        let point1 = CGPointMake(0, -CGRectGetWidth(self.frame) / 6)
        let point2 = CGPointMake(CGRectGetMaxX(self.frame), -CGRectGetWidth(self.frame) / 6)
        let point3 = CGPointMake(CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame))
        let point4 = CGPointMake(0, CGRectGetMaxY(self.frame))
        
        let physicsBody1 = SKPhysicsBody(edgeFromPoint: point1, toPoint: point2)
        let physicsBody2 = SKPhysicsBody(edgeFromPoint: point1, toPoint: point4)
        let physicsBody3 = SKPhysicsBody(edgeFromPoint: point2, toPoint: point3)
        
        let bodies = [physicsBody1, physicsBody2, physicsBody3]
        
        self.physicsBody = SKPhysicsBody(bodies: bodies)
        self.physicsBody?.dynamic = false
        self.physicsBody?.categoryBitMask = boundaryCategory
        self.physicsBody?.collisionBitMask = bulletCategory
        self.physicsBody?.contactTestBitMask = enemyCategory
        
        self.backgroundColor = UIColor.blackColor()
        
        let stars = SKEmitterNode(fileNamed: "Stars.sks")
        stars.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame))
        stars.advanceSimulationTime(10)
        self.addChild(stars)
    }
    
    func setupShip() {
        let ship = childNodeWithName("ship") as! SKSpriteNode
        ship.physicsBody = SKPhysicsBody(rectangleOfSize: ship.size)
        ship.physicsBody?.categoryBitMask = shipCategory
        ship.physicsBody?.contactTestBitMask = enemyCategory
        ship.physicsBody?.collisionBitMask = boundaryCategory
        ship.physicsBody?.mass = 0.01
    }
    
    func gameOver() {
        println("Game Over")
        
        let scene = GameOver(fileNamed: "GameOver")
        scene.points = self.points
        self.view?.presentScene(scene)
    }
    func startWave() {
        let range: UInt32 = 50
        var random: CGFloat = 0
        var randomSize = CGSizeMake(random, random)
        
        let action = [
            SKAction.runBlock{
                self.setupEnemy()
            },
            SKAction.waitForDuration(enemyFrequency)
        ]
        let release = SKAction.sequence(action)
        
        self.runAction(SKAction.repeatAction(release, count: enemyCount), completion: {
            let array = [SKAction.waitForDuration(self.enemySpeed - 2), SKAction.runBlock({self.gameOver()})]
            self.runAction(SKAction.sequence(array))
        })
    }
    func setupEnemy(){
        let size = CGSizeMake(CGRectGetWidth(self.frame) / 6, CGRectGetWidth(self.frame) / 6)
        
        let enemyPositionX = CGFloat(arc4random_uniform(UInt32(CGRectGetWidth(self.frame) - 200)) + 100)
        let enemyPosition = CGPointMake(enemyPositionX, CGRectGetHeight(self.frame) + size.height / 2)
        
        let enemy = EnemyNode(size: size, position: enemyPosition)
        self.addChild(enemy)
        
        let actionArray = [SKAction.moveToY(-enemy.size.height, duration: enemySpeed), SKAction.runBlock({enemy.removeFromParent()})]
        let sequence = SKAction.sequence(actionArray)
        
        enemy.runAction(sequence)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let bullet = setupBullet()
        addChild(bullet)
        bullet.physicsBody?.applyImpulse(CGVectorMake(0, 15))
    }
    override func update(currentTime: NSTimeInterval) {
        processUserMotionForUpdate(currentTime)
    }
    
    func processUserMotionForUpdate(currentTime: CFTimeInterval) {
        let ship = childNodeWithName("ship") as! SKSpriteNode
        
        if let data = motionManager.accelerometerData {

            if fabs(data.acceleration.y) > 0.15 {
                ship.physicsBody?.applyForce(CGVectorMake(30 * CGFloat(data.acceleration.y), 0))
            } else {
                ship.physicsBody?.velocity = CGVectorMake(ship.physicsBody!.velocity.dx / 2, ship.physicsBody!.velocity.dy)
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch collision {
        case enemyCategory | bulletCategory:
                var enemy = contact.bodyA.node as? EnemyNode
                var bullet = contact.bodyB.node as! SKSpriteNode
                
                if contact.bodyB.categoryBitMask == enemyCategory {
                    enemy = contact.bodyB.node as? EnemyNode
                    bullet = contact.bodyA.node as! SKSpriteNode
                }

                let point = enemy!.convertPoint(contact.contactPoint, fromNode: self)
                
                let fire = SKEmitterNode(fileNamed: "AlienFireDamage.sks")
                fire.position = point
                enemy!.addChild(fire)
                switch enemy!.health {
                case 4:
                    enemy!.texture = SKTexture(imageNamed: "cracked1")
                    --enemy!.health
                case 3:
                    enemy!.texture = SKTexture(imageNamed: "cracked2")
                    --enemy!.health
                case 2:
                    enemy!.texture = SKTexture(imageNamed: "cracked3")
                    --enemy!.health
                case 1:
                    enemy!.texture = SKTexture(imageNamed: "cracked4")
                    let smoke = SKEmitterNode(fileNamed: "AlienDamageSmoke.sks")
                    let position = CGPointMake(CGFloat(arc4random_uniform(80)) - 40, CGFloat(arc4random_uniform(80)) - 40)
                    smoke.position = position
                    enemy!.addChild(smoke)
                    --enemy!.health
                case 0:
                    let explosion = SKEmitterNode(fileNamed: "AlienShipExplode")
                    
                    let actions = [
                        SKAction.runBlock{enemy?.removeAllActions()},
                        SKAction.runBlock{enemy?.addChild(explosion)},
                        SKAction.waitForDuration(0.3),
                        SKAction.runBlock{enemy?.removeFromParent()}
                    ]
                    self.runAction(SKAction.sequence(actions))
                default:
                    break
                }
            bullet.removeFromParent()
            points++
            updateLabels()
            
        case enemyCategory | boundaryCategory:
            --lives
            if lives == 0 {
                gameOver()
            }

        default:
            break
        }
    }
    
    func updateLabels() {
        let bulletLabel = childNodeWithName("bulletLabel") as! SKLabelNode
        bulletLabel.text = "Bullets: \(bulletCount)"
        
        let pointLabel = childNodeWithName("pointLabel") as! SKLabelNode
        pointLabel.text = "Points: \(points)"
        
        let lifeLabel = childNodeWithName("lifeLabel") as! SKLabelNode
        lifeLabel.text = "Lives: \(lives)"
        
        let enemyLabel = childNodeWithName("enemyLabel") as! SKLabelNode
        enemyLabel.text = "Enemies to go: \(enemyCount)"
    }
}