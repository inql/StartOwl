package com.startowl

import akka.actor.ActorSystem
import akka.http.scaladsl.Http
import akka.stream.ActorMaterializer
import akka.Done
import akka.http.scaladsl.server.Route
import akka.http.scaladsl.server.Directives._
import akka.http.scaladsl.model.{ContentTypes, HttpEntity, StatusCodes}
import akka.http.scaladsl.marshallers.sprayjson.SprayJsonSupport._
import spray.json.DefaultJsonProtocol._

import scala.io.StdIn
import scala.concurrent.Future


object Server extends App {

  import ServerSettingsTemplate._

  val server: Source[IncomingConnection, Future[ServerBinding]] =
    Http(actorSystem).bind(httpInterface, httpPort)

  log.info(s"\nAkka HTTP Server - Version ${actorSystem.settings.ConfigVersion} - running at http://$httpInterface:$httpPort/")

  val handler: Future[ServerBinding] =
    server
      .to(
        Sink.foreach {
          connection ⇒
            connection.handleWithAsyncHandler(asyncHandler(AkkaHttpRoutesTemplate.availableRoutes))
        }
      )
      .run()

  handler.failed.foreach { case ex: Exception ⇒ log.error(ex, "Failed to bind to {}:{}", httpInterface, httpPort) }

  StdIn.readLine(s"\nPress RETURN to stop...")

  handler
    .flatMap(binding ⇒ binding.unbind())
    .onComplete(_ ⇒ actorSystem.terminate())
}


}
