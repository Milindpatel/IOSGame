# iOS Space Game (SpriteKit)

A small SpriteKit space shooter, built by following Brian Advent's [SpriteKit Space Game tutorial](https://youtu.be/cJy61bOqQpg).

- Tilt the phone to steer the shuttle (accelerometer), tap to fire torpedoes.
- Aliens fly across the screen; each one that gets past costs one of your three lives.
- Particle emitters for the star field and explosions, background music and sound effects.
- The menu switches between Player 1 and Player 2, and the game-over screen remembers your best score.

## Running

Open `SpaceGameReloaded/SpacegameReloaded.xcodeproj` in Xcode and run it on an iOS 15+ device or simulator. The project uses Swift 5. Tilt steering needs a real device; on the simulator you can still fire.

CI builds the app for the iOS Simulator on every push.
