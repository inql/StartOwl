package com.startowl.routes

import akka.http.scaladsl.server.Directives._
import akka.http.scaladsl.server.Route
import com.startowl.config.ServerConfig._
import com.startowl.model._
import com.startowl.repository._
import de.heikoseeberger.akkahttpcirce._
import scala.concurrent.Future

object AllRoutes extends BaseRoute with ResponseFactory {

  import io.circe.generic.auto._

  protected def directives: Route =
    pathPrefix("service1") {
      get {
        path("status") {
          extractRequest{ req =>
            sendResponse(Future(ApiMessage(ApiStatusMessage.currentStatus())))
          }
        } ~
         path("models/apitest"/IntNumber){ (value) =>
           extractRequest { req =>
             sendResponse(Future.successful())
           }
         }
      }
    }

}
