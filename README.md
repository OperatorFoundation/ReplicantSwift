# Operator Foundation

[Operator](https://operatorfoundation.org) makes usable tools to help people around the world with censorship, security, and privacy.

## Shapeshifter

The Shapeshifter project provides network protocol shapeshifting technology
(also sometimes referred to as obfuscation). The purpose of this technology is
to change the characteristics of network traffic so that it is not identified
and subsequently blocked by network filtering devices.

There are two components to Shapeshifter: transports and the dispatcher. Each
transport provide different approach to shapeshifting. ReplicantSwift is provided as a 
Swift library which can be integrated directly into applications.

If you are a tool developer working in the Swift programming language, then you
are in the right place. If you are a tool developer working in other languages we have 
several other tools available to you:

- A Go transports library that can be used directly in your application:
[shapeshifter-transports](https://github.com/OperatorFoundation/shapeshifter-transports)

- A Kotlin transports library that can be used directly in your Android application (currently supports Shadow):
[ShapeshifterAndroidKotlin](https://github.com/OperatorFoundation/ShapeshifterAndroidKotlin)

- A Java transports library that can be used directly in your Android application (currently supports Shadow):
[ShapeshifterAndroidJava](https://github.com/OperatorFoundation/ShapeshifterAndroidJava)

If you want a end user that is trying to circumvent filtering on your network or
you are a developer that wants to add pluggable transports to an existing tool
that is not written in the Swift programming language, then you probably want the
dispatcher. Please note that familiarity with executing programs on the command
line is necessary to use this tool.
<https://github.com/OperatorFoundation/shapeshifter-dispatcher>

If you are looking for a complete, easy-to-use VPN that incorporates
shapeshifting technology and has a graphical user interface, consider
[Moonbounce](https://github.com/OperatorFoundation/Moonbounce), an application for macOS which incorporates shapeshifting without
the need to write code or use the command line.

### Shapeshifter Transports

Shapeshifter Transports is a suite of pluggable transports implemented in a variety of langauges. This repository 
is an implementation of the Replicant transport in the Swift programming language. 

If you are looking for a tool which you can install and
use from the command line, take a look at [shapeshifter-dispatcher](https://github.com/OperatorFoundation/shapeshifter-dispatcher.git) instead.

ReplicantSwift implements the Pluggable Transports 3.0 specification available here:
<https://github.com/Pluggable-Transports/Pluggable-Transports-spec/tree/main/releases/PTSpecV3.0> Specifically,
they implement the [Swift Transports API v3.0](https://github.com/Pluggable-Transports/Pluggable-Transports-spec/blob/main/releases/PTSpecV3.0/Pluggable%20Transport%20Specification%20v3.0%20-%20Swift%20Transport%20API%20v3.0.md).

The purpose of the transport library is to provide a set of different
transports. Each transport implements a different method of shapeshifting
network traffic. The goal is for application traffic to be sent over the network
in a shapeshifted form that bypasses network filtering, allowing
the application to work on networks where it would otherwise be blocked or
heavily throttled.

#### Replicant
Replicant is Operator's Pluggable Transport that can be tuned for each adversary. It is designed to be more effective and efficient than older transports. It can be quickly reconfigured as filtering conditions change by updating just the configuration file.

There are two main advantages to using Replicant. First, it can be more effective than other transports. Simple transports such as shadowsocks work well against some adversaries, but other adversaries with more advanced filtering techniques can easily block them. In situations such as this, Replicant can work where other transports fail. Second, Replicant can be more efficient than other transports. Some transports that are very effective at circumventing the filter are also very inefficient, using a lot of bandwidth in order to implement their approach to shapeshifting. This can make it very expensive to run proxy servers using these transports. Replicant is designed to use the minimum amount of additional bandwidth in order to provide shapeshifting, and can therefore save on the cost of providing proxy servers. Less additional bandwidth used also means a faster connection and more reliable performance on slower Internet connections.

## Prerequisites

ReplicantSwift uses the Swift programming language minimum version 5.6. If you are using a Linux system follow the instructions on swift.org to install Swift. If you are using macOS we recommend that you install Xcode.

## Using the Library

### Add the dependency to your project

This can be done through the Xcode GUI or by updating your Package.swift file
```
dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/OperatorFoundation/ReplicantSwift.git", from: "1.0.0"),
    ],
```

```
targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MyApp",
            dependencies: [
                "ReplicantSwift",
            ]),
        .testTarget(
            name: "MyAppTests",
            dependencies: ["MyApp"]),
    ],
```

### Server:
1. Create a ToneburstServerConfig.
```
let starburstServer = StarburstConfig.SMTPServer
let toneburstServerConfig = ToneBurstServerConfig.starburst(config: starburstServer)
```

2. Create a PolishServerConfig.
```
let shadowServerConfig = ShadowConfig(key: "serverPrivateKeyHex", serverIP: "127.0.0.1", port: 1234, mode: .DARKSTAR)
let polishServerConfig = PolishServerConfig.darkStar(shadowServerConfig)
```

3. Create a ReplicantServerConfig with the polish and toneburst configs.  You can use nil in place of the toneburst and polish, but this is not recommended.
```
let replicantServerConfig = ReplicantServerConfig(polish: polishServerConfig, toneBurst: toneburstServerConfig)
```

4. Create a Replicant server connection.
```
let replicantListener = try replicant.listen(address: "127.0.0.1", port: 1234, config: replicantServerConfig)
Task {
   let replicantConnection = try replicantListener.accept()
   }
```

5. Call .read() and .write() on replicantConnection inside the Task block

### Client:
1. Create a ToneburstClientConfig:\.
```
let starburstClient = StarburstConfig.SMTPClient
let toneburstClientConfig = ToneBurstClientConfig.starburst(config: starburstClient)
```

2. Create a PolishClientConfig.
```
let shadowClientConfig = ShadowConfig(key: "serverPublicKeyHex", serverIP: "127.0.0.1", port: 1234, mode: .DARKSTAR)
let polishClientConfig = PolishClientConfig.darkStar(shadowClientConfig)
```

3. Create a ReplicantClientConfig with the polish and toneburst configs. You can use nil in place of the toneburst and polish, but this is not recommended.
```
let replicantClientConfig = ReplicantClientConfig(serverIP: "127.0.0.1", port: 1234, polish: polishClientConfig, toneBurst: toneburstClientConfig)
```

4. Create a Replicant client connection.
```
let replicantClient = try replicant.connect(host: "127.0.0.1", port: 1234, config: replicantClientConfig)
```

5. Call .read() and .write() on replicantClient

#### Creating a Replicant Config .json file
1. Parse the config to data.
```
// config can be of type ReplicantServerConfig or ReplicantClientConfig
guard let jsonData = config.createJSON() else {
   return
}
```

2. Create the path that the config will be written to.
```
let fileManager = FileManager.default
let configDirectory = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Desktop", isDirectory: true)
let configPath = configDirectory.appendingPathComponent("ReplicantConfig.json", isDirectory: false).path
```

3. Write the data to the config file at the specified path.
```
let configCreated = fileManager.createFile(atPath: configPath, contents: jsonData)
assert(configCreated == true)
```

### Credits
* Shadowsocks was developed by the Shadowsocks team. [whitepaper](https://shadowsocks.org/assets/whitepaper.pdf)
