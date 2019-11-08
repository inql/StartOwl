package com.startowl.repository

import com.startowl.model.SearchRequest

import scala.concurrent.{ExecutionContext, Future}

trait SearchRequestRepository {
  def all(): Future[Seq[SearchRequest]]
  def byDomain(domain: String): Future[Seq[SearchRequest]]
  def byKeyword(keyword: String): Future[Seq[SearchRequest]]
}
//todo: implement json repository implementation - this one is just for simplicity
class InMemorySearchRequestRepository(initialRequests: Seq[SearchRequest] = Seq.empty)(implicit ec: ExecutionContext) extends SearchRequestRepository {

  private var requests: Vector[SearchRequest] = initialRequests.toVector

  override def all(): Future[Seq[SearchRequest]] = Future.successful(requests)

  override def byDomain(domain: String): Future[Seq[SearchRequest]] = Future.successful(requests.filter(_.domain.equals(domain)))

  override def byKeyword(keyword: String): Future[Seq[SearchRequest]] = Future.successful(requests.filter(_.keyword.equals(keyword)))
}
