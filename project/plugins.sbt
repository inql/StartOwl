logLevel := Level.Warn
lazy val `startowl` = (project in file(".")).dependsOn(elmPlugin)
lazy val elmPlugin = ClasspathDependency(RootProject(file("../../..")), None)
resolvers += "Typesafe repository" at "https://repo.typesafe.com/typesafe/releases/"

// The Play plugin
addSbtPlugin("com.typesafe.play" % "sbt-plugin" % "2.7.3")

// Adds dependencyUpdates task
addSbtPlugin("com.timushev.sbt" % "sbt-updates" % "0.3.4")