module Main exposing (..)

import Types exposing (WebsiteRecord )
import WebsiteRecordForm 

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Card as Card
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col
import Bootstrap.Button as Button
import Bootstrap.Card.Block as Block
import Bootstrap.General.HAlign as HAlign

import Bootstrap.Text as Text

import List.Extra exposing (remove)

main =
  Browser.sandbox { init = init, update = update, view = view }


sampleRecord : WebsiteRecord 
sampleRecord =
    WebsiteRecord  "Google" "A search engine" "https://google.com" 

type alias Model = 
    {
        records : List WebsiteRecord,
        newRecord : WebsiteRecordForm.Model
    }

type Msg = AddLink WebsiteRecord 
    | WebsiteRecordFormMsg WebsiteRecordForm.Msg
    | RemoveLink WebsiteRecord

init : Model
init = Model (List.repeat 2 sampleRecord) (WebsiteRecordForm.init)
        
update : Msg -> Model -> Model
update msg model =
  case msg of
    AddLink record -> {model | records = record :: model.records}
    WebsiteRecordFormMsg form -> { model | newRecord = WebsiteRecordForm.update form model.newRecord}
    RemoveLink whichOne -> {model | records = (remove whichOne model.records)}

view : Model -> Html Msg
view model =
     div [] [ 
        h1 [style "text-align" "center"] [ text "StartOwl"] 
        , br [][]
        , mainContent model
        ]
        
    

   
mainContent : Model -> Html Msg
mainContent model =
    div [] [
        
            Grid.container []
            [ CDN.stylesheet,
                model.records |> List.map (\x -> viewSinglePanel x) |> Grid.row [ Row.centerMd ]
                , br [] []
                , Grid.row [] [
                    Grid.col [] [
                        Html.map WebsiteRecordFormMsg (WebsiteRecordForm.view model.newRecord)
                        , Button.button [Button.primary, Button.attrs [ onClick (AddLink model.newRecord)]] [text "Add"]
                    ]
                ]
            ]
        ]
    

viewSinglePanel : WebsiteRecord  -> Grid.Column Msg
viewSinglePanel record =
    Grid.col [Col.xs4] [
        Card.config [ Card.outlinePrimary, Card.align Text.alignXsCenter ]
        |> Card.header [class "text-center"] [ 
            text record.title
            ]
        |> Card.block [] [
            Block.text [] [ text record.description]
            , Block.link [ href record.url] [text record.url]    
        ]
        |> Card.footer [] [ 
            Button.button [Button.primary, Button.attrs [onClick (RemoveLink record)]] [text "Dismiss"]
            ]
        |> Card.view

    ]
    