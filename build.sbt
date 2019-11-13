name := "start-owl-api"

version := "1.0"

scalaVersion := "2.12.4"

scalaSource in Compile := baseDirectory.value / "src"
resourceDirectory in Compile := baseDirectory.value / "conf"
scalaSource in Test := baseDirectory.value / "test"
scalaSource in IntegrationTest := baseDirectory.value / "it"


val akkaVersion = "2.5.9"
val akkaHttpVersion = "10.0.11"
val circeVersion = "0.9.3"
libraryDependencies ++= {
  Seq(
    "com.typesafe.akka" %% "akka-http" % akkaHttpVersion,
    "com.typesafe.akka" %% "akka-http-spray-json" % akkaHttpVersion,
    "com.typesafe.akka" %% "akka-http-testkit" % akkaHttpVersion % Test,
    "org.scalatest" %% "scalatest" % "3.0.5" % "test, it",
    "org.jsoup" % "jsoup" % "1.8.3",
    "com.google.inject" % "guice" % "4.1.0",
    "com.typesafe.akka" %% "akka-actor" % akkaVersion,
    "io.circe" %% "circe-core" % circeVersion,
    "io.circe" %% "circe-generic" % circeVersion,
    "io.circe" %% "circe-parser" % circeVersion,
    "de.heikoseeberger" %% "akka-http-circe" % "1.21.0"
  )
}

enablePlugins(JavaAppPackaging)

lazy val root = (project in file(".")).configs(IntegrationTest).settings(Defaults.itSettings: _*)
