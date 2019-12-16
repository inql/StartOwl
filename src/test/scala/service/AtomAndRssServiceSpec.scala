package service

import java.net.MalformedURLException

import model.{ApiSearchResult, SearchRequest}
import org.scalatest.concurrent.ScalaFutures
import org.scalatest.{BeforeAndAfterEach, Matchers, WordSpec}
import util.TypesDef.MappedApiSearchResult

import scala.concurrent.Future

class AtomAndRssServiceSpec extends WordSpec with Matchers with BeforeAndAfterEach with ScalaFutures {

  var emptyRequest, wrongUrlRequest, noTagsRequest, correctRequest, multipleTagsRequest, nullUrlRequest, nullTagsRequest: SearchRequest = _
  var rssPolsatXml, rssTvnXml, rssEmptyXml: Option[String] = _
  var atomAndRssService: AtomAndRssService = _

  override def beforeEach(): Unit = {
    rssPolsatXml = Option("file://" concat getClass.getResource("../rssPolsat.xml").getPath)
    rssTvnXml = Option("file://" concat getClass.getResource("../rssTvn.xml").getPath)

    emptyRequest = SearchRequest(Option(""),List())
    wrongUrlRequest = SearchRequest(Option("wrong.url"),List())
    correctRequest = SearchRequest(rssPolsatXml, List("Uber"))
    multipleTagsRequest = SearchRequest(rssTvnXml, List("PZPN", "Sport"))
    noTagsRequest = SearchRequest(rssTvnXml,List())

    nullUrlRequest = SearchRequest(None)
    nullTagsRequest = SearchRequest(rssTvnXml, null)

    atomAndRssService = new AtomAndRssService
  }

  "Atom and Rss service" should {

    "raise an exception when empty request is given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.search(emptyRequest)
      whenReady(f.failed) { s => s shouldBe a [MalformedURLException] }
    }

    "raise an exception when invalid request is given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.search(wrongUrlRequest)
      whenReady(f.failed) { s => s shouldBe a [MalformedURLException]}
    }

    "raise an exception when null value is provided as a domain" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.search(nullUrlRequest)
      whenReady(f.failed) { s => s shouldBe a [IllegalArgumentException]}
    }

    "provide a correct mapped result when valid request is given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.search(correctRequest)
      whenReady(f) { s => s shouldBe a [MappedApiSearchResult]}
    }

    "provide a correct mapped result when valid multiple tag request is given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.search(multipleTagsRequest)
      whenReady(f) { s => s shouldBe a [MappedApiSearchResult]}
    }

    "provide a correct mapped result when no tags are given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.search(noTagsRequest)
      whenReady(f) { s => s shouldBe a [MappedApiSearchResult]}
    }

    "provide a non-empty result when one tag is given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.search(correctRequest)
      whenReady(f) { s => s("results") should not be empty}
    }

    "provide a non-empty result when more tags are given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.search(multipleTagsRequest)
      whenReady(f) { s => s("results") should not be empty}
    }

    "provide an empty result when no tags are given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.search(noTagsRequest)
      whenReady(f) { s => s("results") shouldBe empty}
    }

    "provide an exact result when one tag is given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.search(correctRequest)
      val result: ApiSearchResult = ApiSearchResult(
        "https://www.polsatnews.pl/wiadomosc/2019-12-06/uber-ujawnia-dane-dotyczace-napasci-seksualnych-podczas-przejazdow/",
        "Uber ujawnia, do ilu napaści seksualnych dochodzi podczas przejazdów",
        "Łącznie 5981 napaści na tle seksualnym podczas przejazdów Uberem zaraportowano w Stanach Zjednoczonych w 2017 i 2018 roku. Przewoźnik opublikował obszerny raport dotyczący bezpieczeństwa, który podsumowuje zgłoszenia wszystkich użytkowników platformy - pasażerów i kierowców.",
        List("https://r.dcs.redcdn.pl/http/o2/redefine/cp/bg/bgg4csjtvnfotnau6ypxk9je29upc52q.jpg", "https://r.dcs.redcdn.pl/http/o2/redefine/cp/k8/k87opn6efmx1c16n5hb6134mmrvs85ea.jpg"),
        "https://www.polsatnews.pl",
        "Fri Dec 06 22:47:00 CET 2019"
      )
      whenReady(f) {s => s("results") should contain (result)}
    }

    "provide an exact result when multiple tags are given" in {
      val f: Future[MappedApiSearchResult] = atomAndRssService.search(multipleTagsRequest)
      val result: ApiSearchResult = ApiSearchResult(
        "https://eurosport.tvn24.pl/pilka-nozna,105/gala-pzpn-reprezentacja-100-lecia-wyniki,991294.html",
        "Poznaliśmy Reprezentację 100-lecia PZPN",
        "Na ten moment czekała cała piłkarska Polska. Na piątkowej gali Polskiego Związku Piłki Nożnej ogłoszona została Reprezentacja 100-lecia. Przedstawiamy wyniki plebiscytu PZPN.",
        List("https://s7-tvn24.cdntvn.pl/img/sport/apple-touch-icon-144x144.png?v=cc35b9edcfacb5c6232a1dc28e99d8dd"),
        "https://eurosport.tvn24.pl",
        "Fri Dec 06 22:19:30 CET 2019")
      whenReady(f) {s => s("results") should contain (result)}
    }


  }



}
