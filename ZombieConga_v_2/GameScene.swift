//
//  GameScene.swift
//  ZombieConga_v_2
//
//  Created by Austin Nash on 10/8/14.
//  Copyright (c) 2014 Austin Nash. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    let zombie = SKSpriteNode(imageNamed: "zombie1");
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPointZero
    let playableRect: CGRect
    let zombieRotateRadiansPerSec:CGFloat = 4.0 * π
    let zombieAnimation: SKAction
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed(
        "hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed(
        "hitCatLady.wav", waitForCompletion: false)
    var isInvincible = false;
    
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
//        background.zRotation = CGFloat(M_PI) / 8
        background.zPosition = -1
        addChild(background)
        let mySize = background.size
        print("Size: \(mySize)")
        zombie.position = CGPointMake(400, 400);
//        zombie.setScale(2.0);
        addChild(zombie);
//        zombie.runAction(SKAction.repeatActionForever(zombieAnimation))
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnEnemy),
            SKAction.waitForDuration(2.0)])))
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnCat),
            SKAction.waitForDuration(1.0)])))
        debugDrawPlayableArea();
    }
    
    override func update(currentTime: NSTimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        print("\(dt*1000) milliseconds since last update")
        
        moveSprite(zombie, velocity: velocity)
        boundsCheckZombie()
        rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec);
//        checkCollisions()
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        print("Amount to move: \(amountToMove)")
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint) {
        startZombieAnimation()
        let offset = location - zombie.position;
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        let direction = offset / CGFloat(length);
        velocity = direction * zombieMovePointsPerSec
    }
    
    func sceneTouched(touchLocation:CGPoint) {
            moveZombieToward(touchLocation)
    }
    
//    override func touchesBegan(touches: NSSet,
//            withEvent event: UIEvent) {
//            let touch = touches.anyObject() as! UITouch
//            let touchLocation = touch.locationInNode(self)
//            sceneTouched(touchLocation)
//    }
//    
//    override func touchesMoved(touches: NSSet,
//            withEvent event: UIEvent) {
//            let touch = touches.anyObject() as! UITouch
//            let touchLocation = touch.locationInNode(self)
//            sceneTouched(touchLocation)
//    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0,
                                 y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width,
                               y: CGRectGetMaxY(playableRect))
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3
        playableRect = CGRect(x: 0, y: playableMargin,
        width: size.width,
        height: playableHeight) // 4
        // 1
        var textures:[SKTexture] = []
        // 2
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        // 3
        textures.append(textures[2])
        textures.append(textures[1])
        // 4
        zombieAnimation = SKAction.repeatActionForever(
            SKAction.animateWithTextures(textures, timePerFrame: 0.1))
        super.init(size: size) // 5
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
    }
    
    func debugDrawPlayableArea() {
            let shape = SKShapeNode()
            let path = CGPathCreateMutable()
            CGPathAddRect(path, nil, playableRect)
            shape.path = path
            shape.strokeColor = SKColor.redColor()
            shape.lineWidth = 4.0
            addChild(shape)
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let shortest = shortestAngleBetween(zombie.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(
        x: size.width + enemy.size.width/2,
        y: CGFloat.random(
            CGRectGetMinY(playableRect) + enemy.size.height/2,
            max: CGRectGetMaxY(playableRect) - enemy.size.height/2))
        addChild(enemy)
        let actionMove =
        SKAction.moveToX(-enemy.size.width/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func startZombieAnimation() {
        if zombie.actionForKey("animation") == nil {
        zombie.runAction(
        SKAction.repeatActionForever(zombieAnimation),
        withKey: "animation")
        }
    }
    func stopZombieAnimation() {
        zombie.removeActionForKey("animation")
    }
    
    func spawnCat() {
        // 1
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(
        x: CGFloat.random(CGRectGetMinX(playableRect),
        max: CGRectGetMaxX(playableRect)),
        y: CGFloat.random(CGRectGetMinY(playableRect),
        max: CGRectGetMaxY(playableRect)))
        cat.setScale(0)
        addChild(cat)
        // 2
        let appear = SKAction.scaleTo(1.0, duration: 0.5)
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotateByAngle(π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversedAction()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence(
            [scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeatAction(group, count: 10)
        let disappear = SKAction.scaleTo(0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.runAction(SKAction.sequence(actions))
    }
    
    func zombieHitCat(cat: SKSpriteNode) {
        cat.removeFromParent()
        runAction(catCollisionSound)
    }
    
    func zombieHitEnemy(enemy: SKSpriteNode) {
        isInvincible = true;
//        zombie.runAction(SKAction.sequence([blinkAction, SKAction.runBlock(setHiddenTrue())]));
        runAction(enemyCollisionSound)
    }
    
    func setHiddenTrue() {
        zombie.hidden = true;
    }
    
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodesWithName("cat") { node, _ in
            let cat = node as! SKSpriteNode
            if CGRectIntersectsRect(cat.frame, self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHitCat(cat)
        }
        if isInvincible == false {
            var hitEnemies: [SKSpriteNode] = []
            enumerateChildNodesWithName("enemy") { node, _ in
                let enemy = node as! SKSpriteNode
                if CGRectIntersectsRect(
                CGRectInset(node.frame, 20, 20), self.zombie.frame) {
                    hitEnemies.append(enemy)
            }
            }
            for enemy in hitEnemies {
                zombieHitEnemy(enemy)
            }
        }
    }
    
    let blinkTimes = 10.0
    let duration = 3.0
//    let blinkAction = SKAction.customActionWithDuration(duration) {
//        node, elapsedTime in
//        let slice = duration / blinkTimes
//        let remainder = Double(elapsedTime) % slice
//        node.hidden = remainder > slice / 2
//    }
    
    
}

