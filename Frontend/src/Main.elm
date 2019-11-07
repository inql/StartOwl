module Main exposing (..)

import Types exposing (..)


import Browser
import Html exposing (Html, button, div, text, h1,br)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class, href)


import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Text as Text
import Bootstrap.General.HAlign as HAlign
import Bootstrap.Utilities.Spacing as Spacing
import Bootstrap.Button as Button
import Bootstrap.Badge as Badge 

type alias Model = {
    name : String,
    items : List Item
    }


main =
  Browser.sandbox 
  { 
    init = init, 
    update = update, 
    view = view 
  }

init : Model
init = Model "Dave" (List.repeat 2 sampleItem) 


type Msg = 
    AddItem Item 
update : Msg -> Model -> Model
update msg model =
  case msg of
    AddItem item -> {model | items = item :: model.items}


view : Model -> Html Msg
view model =
  div [class "text-center"]
    [ CDN.stylesheet 
    , div [] [ 
      h1 [] [ text ("Hello") 
      , Badge.badgeSuccess [Spacing.ml1] [text model.name] ]
      ]
    , displayItems model.items
    , addOthers
    ]


displayItems : List Item -> Html Msg
displayItems items =
  items |> List.map (\x -> Grid.row [] [ Grid.col [] [ displayItem x, br [][] ]]   ) |> Grid.container []  

displayItem : Item -> Html Msg
displayItem item =
  case item of 
  Section category -> displayCategory category
  CustomClock clock -> displayClock clock

-- TO DO
displayClock : Clock -> Html Msg
displayClock clock =
  div [] [ text "Here will be clock"]

displayCategory : Category -> Html Msg
displayCategory category =
  Card.config [ Card.outlinePrimary, Card.align Text.alignXsCenter , Card.attrs [ Spacing.mb3 ]]
  |> Card.headerH2 [class "text-center"] [
    text category.name
  ]
  |> Card.block [] [
    category.tags |> List.map (\x -> Badge.pillInfo [Spacing.ml1] [text x]) |> Block.titleH2 [] 
    
    ,Block.custom <| (Card.columns (listOfRecords category.records))
  ]
  |> Card.footer [] [
    text "Updated"
  ]
  |> Card.view


listOfRecords : List Record -> List (Card.Config Msg)
listOfRecords records =
  records |> List.map (\x -> displayRecord x)


displayRecord : Record -> Card.Config Msg 
displayRecord record =
  Card.config [Card.outlineSecondary, Card.align Text.alignXsCenter]
  |> Card.header [class "text-align"] [
    text record.title
  ]
  |> Card.block [] [
    Block.text [] [ text record.url ]
    , Block.link [ href record.url] [text record.url]
  ]


addOthers : Html Msg 
addOthers =
  Button.button [ Button.primary, Button.attrs [ Spacing.ml1 , onClick (AddItem sampleItem)]] [text "Add other"]
