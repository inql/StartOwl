package main.core

import com.typesafe.config.{Config, ConfigFactory}

class AppConfig {

  lazy val config: Config = ConfigFactory.load()

  lazy val httpHost: String = config.getString("http.host")
  lazy val httpPort: Int = config.getInt("http.port")

  lazy val appName: String = config.getString("app.name")
}
