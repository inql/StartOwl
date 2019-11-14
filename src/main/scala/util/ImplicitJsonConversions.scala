package util

import akka.http.scaladsl.marshallers.sprayjson.SprayJsonSupport
import model.{DownstreamError, SearchResult}
import spray.json.{DefaultJsonProtocol, RootJsonFormat}

object ImplicitJsonConversions extends DefaultJsonProtocol with SprayJsonSupport{
    implicit val searchResultJsonFormat: RootJsonFormat[SearchResult] = jsonFormat4(SearchResult)
    implicit val errorJsonFormat: RootJsonFormat[DownstreamError] = jsonFormat1(DownstreamError)
}
