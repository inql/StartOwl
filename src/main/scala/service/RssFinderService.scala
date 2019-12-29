package service

import java.io.FileNotFoundException
import java.net.MalformedURLException

import net.ruippeixotog.scalascraper.browser.JsoupBrowser
import net.ruippeixotog.scalascraper.dsl.DSL._
import net.ruippeixotog.scalascraper.dsl.DSL.Extract._
import net.ruippeixotog.scalascraper.dsl.DSL.Parse._
import net.ruippeixotog.scalascraper.model._

import scala.util.matching.Regex

class RssFinderService(domainName: String) {

  val browser = JsoupBrowser()
  var doc: browser.DocumentType = _

  try{
    doc = browser.get(domainName)
  } catch {
    case x @ (_: IllegalArgumentException) => List()
  }

  def getAllValidRssFeeds(): List[String] = {
    (wordPressFeed :: tumblrFeed :: bloggerFeed :: rssSourceUrl).filterNot(_.equals(""))
  }

  def wordPressFeed: String = getFeedBasedOnUrl(domainName + "/feed")
  def tumblrFeed: String = getFeedBasedOnUrl(domainName + "/rss")
  def bloggerFeed: String = getFeedBasedOnUrl(domainName + "/feeds/posts/default")

  def getFeedBasedOnUrl(feedUrl: String): String = {
    try {
      browser.get(feedUrl)
    } catch {
      case x @ (_: FileNotFoundException | _: MalformedURLException) => return ""
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
    case _ => throw new ClassCastException
  }


}
