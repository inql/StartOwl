package services

import javax.inject.Singleton
import models.SearchRule
import net.ruippeixotog.scalascraper.browser.{Browser, JsoupBrowser}
import net.ruippeixotog.scalascraper.browser.JsoupBrowser.JsoupElement
import net.ruippeixotog.scalascraper.dsl.DSL._
import net.ruippeixotog.scalascraper.dsl.DSL.Extract._
import net.ruippeixotog.scalascraper.dsl.DSL.Parse._
import net.ruippeixotog.scalascraper.model.Element

/**
 * Disclaimer: This is just a test of scalascraper package
 * Currently i don't know how exactly should i use play framework unfortunately.
 */
@Singleton
class WebScraperService {

  val browser: Browser = JsoupBrowser()

  def performScraping(rule: SearchRule, condition: (Element,String) => Boolean): Seq[(String, List[Element])] = {
    val domain = browser.get(rule.domain) >> elementList("a")
    for (keyword <- rule.keywords) yield (keyword -> domain.filter(condition(_,keyword)))
  }

  def searchByKeyword(element: Element, keyword: String): Boolean = element.text.contains(keyword)

  def denyByKeyword(element: Element, keyword: String): Boolean = !searchByKeyword(element,keyword)


}
