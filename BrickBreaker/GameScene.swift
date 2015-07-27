//
//  GameScene.swift
//  BrickBreaker
//
//  Created by Atikur Rahman on 7/14/15.
//  Copyright (c) 2015 Atikur Rahman. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    struct PhysicsCategory {
        static let Ball: UInt32     = 0
        static let Paddle: UInt32   = 0b1
        static let Brick: UInt32    = 0b10
        static let Edge: UInt32     = 0b100
    }
    
    let ballSpeed: CGFloat = 200
    
    var paddle: SKSpriteNode!
    var touchLocation: CGPoint!
    
    var brickLayer: SKNode!
    var ballReleased: Bool!
    var positionBall: Bool!
    
    var currentLevel: Int! {
        didSet {
            levelDisplay.text = "LEVEL \(currentLevel + 1)"
            menu.panelText.text = "LEVEL \(currentLevel + 1)"
        }
    }
    
    var hearts: [SKSpriteNode]!
    var levelDisplay: SKLabelNode!
    
    var menu: Menu!
    
    var ballBounceSound: SKAction!
    var levelUpSound: SKAction!
    var loseLifeSound: SKAction!
    var paddleBounceSound: SKAction!
    
    var lives: Int! {
        didSet {
            for (index, heart) in enumerate(hearts) {
                if index < lives {
                    heart.texture = SKTexture(imageNamed: "HeartFull")
                } else {
                    heart.texture = SKTexture(imageNamed: "HeartEmpty")
                }
            }
        }
    }
    
    // MARK: -
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch in (touches as! Set<UITouch>) {
            if menu.hidden {
                if !ballReleased {
                    positionBall = true
                }
            }
            touchLocation = touch.locationInNode(self)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if menu.hidden {
            if positionBall == true {
                paddle.removeAllChildren()
                
                createBallWithLocation(CGPointMake(paddle.position.x, paddle.position.y + paddle.size.height * 0.5), velocity: CGVectorMake(0, ballSpeed))
                ballReleased = true
                positionBall = false
            }
        } else {
            for touch in (touches as! Set<UITouch>) {
                if menu.nodeAtPoint(touch.locationInNode(menu)).name == "Play Button" {
                    menu.hide()
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if menu.hidden {
            for touch in (touches as! Set<UITouch>) {
                let xMovement = touch.locationInNode(self).x - touchLocation.x
                
                paddle.position = CGPointMake(paddle.position.x + xMovement, paddle.position.y)
                
                var paddleMinX = -paddle.size.width * 0.25
                var paddleMaxX = self.size.width + paddle.size.width * 0.25
                
                if positionBall == true {
                    paddleMinX = paddle.size.width * 0.5
                    paddleMaxX = self.size.width - paddle.size.width * 0.5
                }
                
                if paddle.position.x < paddleMinX {
                    paddle.position = CGPointMake(paddleMinX, paddle.position.y)
                }
                
                if paddle.position.x > paddleMaxX {
                    paddle.position = CGPointMake(paddleMaxX, paddle.position.y)
                }
                
                touchLocation = touch.locationInNode(self)
            }
        }
    }
    
    override func didSimulatePhysics() {
        self.enumerateChildNodesWithName("ball") {
            node, _ in
            if node.frame.origin.y + node.frame.size.height < 0 {
                node.removeFromParent()
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        if isLevelComplete() {
            currentLevel = currentLevel + 1
            
            if currentLevel > 2 {
                currentLevel = 0
                lives = 2
            }
            
            loadLevel(currentLevel)
            newBall()
            menu.show()
            self.runAction(levelUpSound)
        } else if ballReleased == true && positionBall == false && self.childNodeWithName("ball") == nil {
            lives = lives - 1
            self.runAction(loseLifeSound)
            
            if lives < 0 {
                // Game over
                currentLevel = 0
                lives = 2
                loadLevel(currentLevel)
                menu.show()
            }
            
            newBall()
        }
    }
    
    // MARK: - SKPhysicsContactDelegate Methods
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        } else {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        
        // contact between ball and paddle
        if firstBody.categoryBitMask == PhysicsCategory.Ball && secondBody.categoryBitMask == PhysicsCategory.Paddle {
            if firstBody.node?.position.y > secondBody.node?.position.y {
                // get contact point in paddle coordinates
                let pointInPaddle = secondBody.node?.convertPoint(contact.contactPoint, fromNode: self)
                // get contact position as percentage of paddle's width
                let contactPosition = (secondBody.node!.frame.size.width * 0.5 + pointInPaddle!.x) / secondBody.node!.frame.size.width
                // cap percentage between 0 to 1 and flip it
                let multiplier = 1.0 - fmax(fmin(contactPosition, 1.0), 0.0)
                // calculate angle based on ball position in paddle
                let angle = (CGFloat(M_PI_2) * multiplier) + CGFloat(M_PI_4)
                // convert angle to vector
                let direction = CGVectorMake(cos(angle), sin(angle))
                
                firstBody.velocity = CGVectorMake(direction.dx * ballSpeed, direction.dy * ballSpeed)
                
                self.runAction(paddleBounceSound)
            }
        }
        
        // contact between ball and brick
        if firstBody.categoryBitMask == PhysicsCategory.Ball && secondBody.categoryBitMask == PhysicsCategory.Brick {
            if let brick = (secondBody.node as? Brick) {
                brick.hit()
            }
            self.runAction(ballBounceSound)
        }
        
        // contact between ball and edge
        if firstBody.categoryBitMask == PhysicsCategory.Ball && secondBody.categoryBitMask == PhysicsCategory.Edge {
            self.runAction(ballBounceSound)
        }
    }
    
    // MARK: -
    
    func createBallWithLocation(position: CGPoint, velocity: CGVector) -> SKSpriteNode {
        let ball = SKSpriteNode(imageNamed: "BallBlue")
        ball.name = "ball"
        ball.position = position
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width * 0.5)
        ball.physicsBody?.friction = 0.0
        ball.physicsBody?.linearDamping = 0.0
        ball.physicsBody?.angularDamping = 0.0
        ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.velocity = velocity
        ball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.Paddle | PhysicsCategory.Brick | PhysicsCategory.Edge
        
        addChild(ball)
        return ball
    }
    
    func loadLevel(level: Int) {
        brickLayer.removeAllChildren()
        
        var collection: [[Brick.BrickType!]] = []
        
        switch level {
        case 0:
            collection = [
                [.Green, .Green, .Green, .Green, .Green, .Green],
                [nil, .Green, .Green, .Green, .Green, nil],
                [nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil],
                [nil, .Blue, .Blue, .Blue, .Blue, nil]
            ]
        case 1:
            collection = [
                [.Green, .Green, .Blue, .Blue, .Green, .Green],
                [.Blue, .Blue, nil, nil, .Blue, .Blue],
                [.Blue, nil, nil, nil, nil, .Blue],
                [nil, nil, .Green, .Green, nil, nil],
                [.Green, nil, .Green, .Green, nil, .Green],
                [.Green, .Green, .Grey, .Grey, .Green, .Green]
            ]
        case 2:
            collection = [
                [.Green, nil, .Green, .Green, nil, .Green],
                [.Green, nil, .Green, .Green, nil, .Green],
                [nil, nil, .Grey, .Grey, nil, nil],
                [.Blue, nil, nil, nil, nil, .Blue],
                [nil, nil, .Green, .Green, nil, nil],
                [.Grey, .Blue, .Green, .Green, .Blue, .Grey]
            ]
        default:
            break
        }
        
        for (rowIndex, row) in enumerate(collection) {
            for (colIndex, brickType) in enumerate(row) {
                if brickType != nil {
                    let brick = Brick(type: brickType)
                    brick.position = CGPointMake(
                        2 + brick.size.width * 0.5 + (brick.size.width + 3) * CGFloat(colIndex),
                        -(2 + brick.size.height * 0.5 + (brick.size.height + 3) * CGFloat(rowIndex)))
                    brickLayer.addChild(brick)
                }
            }
        }
    }
    
    func isLevelComplete() -> Bool {
        for node in brickLayer.children {
            if let brick = node as? Brick {
                if !brick.indestructible {
                    return false
                }
            }
        }
        
        return true
    }
    
    func newBall() {
        self.enumerateChildNodesWithName("ball") {
            node, _ in
            node.removeFromParent()
        }
        
        let ball = SKSpriteNode(imageNamed: "BallBlue")
        ball.position = CGPointMake(0, paddle.size.height)
        paddle.addChild(ball)
        
        paddle.position = CGPointMake(self.size.width/2, paddle.position.y)
        
        ballReleased = false
    }
    
    // MARK: - Initializers
    
    override init(size: CGSize) {
        super.init(size: size)
        
        backgroundColor = SKColor.whiteColor()
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRectMake(0, -128, self.size.width, self.size.height + 100))
        self.physicsBody?.categoryBitMask = PhysicsCategory.Edge
        
        // setup brick layer
        brickLayer = SKNode()
        brickLayer.position = CGPointMake(0, self.size.height - 28)
        addChild(brickLayer)
        
        // add hud bar
        let bar = SKSpriteNode(color: SKColor(red: 0.831, green: 0.831, blue: 0.831, alpha: 1), size: CGSizeMake(self.size.width, 28))
        bar.position = CGPointMake(0, self.size.height)
        bar.anchorPoint = CGPointMake(0, 1)
        addChild(bar)
        
        // add sounds
        ballBounceSound = SKAction.playSoundFileNamed("BallBounce.caf", waitForCompletion: false)
        levelUpSound = SKAction.playSoundFileNamed("LevelUp.caf", waitForCompletion: false)
        loseLifeSound = SKAction.playSoundFileNamed("LoseLife.caf", waitForCompletion: false)
        paddleBounceSound = SKAction.playSoundFileNamed("PaddleBounce.caf", waitForCompletion: false)
        
        // level display
        levelDisplay = SKLabelNode(fontNamed: "Futura")
        levelDisplay.text = "LEVEL 1"
        levelDisplay.fontSize = 15
        levelDisplay.fontColor = SKColor.grayColor()
        levelDisplay.horizontalAlignmentMode = .Left
        levelDisplay.verticalAlignmentMode = .Top
        levelDisplay.position = CGPointMake(10, -10)
        bar.addChild(levelDisplay)
        
        hearts = [
            SKSpriteNode(imageNamed: "HeartFull"),
            SKSpriteNode(imageNamed: "HeartFull")
        ]
        
        for (index, heart) in enumerate(hearts) {
            heart.position = CGPointMake(self.size.width - (16 + 29 * CGFloat(index)), self.size.height - 14)
            addChild(heart)
        }
        
        paddle = SKSpriteNode(imageNamed: "Paddle")
        paddle.position = CGPointMake(self.size.width/2, 90)
        paddle.physicsBody = SKPhysicsBody(rectangleOfSize: paddle.size)
        paddle.physicsBody?.dynamic = false
        paddle.physicsBody?.categoryBitMask = PhysicsCategory.Paddle
        addChild(paddle)
        
        // menu
        menu = Menu()
        menu.position = CGPointMake(self.size.width/2, self.size.height/2)
        addChild(menu)
        
        currentLevel = 0
        lives = 2
        positionBall = false
        
        loadLevel(currentLevel)
        newBall()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}