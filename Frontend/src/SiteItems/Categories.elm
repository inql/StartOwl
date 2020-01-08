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
import Html.Attributes exposing (class, href, src)
import Html.Events exposing (onClick)
import Http
import Json.Encode as E
import SiteItems.Record exposing (..)


type Status
    = Loading
    | Error Http.Error
    | Good
    | NoMoreResults
    | Delete


type alias Category =
    { id : Int
    , name : String
    , tags : List String
    , records : List Record
    , status : Status
    }


recordsInRow =
    2


sampleCategory : Int -> Category
sampleCategory id =
    Category id "Sample name" [] [] Good


type alias Model =
    Category


type Msg
    = LoadMoreRecords
    | GotResult (Result Http.Error (List Record))
    | RemoveCategory


init : Int -> ( Category, Cmd Msg )
init i =
    ( sampleCategory i, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadMoreRecords ->
            ( { model | status = Loading }, loadResults model )

        GotResult result ->
            case result of
                Ok r ->
                    case List.length r == List.length model.records of
                        True ->
                            ( { model | status = NoMoreResults }, Cmd.none )

                        _ ->
                            ( { model | records = model.records ++ List.take recordsInRow (List.drop (List.length model.records) r), status = Good }, Cmd.none )

                Err err ->
                    ( { model | status = Error err }, Cmd.none )

        RemoveCategory ->
            ( { model | status = Delete }, Cmd.none )


loadResults : Model -> Cmd Msg
loadResults model =
    Http.post
        { url = api_url
        , body = Http.jsonBody (preparePostJsonForCategory model.tags)
        , expect = Http.expectJson GotResult recordsDecoder
        }


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
            , Block.custom <| (category.records |> split recordsInRow |> List.map (\x -> Card.deck (listOfRecords x)) |> div [])
            ]
        |> Card.footer []
            [ text (statusToString category.status)
            , br [] []
            , Button.button
                [ Button.primary, Button.attrs [ onClick LoadMoreRecords ] ]
                [ text "Load more" ]
            , Button.button [ Button.warning, Button.attrs [ onClick RemoveCategory ] ] [ text "Delete" ]
            ]
        |> Card.view


split : Int -> List Record -> List (List Record)
split i list =
    case List.take i list of
        [] ->
            []

        listHead ->
            listHead :: split i (List.drop i list)


listOfRecords : List Record -> List (Card.Config Msg)
listOfRecords records =
    records |> List.map (\x -> displayRecord x)


displayRecord : Record -> Card.Config Msg
displayRecord record =
    Card.config [ Card.outlineSecondary, Card.align Text.alignXsCenter ]
        |> Card.header [ class "text-align" ]
            [ text record.title
            ]
        |> Card.imgTop
            [ src
                (case List.head record.img of
                    Just i ->
                        i

                    Nothing ->
                        ""
                )
            ]
            []
        |> Card.block []
            [ Block.text [] [ text record.description ]
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

        NoMoreResults ->
            "No new results"

        Delete ->
            "Removing ..."


encodeCategory : Category -> E.Value
encodeCategory category =
    E.object
        [ ( "id", E.int category.id )
        , ( "title", E.string category.name )
        , ( "tags", E.list E.string category.tags )
        ]
