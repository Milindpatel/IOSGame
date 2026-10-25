import CoreMotion
import GameplayKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    private enum Category {
        static let torpedo: UInt32 = 0x1 << 0
        static let alien: UInt32 = 0x1 << 1
    }

    private let alienImages = ["alien", "alien2", "alien3"]
    private let motionManager = CMMotionManager()

    private var starfield: SKEmitterNode!
    private var player: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    private var gameTimer: Timer?
    private var xAcceleration: CGFloat = 0
    private var lives = [SKSpriteNode]()
    private var isGameOver = false

    private var score = 0 {
        didSet { scoreLabel.text = "Score: \(score)" }
    }

    override func didMove(to view: SKView) {
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)

        addLives()

        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x: 0, y: 1472)
        starfield.advanceSimulationTime(10)
        starfield.zPosition = -1
        addChild(starfield)

        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPoint(x: frame.size.width / 2, y: player.size.height / 2 + 20)
        addChild(player)

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 80, y: frame.size.height - 70)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = .white
        addChild(scoreLabel)
        score = 0

        let interval = Settings.isHard ? 0.3 : 0.75
        gameTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.addAlien()
        }

        // Tilt the phone to steer.
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.2
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
                guard let self, let acceleration = data?.acceleration else { return }
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
        }
    }

    // Stop the timer and sensors when the scene goes away. Before, the timer kept
    // the old scene alive and spawning aliens after the game was over.
    override func willMove(from view: SKView) {
        gameTimer?.invalidate()
        gameTimer = nil
        motionManager.stopAccelerometerUpdates()
    }

    private func addLives() {
        for life in 1...3 {
            let lifeNode = SKSpriteNode(imageNamed: "shuttle")
            lifeNode.position = CGPoint(x: frame.size.width - CGFloat(4 - life) * lifeNode.size.width, y: frame.size.height - 60)
            addChild(lifeNode)
            lives.append(lifeNode)
        }
    }

    private func addAlien() {
        guard !isGameOver, let image = alienImages.randomElement() else { return }
        let alien = SKSpriteNode(imageNamed: image)

        let top = max(Int(frame.size.height) - 150, 101)
        let y = CGFloat(GKRandomDistribution(lowestValue: 100, highestValue: top).nextInt())
        alien.position = CGPoint(x: frame.size.width + alien.size.height, y: y)

        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        alien.physicsBody?.categoryBitMask = Category.alien
        alien.physicsBody?.contactTestBitMask = Category.torpedo
        alien.physicsBody?.collisionBitMask = 0
        addChild(alien)

        // An alien that crosses the screen costs a life.
        alien.run(.sequence([
            .move(to: CGPoint(x: -alien.size.height, y: y), duration: 6),
            .run { [weak self] in self?.loseLife() },
            .removeFromParent(),
        ]))
    }

    private func loseLife() {
        guard !isGameOver, !lives.isEmpty else { return }
        lives.removeFirst().removeFromParent()
        if lives.isEmpty {
            isGameOver = true
            guard let gameOver = SKScene(fileNamed: "GameOverScreen") as? GameOverScene else { return }
            gameOver.score = score
            gameOver.scaleMode = scaleMode
            view?.presentScene(gameOver, transition: .flipHorizontal(withDuration: 0.5))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireTorpedo()
    }

    private func fireTorpedo() {
        guard !isGameOver else { return }
        run(.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))

        let torpedo = SKSpriteNode(imageNamed: "torpedo")
        torpedo.position = CGPoint(x: player.position.x, y: player.position.y + 5)
        torpedo.physicsBody = SKPhysicsBody(circleOfRadius: torpedo.size.width / 2)
        torpedo.physicsBody?.isDynamic = true
        torpedo.physicsBody?.categoryBitMask = Category.torpedo
        torpedo.physicsBody?.contactTestBitMask = Category.alien
        torpedo.physicsBody?.collisionBitMask = 0
        torpedo.physicsBody?.usesPreciseCollisionDetection = true
        addChild(torpedo)

        torpedo.run(.sequence([
            .move(to: CGPoint(x: player.position.x, y: frame.size.height + 10), duration: 0.3),
            .removeFromParent(),
        ]))
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let (first, second) = contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
            ? (contact.bodyA, contact.bodyB)
            : (contact.bodyB, contact.bodyA)

        // Both nodes can already be gone if two torpedoes hit the same alien.
        guard first.categoryBitMask & Category.torpedo != 0,
              second.categoryBitMask & Category.alien != 0,
              let torpedo = first.node as? SKSpriteNode,
              let alien = second.node as? SKSpriteNode
        else { return }

        torpedoDidCollide(torpedo: torpedo, alien: alien)
    }

    private func torpedoDidCollide(torpedo: SKSpriteNode, alien: SKSpriteNode) {
        if let explosion = SKEmitterNode(fileNamed: "Explosion") {
            explosion.position = alien.position
            addChild(explosion)
            explosion.run(.sequence([.wait(forDuration: 2), .removeFromParent()]))
        }
        run(.playSoundFileNamed("explosion.mp3", waitForCompletion: false))

        torpedo.removeFromParent()
        alien.removeFromParent()
        score += 5
    }

    override func didSimulatePhysics() {
        player.position.x += xAcceleration * 50

        // Wrap around the screen edges.
        if player.position.x < -20 {
            player.position.x = size.width + 20
        } else if player.position.x > size.width + 20 {
            player.position.x = -20
        }
    }
}
