package models

import models.SearchMode.SearchMode

case class SearchRule(domain: String, searchMode: SearchMode, keywords: String*)
