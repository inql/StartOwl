package com.startowl

import akka.http.scaladsl.server.{Directives, Route}
import com.startowl.repositories.SearchRequestRepository

trait Router {

  def route: Route

}

class SearchRequestRouter(searchRequestRepository: SearchRequestRepository) extends Router with Directives {

  import de.heikoseeberger.akkahttpcirce.FailFastCirceSupport._
  import io.circe.generic.auto._

  override def route: Route = pathPrefix("searchrequests"){
    pathEndOrSingleSlash {
      get {
        complete(searchRequestRepository.all())
      }
    }
  }
}
