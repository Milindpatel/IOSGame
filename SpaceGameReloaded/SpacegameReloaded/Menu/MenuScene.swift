import Foundation
import SpriteKit

class MenuScene: SKScene {
    private var starfield: SKEmitterNode!
    private var playerLabelNode: SKLabelNode!

    override func didMove(to view: SKView) {
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)

        starfield = childNode(withName: "starfield") as? SKEmitterNode
        starfield?.advanceSimulationTime(10)

        playerLabelNode = childNode(withName: "playerLabel") as? SKLabelNode
        updatePlayerLabel()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }

        switch nodes(at: location).first?.name {
        case "newGame":
            view?.presentScene(GameScene(size: size), transition: .flipHorizontal(withDuration: 0.5))
        case "playerButton":
            Settings.isPlayer2.toggle()
            updatePlayerLabel()
        default:
            break
        }
    }

    private func updatePlayerLabel() {
        playerLabelNode?.text = Settings.isPlayer2 ? "Player 2" : "Player 1"
    }
}


/// Small wrapper around UserDefaults for the game's saved settings.
enum Settings {
    private static let defaults = UserDefaults.standard

    /// Which player is playing (the menu toggles between Player 1 and Player 2).
    static var isPlayer2: Bool {
        get { defaults.bool(forKey: "Player2") }
        set { defaults.set(newValue, forKey: "Player2") }
    }

    /// Faster alien waves.
    static var isHard: Bool {
        defaults.bool(forKey: "hard")
    }

    /// Best score so far on this device.
    static var highScore: Int {
        get { defaults.integer(forKey: "highScore") }
        set { defaults.set(newValue, forKey: "highScore") }
    }
}
