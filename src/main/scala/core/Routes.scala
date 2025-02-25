package core

import akka.actor.{ActorSystem, Props}
import akka.http.scaladsl.model.{HttpResponse, StatusCodes}
import akka.http.scaladsl.server.{Directive, ExceptionHandler, RejectionHandler, Route}
import akka.http.scaladsl.server.RouteConcatenation._enhanceRouteWithConcatenation
import akka.http.scaladsl.server.directives.FutureDirectives.onComplete
import akka.http.scaladsl.model.StatusCodes.{OK, ServiceUnavailable}
import akka.http.scaladsl.server.Directives._
import akka.http.scaladsl.server.PathMatchers.LongNumber
import akka.routing.Router
import akka.util.Timeout
import com.google.inject.{Inject, Singleton}
import directive.TestApiDirectives
import model.{ApiSearchResult, DownstreamError, SearchRequest, ShopSearchRequest}
import repository.{InMemoryTestApiRepository, TestApiRepository}
import service.{AllegroResultFinderService, AtomAndRssService}
import ch.megard.akka.http.cors.scaladsl.CorsDirectives._
import util.AkkaSystemUtils
import java.util.concurrent.TimeUnit

import scala.util.{Failure, Success}
import util.ImplicitJsonConversions._
import akka.actor._
import akka.http.scaladsl.model.Uri.Path.~
import akka.pattern.ask
import akka.util.Timeout
import org.joda.time.Seconds

import scala.concurrent.duration.{Duration, FiniteDuration}
import scala.concurrent.{Await, Future}

@Singleton
class Routes @Inject()(atomAndRssService: AtomAndRssService, allegroResultFinderService: AllegroResultFinderService) extends AkkaSystemUtils with TestApiDirectives{
  import de.heikoseeberger.akkahttpcirce.FailFastCirceSupport._
  import io.circe.generic.auto._
  import ch.megard.akka.http.cors.scaladsl.CorsDirectives._

  // Your rejection handler
  val rejectionHandler: RejectionHandler = corsRejectionHandler.withFallback(RejectionHandler.default)

  // Your exception handler
  val exceptionHandler = ExceptionHandler {
    case e: NoSuchElementException => complete(StatusCodes.NotFound -> e.getMessage)
  }
  // Combining the two handlers only for convenience
  val handleErrors: Directive[Unit] = handleRejections(rejectionHandler) & handleExceptions(exceptionHandler)

  lazy val routes: Route = {
    handleErrors {
      cors() {
        path("healthcheck") {
          get {
            complete(OK)
          }
        } ~
          pathPrefix("allegrosearch"){
            post {
              entity(as[ShopSearchRequest]) { shopSearchRequest =>
                handleWithGeneric(allegroResultFinderService.init(shopSearchRequest)) {record =>
                  complete(record)
                }
              }
            }
          } ~
          pathPrefix("searchrequest"){
            post {
              entity(as[SearchRequest]) { searchRequest =>
                handleWithGeneric(atomAndRssService.findAllResults(searchRequest)) { record =>
                  complete(record)
                }
              }
            }
          }
      }
    }
    }
}
