package service

import model.{ApiSearchResult, SearchRequest}
import net.ruippeixotog.scalascraper.browser.JsoupBrowser
import net.ruippeixotog.scalascraper.dsl.DSL._
import net.ruippeixotog.scalascraper.dsl.DSL.Extract._
import net.ruippeixotog.scalascraper.dsl.DSL.Parse._
import net.ruippeixotog.scalascraper.model.Element
import javax.inject.{Inject, Singleton}
import util.AkkaSystemUtils

import scala.concurrent.{ExecutionContext, Future}
@Singleton
class WebScraperService@Inject extends AkkaSystemUtils{
  import system.dispatcher
  val browser = JsoupBrowser()

  def search(query: SearchRequest): Future[Map[String, Seq[ApiSearchResult]]] = {
    system.log.info(s"Received request to get data from: ${query}")
    //todo: for now it only gives the title to given result
    val doc = browser.get(query.domain).body
    val allHyperLinks = doc >> elementList("a")
    for (element <- allHyperLinks.filter(p => query.keyword.exists(p.text.contains))) crawlInto(element)
    Future.successful(Map("results" -> (for (key <- query.keyword) yield ApiSearchResult(query.domain,allHyperLinks.filter(p => p.text.contains(key)).mkString(", "),"","",""))))
  }

  def crawlInto(uri: Element): Unit = {
    val doc = browser.get(uri.attr("href"))
    system.log.info(s"Processing element ${uri} - entering ${uri.attr("href")}")
  }


}
