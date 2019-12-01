package service

import akka.actor.Actor
import akka.event.Logging
import model.{RssFeed, RssItem}

abstract class Reader extends Actor {
  val log = Logging(context.system, this)

  def print(feed: RssFeed): Unit ={
    println(feed.latest)
  }
}

class RssReader {

}
