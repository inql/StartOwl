name := "StartOwl-akka"

version := "0.1"

scalaVersion := "2.13.1"

libraryDependencies ++= {
  val akkaVersion = "2.5.26"
  val akkaHttp = "10.1.10"
  val circeVersion = "0.12.3"
  Seq(
    "com.typesafe.akka" %% "akka-actor"      % akkaVersion,
    "com.typesafe.akka" %% "akka-http-core"  % akkaHttp,
    "com.typesafe.akka" %% "akka-http"       % akkaHttp,
    "com.typesafe.akka" %% "akka-stream" % akkaVersion,
    "com.typesafe.play" %% "play-ws-standalone-json"       % "2.0.7",
    "com.typesafe.akka" %% "akka-slf4j"      % akkaVersion,
    "ch.qos.logback"    %  "logback-classic" % "1.2.3",
    "de.heikoseeberger" %% "akka-http-play-json"   % "1.29.0",
    "com.typesafe.akka" %% "akka-testkit"    % akkaVersion   % "test",
    "org.scalatest"     %% "scalatest"       % "3.2.0-M1"       % "test",
    "io.circe" %% "circe-core" % circeVersion,
    "io.circe" %% "circe-generic" % circeVersion,
    "io.circe" %% "circe-parser" % circeVersion,
    "com.typesafe.akka" %% "akka-http-spray-json" % akkaHttp,
    "de.heikoseeberger" %% "akka-http-circe" % "1.29.1"
  )
}