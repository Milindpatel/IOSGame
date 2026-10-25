import SpriteKit

class GameOverScene: SKScene {
    var score = 0

    private var scoreLabel: SKLabelNode!
    private var playerScore: SKLabelNode!

    override func didMove(to view: SKView) {
        playerScore = childNode(withName: "playerScore") as? SKLabelNode
        playerScore.text = Settings.isPlayer2 ? "Player 2 Score" : "Player 1 Score"

        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        scoreLabel.text = "\(score)"

        if score > Settings.highScore {
            Settings.highScore = score
            playerScore.text = (playerScore.text ?? "") + " (new best!)"
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        if nodes(at: location).contains(where: { $0.name == "newGame" }) {
            view?.presentScene(GameScene(size: size), transition: .flipHorizontal(withDuration: 0.5))
        }
    }
}
