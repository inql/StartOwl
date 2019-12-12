package service

import model.{IconModel, IconSize, ImageFormat}
import model.ImageFormat.ImageFormat
import net.ruippeixotog.scalascraper.browser.JsoupBrowser
import util.TypesDef.LogoSearchResult
import net.ruippeixotog.scalascraper.dsl.DSL._
import net.ruippeixotog.scalascraper.dsl.DSL.Extract._
import net.ruippeixotog.scalascraper.dsl.DSL.Parse._
import net.ruippeixotog.scalascraper.model._
class IconFinderService(domainName: String) {



  val browser = JsoupBrowser()
  val doc = browser.get(domainName)
  val heightRegex = "^[0-9][^x]*".r
  val widthRegex = "(?<=x)[0-9]+".r
  val imageFormatRegex = "\\.(?:jpg|ico|png)".r

  def getAllLogoCandidates(): Unit = {

  }

  def appleIconFilter(element: Element): Boolean = element.hasAttr("rel") && element.attr("rel").equals("apple-touch-icon")

  def getIconsBasedOnFilter(condition: (Element => Boolean)): List[IconModel] = {
    (doc >> elementList("link")).filter(p => condition(p)).map(p =>
        IconModel(p.attr("href"),getIconSize(p),
          ImageFormat.withNameOpt(imageFormatRegex.findFirstIn(p.attr("href")).getOrElse(".png")).getOrElse(ImageFormat.PNG))).sortWith(_.size > _.size)
  }

  def getIconSize(element: Element): IconSize = {
    val sizes = element.attrs.getOrElse("sizes","")
    IconSize(heightRegex.findFirstIn(sizes).getOrElse("0").toInt, widthRegex.findFirstIn(sizes).getOrElse("0").toInt)
  }

}
