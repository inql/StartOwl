logLevel := Level.Warn

//these are required for Heroku support
addSbtPlugin("com.heroku" % "sbt-heroku" % "1.0.1")
addSbtPlugin("com.typesafe.sbt" % "sbt-native-packager" % "1.3.3")
//for coverage
addSbtPlugin("org.scoverage" % "sbt-scoverage" % "1.5.1")
