package main.core

import akka.http.scaladsl.model.HttpResponse
import akka.http.scaladsl.server.{ExceptionHandler, Route}
import akka.http.scaladsl.server.RouteConcatenation._enhanceRouteWithConcatenation
import akka.http.scaladsl.server.directives.FutureDirectives.onComplete
import akka.http.scaladsl.model.StatusCodes.{OK, ServiceUnavailable}
import akka.http.scaladsl.server.Directives._
import akka.http.scaladsl.server.PathMatchers.LongNumber
import akka.routing.Router
import com.google.inject.{Inject, Singleton}
import main.directive.TestApiDirectives
import main.model.DownstreamError
import main.repository.{InMemoryTestApiRepository, TestApiRepository}

import scala.util.{Failure, Success}
import main.util.ImplicitJsonConversions._

trait Router

@Singleton
class Routes @Inject()(testApiRepository: InMemoryTestApiRepository) extends Router with TestApiDirectives{
  import de.heikoseeberger.akkahttpcirce.FailFastCirceSupport._
  import io.circe.generic.auto._

  lazy val routes: Route = {
        path("healthcheck") {
          get {
            complete(OK)
          }
        } ~
      pathPrefix("testresults"){
        pathEndOrSingleSlash{
          get {
            handleWithGeneric(testApiRepository.all()) { record =>
              complete(record)
            }
          }
        } ~
        path(Segment){ (tag : String) =>
          get {
            handleWithGeneric(testApiRepository.byTag(tag)) { record =>
              complete(record)
            }
          }
        }
      }
    }
}
