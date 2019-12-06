name := "start-owl-api"

version := "1.0"

scalaVersion := "2.12.10"

scalaSource in Compile := baseDirectory.value / "src/main/scala/"
resourceDirectory in Compile := baseDirectory.value / "conf"
scalaSource in Test := baseDirectory.value / "src/test/scala/"
scalaSource in IntegrationTest := baseDirectory.value / "it"


val akkaVersion = "2.5.23"
val akkaHttpVersion = "10.1.10"
val circeVersion = "0.9.3"
libraryDependencies ++= {
  Seq(
    "com.typesafe.akka" %% "akka-http" % akkaHttpVersion,
    "com.typesafe.akka" %% "akka-http-core" % akkaHttpVersion,
    "com.typesafe.akka" %% "akka-http-spray-json" % akkaHttpVersion,
    "com.typesafe.akka" %% "akka-parsing" % akkaHttpVersion,
    "com.typesafe.akka" %% "akka-http-testkit" % akkaHttpVersion % Test,
    "org.scalatest" %% "scalatest" % "3.0.5" % "test, it",
    "org.jsoup" % "jsoup" % "1.8.3",
    "com.google.inject" % "guice" % "4.1.0",
    "com.typesafe.akka" %% "akka-actor" % akkaVersion,
    "com.typesafe.akka" %% "akka-protobuf" % akkaVersion,
    "com.typesafe.akka" %% "akka-stream" % akkaVersion,
    "io.circe" %% "circe-core" % circeVersion,
    "io.circe" %% "circe-generic" % circeVersion,
    "io.circe" %% "circe-parser" % circeVersion,
    "de.heikoseeberger" %% "akka-http-circe" % "1.21.0",
    "ch.megard" %% "akka-http-cors" % "0.4.2",
    "com.rometools" % "rome" % "1.8.1",
    "org.scala-lang.modules" %% "scala-xml" % "1.2.0",
    "net.ruippeixotog" %% "scala-scraper" % "2.2.0",
    "com.typesafe.akka" %% "akka-stream-testkit" % "2.5.26" % Test
  )
}

fork := true
enablePlugins(JavaAppPackaging)

lazy val root = (project in file(".")).configs(IntegrationTest).settings(Defaults.itSettings: _*)
