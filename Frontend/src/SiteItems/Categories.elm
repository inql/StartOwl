module SiteItems.Categories exposing (..)

import Api.ApiConnection exposing (..)
import Bootstrap.Accordion as Accordion
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
import Html.Attributes exposing (class, href, src, style)
import Html.Events exposing (onClick)
import Http
import IconManager as Icons
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
    , urls : List String
    , accordionState : Accordion.State
    }


recordsInRow =
    2


idToStr : Int -> String
idToStr id =
    id |> String.fromInt


sampleCategory : Int -> Category
sampleCategory id =
    Category id "Sample name" [] [] Good [] (getOpenAccordion id)


getOpenAccordion : Int -> Accordion.State
getOpenAccordion id =
    Accordion.initialStateCardOpen (idToStr id)


type alias Model =
    Category


type Msg
    = LoadMoreRecords
    | GotResult (Result Http.Error (List Record))
    | RemoveCategory
    | UpdateUrls (List String)
    | AccordionMsg Accordion.State


init : Int -> ( Category, Cmd Msg )
init i =
    ( sampleCategory i, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Accordion.subscriptions model.accordionState AccordionMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadMoreRecords ->
            ( { model | status = Loading }, loadResults model.urls model )

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

        UpdateUrls newUrls ->
            ( { model | urls = newUrls }, Cmd.none )

        AccordionMsg state ->
            ( { model | accordionState = state }, Cmd.none )


loadResults : List String -> Model -> Cmd Msg
loadResults urls model =
    Http.post
        { url = api_url
        , body = Http.jsonBody (preparePostJsonForCategory model.tags (addPrefixToUrl urls))
        , expect = Http.expectJson GotResult recordsDecoder
        }


addPrefixToUrl : List String -> List String
addPrefixToUrl urls =
    urls |> List.map (\x -> "http://" ++ x)


view : Model -> Html Msg
view model =
    displayCategory model


displayCategory : Category -> Html Msg
displayCategory category =
    Accordion.config AccordionMsg
        |> Accordion.withAnimation
        |> Accordion.cards
            [ Accordion.card
                { id = category.id |> idToStr
                , options = []
                , header =
                    Accordion.header [] <|
                        Accordion.toggle []
                            [ text category.name
                            , Button.button [ Button.danger, Button.small, Button.attrs [ onClick RemoveCategory, class "delete_button" ] ] [ Icons.deleteIcon ]
                            ]
                , blocks =
                    [ Accordion.block []
                        [ category.tags |> List.map (\x -> Badge.pillInfo [ Spacing.ml1 ] [ text x ]) |> Block.titleH2 []
                        , Block.custom <| (category.records |> split recordsInRow |> List.map (\x -> Card.deck (listOfRecords x)) |> div [])
                        , Block.link []
                            [ text (statusToString category.status)
                            , br [] []
                            , Button.button
                                [ Button.primary, Button.attrs [ onClick LoadMoreRecords ] ]
                                [ text "Load more" ]
                            ]
                        ]
                    ]
                }
            ]
        |> Accordion.view category.accordionState


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
    Card.config [ Card.outlineSecondary ]
        |> Card.imgTop
            [ src record.img ]
            []
        |> Card.header [ class "text-align" ]
            [ text record.title
            , setCardClickable record.url
            ]
        |> Card.block []
            [ Block.text [] [ text record.description ]
            ]


setCardClickable : String -> Html Msg
setCardClickable url =
    a
        [ style "position" "absolute"
        , style "top" "0"
        , style "left" "0"
        , style "height" "100%"
        , style "width" "100%"
        , href url
        , Html.Attributes.target "_blank"
        , Html.Attributes.rel "noopener noreferrer"
        ]
        []


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
