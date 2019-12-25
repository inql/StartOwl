package service

import net.ruippeixotog.scalascraper.dsl.DSL._
import net.ruippeixotog.scalascraper.dsl.DSL.Extract._
import net.ruippeixotog.scalascraper.dsl.DSL.Parse._
import net.ruippeixotog.scalascraper.model._

object ElementFinderService {

  def getElementsBasedOnFilter(baseElementList: List[Element], condition: Element => Boolean, operation: Element => AnyRef): List[AnyRef] =
    (baseElementList).filter(p => condition(p)).map(p => operation(p))

}
