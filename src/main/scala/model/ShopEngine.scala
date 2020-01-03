package model

case class ShopEngine(name: String, domain: String)

object ShopEngine {
  def buildShop(name: String): ShopEngine = name match {
    case "Allegro" => allegro
    case "Amazon" => amazon
    case "Ebay" => ebay
    case _ => allegro
  }


  val allegro = ShopEngine("Allegro", "https://allegro.pl")
  val amazon = ShopEngine("Amazon", "https://amazon.de")
  val ebay = ShopEngine("Ebay", "https://ebay.com")
}