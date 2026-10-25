import SpriteKit
import UIKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let view = view as? SKView, let scene = SKScene(fileNamed: "MenuScene") else { return }
        scene.scaleMode = .aspectFill
        view.presentScene(scene)
        view.ignoresSiblingOrder = true
        #if DEBUG
        view.showsFPS = true
        view.showsNodeCount = true
        #endif
    }

    override var shouldAutorotate: Bool {
        true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        UIDevice.current.userInterfaceIdiom == .phone ? .allButUpsideDown : .all
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}
