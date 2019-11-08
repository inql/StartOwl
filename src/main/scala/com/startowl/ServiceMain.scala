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


object ServiceMain extends App {

  implicit val system = ActorSystem("startowl-api")
  implicit val materialize = ActorMaterializer()
  //needed for the future flatMap/onComplete in the end
  implicit val executionContext = system.dispatcher

  var orders: List[Item] = Nil

  //domain model
  final case class Item(name: String, id: Long)
  final case class Order(items: List[Item])

  //formats for unmarshallingandmarshalling
  implicit val itemFormat = jsonFormat2(Item)
  implicit val orderFormat = jsonFormat1(Order)

  // (fake) async database query ap1
  def fetchItem(itemId: Long): Future[Option[Item]] = Future {
    orders.find(o => o.id == itemId)
  }
  def saveOrder(order: Order): Future[Done] = {
    orders = order match {
      case Order(items) => items ::: orders
      case _            => orders
    }
    Future { Done }
  }






  val route :Route =
    concat(
      get{
        pathPrefix("item"/LongNumber) { id =>
          //there might be no item for a given id
          val maybeItem: Future[Option[Item]] = fetchItem(id)

          onSuccess(maybeItem) {
            case Some(item) => complete(item)
            case None => complete(StatusCodes.NotFound)
          }
        }
      },
      post {
        path("create-order"){
          entity(as[Order]) { order =>
            val saved: Future[Done] = saveOrder(order)
            onComplete(saved) { done =>
              complete("order created")
            }
          }
        }
      }
    )

  val bindingFuture = Http().bindAndHandle(route,"localhost",8080)

  println(s"Server online at http://localhost:8080/\nPress RETURN to stop...")
  StdIn.readLine()
  bindingFuture
    .flatMap(_.unbind())
    .onComplete(_ => system.terminate())


}
