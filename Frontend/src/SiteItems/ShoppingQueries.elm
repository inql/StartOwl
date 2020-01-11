module SiteItems.ShoppingQueries exposing (..)

import Api.ApiConnection exposing (..)
import Bootstrap.Accordion as Accordion
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Carousel as Carousel exposing (defaultStateOptions)
import Bootstrap.Carousel.Slide as Slide
import Helpers exposing (errorToString)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as D
import Json.Encode as E


type alias QueryResult =
    { name : String
    , img : String
    , price : Float
    , link : String
    }


type alias ShoppingQuery =
    { id : Int
    , priceMin : Int
    , priceMax : Int
    , tags : List String
    , searchMode : String
    , results : List QueryResult
    , carouselState : Carousel.State
    , accordionState : Accordion.State
    }


type Msg
    = CarouselMsg Carousel.Msg
    | LoadItems
    | GotResult (Result Http.Error (List QueryResult))
    | AccordionMsg Accordion.State


init : Int -> Int -> Int -> List String -> ( ShoppingQuery, Cmd Msg )
init id pMin pMax tags =
    let
        myModel =
            ShoppingQuery
                id
                pMin
                pMax
                tags
                "DESCRIPTION"
                [ noResultsQuery ]
                Carousel.initialState
                (Accordion.initialStateCardOpen "card1")
    in
    ( myModel
    , Cmd.none
    )


noResultsQuery : QueryResult
noResultsQuery =
    QueryResult "No results!" "" 0 ""


subscriptions : ShoppingQuery -> Sub Msg
subscriptions model =
    Carousel.subscriptions model.carouselState CarouselMsg


update : Msg -> ShoppingQuery -> ( ShoppingQuery, Cmd Msg )
update msg model =
    case msg of
        CarouselMsg subMsg ->
            ( { model | carouselState = Carousel.update subMsg model.carouselState }, Cmd.none )

        LoadItems ->
            ( model, loadResults model )

        GotResult result ->
            case result of
                Ok r ->
                    ( { model | results = r, carouselState = Carousel.initialStateWithOptions { defaultStateOptions | interval = Just 2000, pauseOnHover = False } }, Cmd.none )

                Err _ ->
                    ( { model | results = [ noResultsQuery ] }, Cmd.none )

        AccordionMsg state ->
            ( { model | accordionState = state }, Cmd.none )


loadResults : ShoppingQuery -> Cmd Msg
loadResults model =
    Http.post
        { url = query_url
        , body = Http.jsonBody (preparePostJsonForShoppingQuery model.priceMin model.priceMax model.tags)
        , expect = Http.expectJson GotResult queryResultDecoder
        }


queryResultDecoder : D.Decoder (List QueryResult)
queryResultDecoder =
    D.field "results" (D.list decodeRecord)


decodeRecord : D.Decoder QueryResult
decodeRecord =
    D.map4 QueryResult
        (D.field "name" D.string)
        (D.field "imageUri" D.string)
        (D.field "price" D.float)
        (D.field "uri" D.string)


view : ShoppingQuery -> Html Msg
view model =
    Accordion.config AccordionMsg
        |> Accordion.withAnimation
        |> Accordion.cards
            [ Accordion.card
                { id = "card1"
                , options = []
                , header = Accordion.header [] <| Accordion.toggle [] [ text (String.fromInt model.priceMin ++ " - " ++ String.fromInt model.priceMax) ]
                , blocks =
                    [ Accordion.block []
                        [ Block.custom <|
                            (Carousel.config CarouselMsg []
                                |> Carousel.withControls
                                |> (Carousel.slides <|
                                        (model.results |> List.map (\x -> displayRecord x))
                                   )
                                |> Carousel.view model.carouselState
                            )
                        , Block.text [] [ button [ onClick LoadItems ] [ text "Load" ] ]
                        ]
                    ]
                }
            ]
        |> Accordion.view model.accordionState


displayRecord : QueryResult -> Slide.Config msg
displayRecord result =
    Slide.config []
        (Slide.image [ class "center" ] result.img)
        |> Slide.caption []
            [ setSlideClickable result.link
            , h1 [ class "strokeme" ] [ text result.name ]
            , h4 [ class "strokeme", style "color" "gray" ] [ text (String.fromFloat result.price |> String.padRight 2 '0') ]
            ]


encodeShoppingQuery : ShoppingQuery -> E.Value
encodeShoppingQuery model =
    E.object
        [ ( "id", E.int model.id )
        , ( "priceMin", E.int model.priceMin )
        , ( "priceMax", E.int model.priceMax )
        , ( "tags", E.list E.string model.tags )
        ]


setSlideClickable : String -> Html msg
setSlideClickable url =
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
