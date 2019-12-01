package util

import akka.http.scaladsl.marshallers.sprayjson.SprayJsonSupport
import model.{DownstreamError, ApiSearchResult}
import spray.json.{DefaultJsonProtocol, RootJsonFormat}

object ImplicitJsonConversions extends DefaultJsonProtocol with SprayJsonSupport{
//    implicit val searchResultJsonFormat: RootJsonFormat[ApiSearchResult] = jsonFormat4(ApiSearchResult)
    implicit val errorJsonFormat: RootJsonFormat[DownstreamError] = jsonFormat1(DownstreamError)
}
