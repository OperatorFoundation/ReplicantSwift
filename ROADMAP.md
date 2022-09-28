# Replicant Roadmap

## Language Support
- Swift and Go are fully supported and have feature parity, so Kotlin is the next language to support.

## Configuration
- Improvement of configuration files
 - Cleaner JSON
 - Remove redundant fields
 - Identical files for different implementations (Swift and Go have different files)
- Further development of the concept of Replicant “modes”
 - High-level mode config files can be short and easy
 - Low-level Replicant configuration, such as defining a new mode, should also be possible directly in the config files
- Replace JSON with a better configuration file syntax
- Create a suite of different configurations for mimicking popular Internet protocols
- Easier Starbridge config generation
 - Add config pair generation API to the ReplicantSwift code base that saves a new JSON config pair to a user provided directory
 - Config handling specification added to PT spec
 - Have ShapeshifterDispatcherSwift Config program utilize this API so that users can create a new config pair as needed using CLI
 - Create a new GUI macOS app that utilizes this API
 - Create an iOS/iPadOS app that utilizes this API

## Troubleshooting
- Easier live debugging of Starburst configurations
- Easier unit testing of Starburst configurations

## Toneburst
- Bring back binary protocols
 - But which binary protocols should we mimic?

### Starburst
- Replace regex in Starburst with something simpler and easier to debug
 - Perhaps finite automata
 - This needs a regex-like microformat to keep it succint
- Add conditionals
- Add map
- Add reduce
- Add flatmap
- Environmental inputs
 - Time of day
 - Destination address

## Polish
### DarkStar
- optional client authentication
- optional new user registration
- optional entropy reduction setting for polish-only transports
