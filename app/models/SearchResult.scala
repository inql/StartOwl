package models

import net.ruippeixotog.scalascraper.browser.JsoupBrowser.JsoupElement

class SearchResult(source: String, keyword: String, var result: List[JsoupElement])
{
  type Hyperlink = String
  type Description = String

  val generatedModel: List[(Hyperlink, Description)] = extractResultToModel(result)

  private def extractResultToModel(result: List[JsoupElement]): List[(Hyperlink, Description)] ={
    for(element <- result) yield (element.attr("href"),element.text)
  }
}
