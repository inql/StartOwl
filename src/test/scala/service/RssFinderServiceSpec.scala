package service

import net.ruippeixotog.scalascraper.browser.JsoupBrowser
import org.scalatest.{BeforeAndAfterEach, Matchers, WordSpec}

class RssFinderServiceSpec extends WordSpec with Matchers with BeforeAndAfterEach{

  val urlToCheckWordpressFeeds = "http://www.aweber.com/blog"
  val urlToCheckTumblrFeeds = "https://srbachchan.tumblr.com"
  val urlToCheckApplicationRssFeeds = "https://tvn24.pl"
  val urlToCheckBloggerFeeds = "https://nikonorov.pl"
  val urlToCheckCombinedFeeds = "https://wykop.pl"
  val browser = JsoupBrowser()


  var wordPressRssFinderService: RssFinderService = _
  var tumblrRssFinderService: RssFinderService = _
  var applicationRssFinderService: RssFinderService = _
  var bloggerRssFinderService: RssFinderService = _
  var combinedRssFinderService: RssFinderService = _

  override protected def beforeEach(): Unit = {
    wordPressRssFinderService = new RssFinderService(urlToCheckWordpressFeeds)
    tumblrRssFinderService = new RssFinderService(urlToCheckTumblrFeeds)
    applicationRssFinderService = new RssFinderService(urlToCheckApplicationRssFeeds)
    bloggerRssFinderService = new RssFinderService(urlToCheckBloggerFeeds)
    combinedRssFinderService = new RssFinderService(urlToCheckCombinedFeeds)
  }

  "RssFinderService" should {

    "return a String when wordPressFeed function is called" in {
      val result = wordPressRssFinderService.wordPressFeed
      result shouldBe a [String]
      noException should be thrownBy browser.get(result)
    }

    "return a String when tumblrFeed function is called" in {
      val result = tumblrRssFinderService.tumblrFeed
      result shouldBe a [String]
      noException should be thrownBy browser.get(result)
    }

    "return a list of Strings when rssSourceUrl function is called" in {
      val result = applicationRssFinderService.rssSourceUrl
      result shouldBe a [List[String]]
      result.foreach(
        noException should be thrownBy browser.get(_)
      )
    }

    "return a String when bloggerFeed function is called" in {
      val result = bloggerRssFinderService.wordPressFeed
      result shouldBe a [String]
      noException should be thrownBy browser.get(result)
    }

    "return valid URL (not \"\") when wordPressFeed function is called" in {
      val result = wordPressRssFinderService.wordPressFeed
      result should not be ""
      noException should be thrownBy browser.get(result)
    }

    "return valid URL (not \"\") when tumblrFeed function is called" in {
      val result = tumblrRssFinderService.tumblrFeed
      result should not be ""
      noException should be thrownBy browser.get(result)
    }

    "return valid URL (not \"\") when rssSourceUrl function is called" in {
      val result = applicationRssFinderService.rssSourceUrl
      result should not contain ""
      result.foreach(
        noException should be thrownBy browser.get(_)
      )
    }

    "return valid URL (not \"\") when bloggerFeed function is called" in {
      val result = bloggerRssFinderService.wordPressFeed
      result should not be ""
      noException should be thrownBy browser.get(result)
    }

    "return a list of Strings when getAllValidRssFeeds is called" in {
      val result = combinedRssFinderService.getAllValidRssFeeds()
      result shouldBe a [List[String]]
      result.foreach(
        noException should be thrownBy browser.get(_)
      )
    }

    "return all valid URLs (list not contains \"\") when getAllValidRssFeeds is called" in {
      val result = combinedRssFinderService.getAllValidRssFeeds()
      result should not contain ""
      result should not be empty
      result.foreach(
        noException should be thrownBy browser.get(_)
      )
    }

  }

}
