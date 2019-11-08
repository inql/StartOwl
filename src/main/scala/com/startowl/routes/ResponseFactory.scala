package com.startowl.routes

import akka.http.scaladsl.marshalling.ToResponseMarshallable
import akka.http.scaladsl.model.StatusCodes._
import akka.http.scaladsl.server.Directives._
import akka.http.scaladsl.server._
import akka.http.scaladsl.server.Route
import com.startowl.model.{ApiMessage, ApiStatusMessage}
import com.sun.xml.internal.ws.util.Pool.Marshaller

import scala.concurrent.Future
import scala.util.{Failure, Success}

trait ResponseFactory {

  import com.startowl.config.ServerConfig._
  import io.circe.generic.auto._

  def sendResponse[T](eventualResult: Future[T])(implicit marshaller: T => ToResponseMarshallable): Route = {
    onComplete(eventualResult){
      case Success(result) => complete(result)
      case Failure(e) => {
        log.error(s"Error: ${e.toString}")
        complete(ToResponseMarshallable(InternalServerError -> ApiMessage(ApiStatusMessage.unknownException)))
      }
    }
  }

}
