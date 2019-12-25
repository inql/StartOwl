package service

import java.io.FileNotFoundException
import java.net.MalformedURLException

import net.ruippeixotog.scalascraper.browser.JsoupBrowser
import net.ruippeixotog.scalascraper.dsl.DSL._
import net.ruippeixotog.scalascraper.dsl.DSL.Extract._
import net.ruippeixotog.scalascraper.dsl.DSL.Parse._
import net.ruippeixotog.scalascraper.model._

class RssFinderService(domainName: String) {

  val browser = JsoupBrowser()
  var doc: browser.DocumentType = _

  try{
    doc = browser.get(domainName)
  } catch {
    case x @ (_: IllegalArgumentException) => List()
  }

  def getAllValidRssFeeds(): List[String] = {
    (wordPressFeed :: rssSourceUrl).filterNot(_.equals(""))
  }

  def wordPressFeed: String = {
    var feedUrl = domainName + "/feed"
    try {
      browser.get(feedUrl)
    } catch {
      case x @ (_: FileNotFoundException | _: MalformedURLException) => feedUrl = ""
    }
    feedUrl
  }





  def linkElementList: List[Element] = doc >> elementList("link")
  def rssElementFilter(element: Element): Boolean = element.hasAttr("type") && element.attr("type").equals("application/rss+xml")

  val operation = (p: Element) => p.attrs.getOrElse("href", "").charAt(0) match {
    case '/' => domainName + p.attrs.getOrElse("href","")
    case _ => p.attrs.getOrElse("href","")
  }

  def rssSourceUrl: List[String] = ElementFinderService.getElementsBasedOnFilter(linkElementList, rssElementFilter, operation) match {
    case result: List[String] => result
    case _ => throw ClassCastException
  }


}
