package com.startowl.config

import akka.actor.ActorSystem
import akka.event.{LogSource, Logging, LoggingAdapter}
import akka.stream.ActorMaterializer
import com.typesafe.config.{Config, ConfigFactory}

import scala.concurrent.ExecutionContext

trait ServerConfig {

  lazy private val config: Config = ConfigFactory.load()
  private val httpConfig: Config = config.getConfig("http")
  val httpInterface: String = httpConfig.getString("interface")
  val httpPort: Int = httpConfig.getInt("port")

  implicit val actorSystem: ActorSystem = ActorSystem("akka-http-circe-json")
  implicit val materializer: ActorMaterializer = ActorMaterializer()
  implicit val executionContext: ExecutionContext = actorSystem.dispatcher
  private implicit val logSource: LogSource[ServerConfig] = (t: ServerConfig) => t.getClass.getSimpleName
  private def logger(implicit logSource: LogSource[_ <: ServerConfig]) = Logging(actorSystem, this.getClass)

  implicit val log: LoggingAdapter = logger


}

object ServerConfig extends ServerConfig
