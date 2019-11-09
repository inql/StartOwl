package main.util

import akka.actor.ActorSystem
import akka.stream.ActorMaterializer

trait AkkaSystemUtils {
  implicit val system: ActorSystem = ActorSystem("actor-system")
  implicit val materializer: ActorMaterializer = ActorMaterializer()

}
