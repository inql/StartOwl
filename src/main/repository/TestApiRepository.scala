package main.repository

import javax.inject.{Inject, Singleton}
import main.model.{SearchResult, TestSearchResult}

import scala.concurrent.{ExecutionContext, Future}


trait TestApiRepository {

  def all(): Future[Seq[TestSearchResult]]
  def byId(id: Long): Future[TestSearchResult]
  def byName(name: String): Future[Seq[TestSearchResult]]
}

object TestApiRepository {
  final case class TestApiNotFound(id: String) extends Exception("")
}
@Singleton
class InMemoryTestApiRepository@Inject() extends TestApiRepository {
  val initialRecords = Seq(
    TestSearchResult(1,"www.wp.pl","Tytuł 1","Opis 1"),
    TestSearchResult(2,"www.wp.pl","Tytuł 2","Opis 1"),
    TestSearchResult(3,"www.wp.pl","Tytuł 1","Opis 1"),
    TestSearchResult(4,"www.wp.pl","Tytuł 1","Opis 1"),
    TestSearchResult(5,"www.wp.pl","Tytuł 1","Opis 1"),
    TestSearchResult(6,"www.wp.pl","Tytuł 1","Opis 1"),
    TestSearchResult(7,"www.wp.pl","Tytuł 1","Opis 1"),
    TestSearchResult(8,"www.wp.pl","Tytuł 1","Opis 1"),
    TestSearchResult(9,"www.wp.pl","Tytuł 1","Opis 1"),
    TestSearchResult(10,"www.wp.pl","Tytuł 1","Opis 1"),
    TestSearchResult(11,"www.wp.pl","Tytuł 1","Opis 1"),
    TestSearchResult(12,"www.wp.pl","Tytuł 1","Opis 1"),
    TestSearchResult(13,"www.wp.pl","Tytuł 1","Opis 1")
  )
  private var testRecords = initialRecords.toVector

  override def all(): Future[Seq[TestSearchResult]] = Future.successful(testRecords)

  override def byId(id: Long): Future[TestSearchResult] = Future.successful(testRecords.filter(_.id==id)(0))

  override def byName(name: String): Future[Seq[TestSearchResult]] = Future.successful(testRecords.filter(_.title.equals(name)))
}
