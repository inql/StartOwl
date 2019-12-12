package service

import net.ruippeixotog.scalascraper.browser.JsoupBrowser
import util.TypesDef.LogoSearchResult
import net.ruippeixotog.scalascraper.dsl.DSL._
import net.ruippeixotog.scalascraper.dsl.DSL.Extract._
import net.ruippeixotog.scalascraper.dsl.DSL.Parse._
import net.ruippeixotog.scalascraper.model._
class IconFinderService(domainName: String) {



  val browser = JsoupBrowser()
  val doc = browser.get(domainName)

  def getAllLogoCandidates(): LogoSearchResult = {
    
  }

  def getIconsBasedOnAppleTouch() = {
    doc >> elementList("link")
  }

}
