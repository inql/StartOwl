package service

import akka.actor.Actor
import akka.event.Logging
import javax.inject.Inject
import model.{ApiSearchResult, SearchRequest}
import net.ruippeixotog.scalascraper.browser.JsoupBrowser
import net.ruippeixotog.scalascraper.model.Element
import net.ruippeixotog.scalascraper.scraper.ContentExtractors.elementList
import net.ruippeixotog.scalascraper.dsl.DSL._
import net.ruippeixotog.scalascraper.dsl.DSL.Extract._
import net.ruippeixotog.scalascraper.dsl.DSL.Parse._
import net.ruippeixotog.scalascraper.model.Element
import util.AkkaSystemUtils

import scala.annotation.tailrec
import scala.concurrent.Future

class AtomAndRssService@Inject extends AkkaSystemUtils{

  val browser = JsoupBrowser()

  def search(query: SearchRequest): Future[Map[String, Seq[ApiSearchResult]]] = {
    system.log.info(s"Received request to get data from: ${query}")
    //todo: for now it only gives the title to given result
    val doc = browser.get(query.domain).body
    val allHyperLinks = doc >> elementList("a")

    Future.successful(getAllResults(query.keyword,allHyperLinks))
  }

  def getAllResults(keywords: List[String], allHyperLinks: List[Element]): Map[String,Seq[ApiSearchResult]] = {
    @tailrec
    def getAllResultsFromKeyword(keywords: List[String], allHyperLinks: List[Element], result: Seq[ApiSearchResult]): Seq[ApiSearchResult] = keywords match {
      case Nil => result
      case keyword :: rest => getAllResultsFromKeyword(
        rest, allHyperLinks,
        (for (element <- allHyperLinks.filter(_.text.contains(keyword))) yield ApiSearchResult(element.attr("href"),element.text,"","","")) ++ result)
    }
    val finalResult = Map("results" -> getAllResultsFromKeyword(keywords,allHyperLinks,Seq()))
    finalResult
  }

}


