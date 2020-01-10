package util

import akka.http.scaladsl.marshallers.sprayjson.SprayJsonSupport
import model.allegro_api.AuthorizationResponse
import model.{ApiSearchResult, DownstreamError}
import spray.json.{DefaultJsonProtocol, RootJsonFormat}
import spray.json._

object ImplicitJsonConversions extends DefaultJsonProtocol with SprayJsonSupport{
//    implicit val searchResultJsonFormat: RootJsonFormat[ApiSearchResult] = jsonFormat4(ApiSearchResult)
    implicit val errorJsonFormat: RootJsonFormat[DownstreamError] = jsonFormat1(DownstreamError)
//    implicit val apiSearchResultFormat: RootJsonFormat[ApiSearchResult] = jsonFormat5(ApiSearchResult)
    implicit val authorizationResponseJsonFormat: RootJsonFormat[AuthorizationResponse] = jsonFormat5(AuthorizationResponse)
}
