package model

case class ShopSearchRequest(keyword: String, shopEngineInput: String){
  val shopEngine = ShopEngine.buildShop(shopEngineInput)
}
