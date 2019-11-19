package service

import com.google.inject.{Inject, Singleton}
import model.{SearchRequest, SearchResult}
import net.ruippeixotog.scalascraper.browser.JsoupBrowser
import util.AkkaSystemUtils

import net.ruippeixotog.scalascraper.dsl.DSL._
import net.ruippeixotog.scalascraper.dsl.DSL.Extract._
import net.ruippeixotog.scalascraper.dsl.DSL.Parse._
import net.ruippeixotog.scalascraper.model.Element

import scala.concurrent.Future

@Singleton
class WebScrapperService @Inject() extends AkkaSystemUtils{

  val browser = JsoupBrowser()

  def search(query: SearchRequest): Future[Seq[SearchResult]] = {
    //todo: for now it only gives the title to given result
    val doc = browser.get(query.domain)
    val allHyperLinks = doc >> elementList("a")
    Future.successful(for (key <- query.keyword) yield SearchResult("",allHyperLinks.filter(p => p.text.contains(key)).mkString(", "),"","",""))

  }


}
