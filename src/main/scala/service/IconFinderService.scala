package service

import model.{IconModel, IconSize, ImageFormat}
import model.ImageFormat.ImageFormat
import net.ruippeixotog.scalascraper.browser.{Browser, JsoupBrowser}
import util.TypesDef.LogoSearchResult
import net.ruippeixotog.scalascraper.dsl.DSL._
import net.ruippeixotog.scalascraper.dsl.DSL.Extract._
import net.ruippeixotog.scalascraper.dsl.DSL.Parse._
import net.ruippeixotog.scalascraper.model._

import scala.util.matching.Regex
class IconFinderService(domainName: String) {



  val browser: Browser = JsoupBrowser()
  var doc: browser.DocumentType = _

  try{
    doc = browser.get(domainName)
  } catch {
    case x @ (_: IllegalArgumentException) => List(IconModel("no-perfect-icon-for-you",IconSize(0,0),ImageFormat.PNG))
  }

  val heightRegex: Regex = "^[0-9][^x]*".r
  val widthRegex: Regex = "(?<=x)[0-9]+".r
  val imageFormatRegex: Regex = "\\.(?:jpg|ico|png)".r
  val imageSizeRegex: Regex = "[0-9]{1,3}x[0-9]{1,3}".r

  def getBestLogoCandidate(): IconModel = {


    List.concat(
      getIconsBasedOnFilter(linkElementList,appleIconFilter,"href"),
      getIconsBasedOnFilter(linkElementList, faviconIconFilter, "href"),
      getIconsBasedOnFilter(metaElementList, msApplicationIconFilter, "content"),
      getIconsBasedOnFilter(metaElementList, openGraphProtocolIconFilter, "content")
    ).sortWith(_.size > _.size).headOption.getOrElse(IconModel("no-perfect-icon-for-you",IconSize(0,0),ImageFormat.PNG))


  }

  def appleIconFilter(element: Element): Boolean = element.hasAttr("rel") && element.attr("rel").equals("apple-touch-icon")

  def faviconIconFilter(element: Element): Boolean = element.hasAttr("rel") && element.attr("rel").equals("icon")

  def msApplicationIconFilter(element: Element): Boolean = element.hasAttr("name") && element.attr("name").equals("msapplication-TileImage")

  def openGraphProtocolIconFilter(element: Element): Boolean = element.hasAttr("property") && element.attr("property").equals("og:image")

  def metaElementList: List[Element] = doc >> elementList("meta")

  def linkElementList: List[Element] = doc >> elementList("link")

  def getIconsBasedOnFilter(baseElementList: List[Element], condition: (Element => Boolean), sourceAttr: String): List[IconModel] = {

    def getImageLink(element: Element): String = element.attrs.getOrElse(sourceAttr,"").charAt(0) match {
      case '/' => domainName + element.attrs.getOrElse(sourceAttr,"")
      case _ => element.attrs.getOrElse(sourceAttr,"")
    }

    def getIconSize(element: Element): IconSize = {
      val sizes = element.attrs.getOrElse("sizes",imageSizeRegex.findFirstIn(element.attr(sourceAttr)).getOrElse(""))
      IconSize(heightRegex.findFirstIn(sizes).getOrElse("0").toInt, widthRegex.findFirstIn(sizes).getOrElse("0").toInt)
    }

    val operation = (p: Element) =>
      IconModel(getImageLink(p),getIconSize(p),
        ImageFormat.withNameOpt(imageFormatRegex.findFirstIn(p.attr(sourceAttr)).getOrElse(".png")).getOrElse(ImageFormat.PNG))

    ElementFinderService.getElementsBasedOnFilter(baseElementList,condition,operation) match {
      case result: List[IconModel] => result
      case _ => throw new ClassCastException
    }
  }





}
