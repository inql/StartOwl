package main.repository

import javax.inject.{Inject, Singleton}
import main.model.{SearchResult, TestSearchResult}

import scala.concurrent.{ExecutionContext, Future}


trait TestApiRepository {

  def all(): Future[Seq[TestSearchResult]]
  def byTag(tag: String): Future[Seq[TestSearchResult]]
  def byName(name: String): Future[Seq[TestSearchResult]]
}

object TestApiRepository {
  final case class TestApiNotFound(id: String) extends Exception("")
}
@Singleton
class InMemoryTestApiRepository@Inject() extends TestApiRepository {
  val initialRecords = Seq(
    TestSearchResult("sport","www.wp.pl","Tytuł 1","Opis 1"),
    TestSearchResult("polityka","www.fajnastrona.pl","Tytuł 2","Opis 1"),
    TestSearchResult("programowanie","www.onet.pl","Tytuł 1","Opis 1"),
    TestSearchResult("gry","www.mateusz.pl","Tytuł 1","Opis 1"),
    TestSearchResult("sport","www.markzukernber.pl","Tytuł 1","Opis 1"),
    TestSearchResult("test","www.dobrastarczy.pl","xsadasdasd 1","Opis 1"),
    TestSearchResult("jedzenie","www.wp.pl","Tytuł 1","Opis 1"),
    TestSearchResult("jedzenie","www.wp.pl","Tytuł 1","Opis 1"),
    TestSearchResult("jedzenie","www.wp.pl","Tytuł 1","Opis 1"),
    TestSearchResult("sport","www.wp.pl","Tytuł 1","Opis 1"),
    TestSearchResult("gry","www.wp.pl","Tytuł 1","Opis 1"),
    TestSearchResult("programowanie","www.wp.pl","Tytuł 1","Opis 1"),
    TestSearchResult("programowanie","www.wp.pl","Tytuł 1","Opis 1")
  )
  private var testRecords = initialRecords.toVector

  override def all(): Future[Seq[TestSearchResult]] = Future.successful(testRecords)

  override def byTag(tag: String): Future[Seq[TestSearchResult]] = Future.successful(testRecords.filter(_.tag.equals(tag)))

  override def byName(name: String): Future[Seq[TestSearchResult]] = Future.successful(testRecords.filter(_.title.equals(name)))
}
