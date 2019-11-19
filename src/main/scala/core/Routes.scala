package core

import akka.http.scaladsl.model.HttpResponse
import akka.http.scaladsl.server.{ExceptionHandler, Route}
import akka.http.scaladsl.server.RouteConcatenation._enhanceRouteWithConcatenation
import akka.http.scaladsl.server.directives.FutureDirectives.onComplete
import akka.http.scaladsl.model.StatusCodes.{OK, ServiceUnavailable}
import akka.http.scaladsl.server.Directives._
import akka.http.scaladsl.server.PathMatchers.LongNumber
import akka.routing.Router
import com.google.inject.{Inject, Singleton}
import directive.TestApiDirectives
import model.{DownstreamError, SearchRequest}
import repository.{InMemoryTestApiRepository, TestApiRepository}

import scala.util.{Failure, Success}
import util.ImplicitJsonConversions._

import scala.concurrent.Future

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
      pathPrefix("testresults") {
        pathEndOrSingleSlash {
          get {
            handleWithGeneric(testApiRepository.all()) { record =>
              complete(record)
            }
          }
        } ~
          path(Segment) { (tag: String) =>
            get {
              handleWithGeneric(testApiRepository.byTag(tag)) { record =>
                complete(record)
              }
            }
          }
      } ~
      pathPrefix("searchrequest"){
        get{
          complete(OK)
        }
        //todo: end it please
        parameters('domain,'tag.*) { (domain, tags) =>
          tags.toList match {
            case Nil => complete(s"Received query from domain ${domain} without any tags")
            case tag :: Nil => complete(s"Received query from domain ${domain} with only one tag: ${tag}")
            case multiple => complete(s"Received query from domain ${domain} with multiple tags: ${multiple.mkString(", ")}")
          }

        }
      }
    }
}
