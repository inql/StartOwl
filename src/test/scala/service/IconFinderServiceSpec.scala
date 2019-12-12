package service

import net.ruippeixotog.scalascraper.browser.{Browser, JsoupBrowser}
import net.ruippeixotog.scalascraper.model.Element
import org.scalatest.{BeforeAndAfterEach, Matchers, WordSpec}

class IconFinderServiceSpec extends WordSpec with Matchers with BeforeAndAfterEach {

  val urlToCheck: String = "https://www.tvn24.pl"

  var iconFinderService: IconFinderService = _

  override def beforeEach(): Unit = {
    iconFinderService = new IconFinderService(urlToCheck)
  }

  "IconFinderService" should {

    "return a list of apple-type favicons when getIconsBasedOnAppleTouch is called" in {
      val result: List[Element] = iconFinderService.getIconsBasedOnAppleTouch()
      assertResult(List())(result)

    }

  }


}
