package service

import model.{IconModel, IconSize, ImageFormat}
import net.ruippeixotog.scalascraper.browser.{Browser, JsoupBrowser}
import net.ruippeixotog.scalascraper.model.Element
import org.scalatest.{BeforeAndAfterEach, Matchers, WordSpec}

class IconFinderServiceSpec extends WordSpec with Matchers with BeforeAndAfterEach {

  val urlToCheckAppleIcons: String = "https://www.polsatnews.pl"
  val urlToCheckFavicons: String = "https://www.onet.pl"
  val urlToCheckMsApplicationIcons: String = "https://www.wykop.pl"
  val urlToCheckOpenGraphIcons: String = "https://www.github.com"
  val urlToFindAllIcons: String = "https://www.wykop.pl"

  var appleIconFinderService: IconFinderService = _
  var faviconIconFinderService: IconFinderService = _
  var msApplicationIconFinderService: IconFinderService = _
  var openGraphIconFinderService: IconFinderService = _
  var allIconFinderService: IconFinderService = _

  override def beforeEach(): Unit = {
    appleIconFinderService = new IconFinderService(urlToCheckAppleIcons)
    faviconIconFinderService = new IconFinderService(urlToCheckFavicons)
    msApplicationIconFinderService = new IconFinderService(urlToCheckMsApplicationIcons)
    openGraphIconFinderService = new IconFinderService(urlToCheckOpenGraphIcons)
    allIconFinderService = new IconFinderService(urlToFindAllIcons)
  }

  "IconFinderService" should {

    "return a list of IconModels when getIconsBasedOnFilter is called" in {
      val result: List[IconModel] = appleIconFinderService.getIconsBasedOnFilter(appleIconFinderService.linkElementList, appleIconFinderService.appleIconFilter, "href")
      result shouldBe a [List[_]]
    }

    "return non empty list of IconModels when getIconsBasedOnFilter is called" in {
      val result: List[IconModel] = appleIconFinderService.getIconsBasedOnFilter(appleIconFinderService.linkElementList, appleIconFinderService.appleIconFilter, "href")
      result should not be empty
    }

    "return a list of IconModels which contains at least one valid image record" in {
      val result: List[IconModel] = appleIconFinderService.getIconsBasedOnFilter(appleIconFinderService.linkElementList, appleIconFinderService.appleIconFilter, "href")
      val expected: IconModel = IconModel("https://www.polsatnews.pl/apple-touch-icon.png",IconSize(0,0),ImageFormat.PNG)
      result should contain (expected)
    }

    "return a list of apple-type favicons when getIconsBasedOnFilter with apple-filter is called" in {
      val result: List[IconModel] = appleIconFinderService.getIconsBasedOnFilter(appleIconFinderService.linkElementList,appleIconFinderService.appleIconFilter,"href")
      val expected: List[IconModel] = List(IconModel("https://www.polsatnews.pl/apple-touch-icon.png",IconSize(0,0),ImageFormat.PNG))
      assertResult(expected)(result)

    }

    "return a list of favicon-type favicons when getIconsBasedOnFilter with favicon-filter is called" in {
      val result: List[IconModel] = faviconIconFinderService.getIconsBasedOnFilter(faviconIconFinderService.linkElementList,faviconIconFinderService.faviconIconFilter,"href")
      val expected: List[IconModel] = List(IconModel("https://ocdn.eu/onetmobilemainpage/manifestprod/icons2/favicon-16x16.png",IconSize(16,16),ImageFormat.PNG), IconModel("https://ocdn.eu/onetmobilemainpage/manifestprod/icons2/favicon-32x32.png",IconSize(32,32),ImageFormat.PNG),
      IconModel("https://ocdn.eu/onetmobilemainpage/manifestprod/icons2/pwa-192x192.png",IconSize(192,192),ImageFormat.PNG))
      assertResult(expected)(result)

    }

    "return a list of msapplication-type favicons when getIconsBasedOnFilter with msapplication-filter is called" in {
      val result: List[IconModel] = msApplicationIconFinderService.getIconsBasedOnFilter(msApplicationIconFinderService.metaElementList,msApplicationIconFinderService.msApplicationIconFilter,"content")
      val expected: List[IconModel] = List(IconModel("https://www.wykop.pl/static/wykoppl7/img/mstile-144x144.png",IconSize(144,144),ImageFormat.PNG))
      assertResult(expected)(result)

    }

    "return a list of open-graph-type favicons when getIconsBasedOnFilter with open-graph-filter is called" in {
      val result: List[IconModel] = openGraphIconFinderService.getIconsBasedOnFilter(openGraphIconFinderService.metaElementList,openGraphIconFinderService.openGraphProtocolIconFilter,"content")
      val expected: List[IconModel] = List(IconModel("https://github.githubassets.com/images/modules/open_graph/github-logo.png",IconSize(0,0),ImageFormat.PNG),
      IconModel("https://github.githubassets.com/images/modules/open_graph/github-mark.png",IconSize(0,0),ImageFormat.PNG), IconModel("https://github.githubassets.com/images/modules/open_graph/github-octocat.png",IconSize(0,0),ImageFormat.PNG))
      assertResult(expected)(result)

    }

    "return best quality icon when getBestLogoCandidate is called" in {
      val result: IconModel = allIconFinderService.getBestLogoCandidate()
      val expected: IconModel = IconModel("https://www.wykop.pl/static/wykoppl7/img/favicon-160x160.png",IconSize(160,160),ImageFormat.PNG)
      assertResult(expected)(result)

    }

  }


}
