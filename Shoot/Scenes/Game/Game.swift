//
//  GameScene.swift
//  Shoot
//
//  Created by Ben Sutherland on 7/07/2015.
//  Copyright (c) 2015 BlenderSleuth Graphics. All rights reserved.
//

import SpriteKit

//Collision Categories
let bulletCategory: UInt32 = 0x1 << 0
let wallCategory: UInt32 = 0x1 << 1
let enemyCategory: UInt32 = 0x1 << 2
let boundaryCategory: UInt32 = 0x1 << 3

class Game: SKScene, SKPhysicsContactDelegate {
    
    var bulletCount = 100
    var enemyCount = 15
    var points = 0
    var lives = 10
    
    let enemySpeed: NSTimeInterval = 6 //seconds to get to bottom of screen
    let enemyFrequency: NSTimeInterval = 3 //seconds between enemies
    
    override func didMoveToView(view: SKView) {
        initHUD()
        initWave()
        initWorld()
        self.physicsWorld.contactDelegate = self
    }

    func initGun() {
        let gun = self.childNodeWithName("gun") as! SKSpriteNode
        
        //gun.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame) + self.frame.size.height / 4)
        //gun.size = CGSizeMake(CGRectGetWidth(self.frame) / 5, CGRectGetWidth(self.frame) / 5)
    }
    func initWall() {
        let wall = childNodeWithName("wall") as! SKSpriteNode
        //wall.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) / 5 * 4)
        //wall.size = CGSizeMake(self.frame.width / 4, self.frame.width / 16)
        
        wall.physicsBody?.categoryBitMask = wallCategory
        wall.physicsBody?.contactTestBitMask = bulletCategory
        wall.physicsBody?.collisionBitMask = bulletCategory
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
    
    func initHUD() {
        let bulletLabel = childNodeWithName("bulletLabel") as! SKLabelNode
        bulletLabel.text = "Bullets: \(bulletCount)"
        
        let pointLabel = childNodeWithName("pointLabel") as! SKLabelNode
        pointLabel.text = "Points: \(points)"
        
        let lifeLabel = childNodeWithName("lifeLabel") as! SKLabelNode
        lifeLabel.text = "Lives: \(lives)"
        
        let enemyLabel = childNodeWithName("enemyLabel") as! SKLabelNode
        enemyLabel.text = "Enemies to go: \(enemyCount)"
    }
    func initWorld() {
        let point1 = CGPointMake(0, -CGRectGetWidth(self.frame) / 6)
        let point2 = CGPointMake(CGRectGetMaxX(self.frame), -CGRectGetWidth(self.frame) / 6)
        
        self.physicsBody = SKPhysicsBody(edgeFromPoint: point1, toPoint: point2)
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
    
    func gameOver() {
        println("Game Over")
        
        let scene = GameOver(fileNamed: "GameOver")
        scene.points = self.points
        self.view?.presentScene(scene)
    }
    func initWave() {
        let range: UInt32 = 50
        var random: CGFloat = 0
        var randomSize = CGSizeMake(random, random)
        
        let action = [
            SKAction.runBlock{
                self.initEnemy()
            },
            SKAction.runBlock{
                --self.enemyCount
            },
            SKAction.waitForDuration(enemyFrequency)
        ]
        let release = SKAction.sequence(action)
        
        self.runAction(SKAction.repeatAction(release, count: enemyCount), completion: {
            let array = [SKAction.waitForDuration(self.enemySpeed - 2), SKAction.runBlock({self.gameOver()})]
            self.runAction(SKAction.sequence(array))
        })
    }
    func initEnemy(){
        let size = CGSizeMake(CGRectGetWidth(self.frame) / 6, CGRectGetWidth(self.frame) / 6)
        
        let enemyPositionX = CGFloat(arc4random_uniform(UInt32(CGRectGetWidth(self.frame) - 200)) + 100)
        let enemyPosition = CGPointMake(enemyPositionX, CGRectGetHeight(self.frame) + size.height / 2)
        
        let enemy = EnemyNode(size: size, position: enemyPosition)
        self.addChild(enemy)
        
        let actionArray = [SKAction.moveToY(-enemy.size.height, duration: enemySpeed), SKAction.runBlock({enemy.removeFromParent()})]
        let sequence = SKAction.sequence(actionArray)
        
        enemy.runAction(sequence)
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
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if bulletCount != 0 {
            let bullet = initBullet()
            self.addChild(bullet)
            --bulletCount
            bullet.physicsBody?.applyImpulse(CGVectorMake(0, 15))
        }
    }
    override func update(currentTime: NSTimeInterval) {
        let bulletLabel = childNodeWithName("bulletLabel") as! SKLabelNode
        bulletLabel.text = "Bullets: \(bulletCount)"
        
        let pointLabel = childNodeWithName("pointLabel") as! SKLabelNode
        pointLabel.text = "Points: \(points)"
        
        let lifeLabel = childNodeWithName("lifeLabel") as! SKLabelNode
        lifeLabel.text = "Lives: \(lives)"
        
        let enemyLabel = childNodeWithName("enemyLabel") as! SKLabelNode
        enemyLabel.text = "Enemies to go: \(enemyCount)"
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch collision {
        case wallCategory | bulletCategory:
            println("Hit Wall")
            
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
                    let explosion = SKEmitterNode(fileNamed: "AlienShipPieces.sks")
                    
                    let actions = [
                        SKAction.runBlock{enemy!.removeAllActions()},
                        SKAction.runBlock{enemy!.addChild(explosion)},
                        SKAction.runBlock{explosion.advanceSimulationTime(0.5)},
                        SKAction.waitForDuration(0.01),
                        SKAction.runBlock{explosion.particleTexture = SKTexture(imageNamed: "Piece2")},
                        SKAction.waitForDuration(0.01),
                        SKAction.runBlock{explosion.particleTexture = SKTexture(imageNamed: "Piece3")},
                        SKAction.waitForDuration(0.01),
                        SKAction.runBlock{explosion.particleTexture = SKTexture(imageNamed: "Piece4")},
                        SKAction.waitForDuration(0.01),
                        SKAction.runBlock{explosion.particleTexture = SKTexture(imageNamed: "Piece5")},
                        SKAction.waitForDuration(0.01),
                        SKAction.runBlock{explosion.particleTexture = SKTexture(imageNamed: "Piece6")},
                        SKAction.runBlock{enemy!.removeFromParent()}
                    ]
                    
                    self.runAction(SKAction.sequence(actions))
                default:
                    break
                }
            bullet.removeFromParent()
            points++
            
        case enemyCategory | boundaryCategory:
            --lives
            if lives == 0 {
                gameOver()
            }

        default:
            break
        }
    }
}