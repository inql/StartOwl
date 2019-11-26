module SiteItems.Categories exposing (..)

import Api.ApiRecords exposing (..)
import Bootstrap.Badge as Badge
import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.General.HAlign as HAlign
import Bootstrap.Grid as Grid
import Bootstrap.Text as Text
import Bootstrap.Utilities.Spacing as Spacing
import Browser
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, field, list, map2, string)
import SiteItems.Record exposing (..)


type Status
    = Loading
    | Error Http.Error
    | Good


type alias Category =
    { id : Int
    , name : String
    , tags : List String
    , records : List Record
    , status : Status
    }


sampleCategory : Category
sampleCategory =
    Category 1 "Sample name" (List.repeat 2 "Tag") (List.repeat 2 sampleRecord) Good


type alias Model =
    Category


type Msg
    = LoadMoreRecords
    | GotResult (Result Http.Error (List Record))


init : Int -> Category
init i =
    sampleCategory


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadMoreRecords ->
            ( { model | status = Loading }, loadResults )

        GotResult result ->
            case result of
                Ok r ->
                    ( { model | records = model.records ++ r, status = Good }, Cmd.none )

                Err err ->
                    ( { model | status = Error err }, Cmd.none )


loadResults : Cmd Msg
loadResults =
    Http.get
        { url = "http://localhost:5016/data.json"
        , expect = Http.expectJson GotResult recordsDecoder
        }


recordsDecoder : Decoder (List Record)
recordsDecoder =
    field "records" (list decodeRecord)


decodeRecord : Decoder Record
decodeRecord =
    map2 Record
        (field "url"
            string
        )
        (field
            "title"
            string
        )


view : Model -> Html Msg
view model =
    displayCategory model


displayCategory : Category -> Html Msg
displayCategory category =
    Card.config [ Card.outlinePrimary, Card.align Text.alignXsCenter, Card.attrs [ Spacing.mb3 ] ]
        |> Card.headerH2 [ class "text-center" ]
            [ text category.name
            ]
        |> Card.block []
            [ category.tags |> List.map (\x -> Badge.pillInfo [ Spacing.ml1 ] [ text x ]) |> Block.titleH2 []
            , Block.custom <| Card.columns (listOfRecords category.records)
            ]
        |> Card.footer []
            [ text (statusToString category.status)
            , br [] []
            , Button.button
                [ Button.primary, Button.attrs [ onClick LoadMoreRecords ] ]
                [ text "Load more" ]
            ]
        |> Card.view


listOfRecords : List Record -> List (Card.Config Msg)
listOfRecords records =
    records |> List.map (\x -> displayRecord x)


displayRecord : Record -> Card.Config Msg
displayRecord record =
    Card.config [ Card.outlineSecondary, Card.align Text.alignXsCenter ]
        |> Card.header [ class "text-align" ]
            [ text record.title
            ]
        |> Card.block []
            [ Block.text [] [ text record.url ]
            , Block.link [ href record.url ] [ text record.url ]
            ]


statusToString : Status -> String
statusToString status =
    case status of
        Loading ->
            "Loading"

        Error err ->
            Helpers.errorToString err

        Good ->
            "Good"
