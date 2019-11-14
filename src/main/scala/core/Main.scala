package core

import akka.NotUsed
import akka.actor.ActorSystem
import akka.http.scaladsl.Http
import akka.http.scaladsl.model.{HttpRequest, HttpResponse}
import akka.http.scaladsl.server.RouteResult.route2HandlerFlow
import akka.stream.ActorMaterializer
import akka.stream.scaladsl.Flow
import com.google.inject.{AbstractModule, Guice, Injector}
import model.TestSearchResult
import repository.{InMemoryTestApiRepository, TestApiRepository}
import util.AkkaSystemUtils

trait MainApp extends AkkaSystemUtils {
  import system.dispatcher
  lazy val injector: Injector = Guice.createInjector(new Module())
  lazy val appConfig: AppConfig = injector.getInstance(classOf[AppConfig])
  lazy val routes: Flow[HttpRequest, HttpResponse, NotUsed] = route2HandlerFlow(injector.getInstance(classOf[Routes]).routes)

  def main(args: Array[String]): Unit = {
    Http().bindAndHandle(routes, appConfig.httpHost, appConfig.httpPort)
    system.log.info(s"Server started: ${appConfig.appName} at ${appConfig.httpHost}:${appConfig.httpPort}")
  }
}

object Main extends MainApp

class Module extends AbstractModule {
  def configure: Unit = {
    //no custom bindings required for now
  }
}
