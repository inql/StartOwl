module SiteItems.ShoppingQueries exposing (..)

import Api.ApiConnection exposing (..)
import Bootstrap.Accordion as Accordion
import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Carousel as Carousel exposing (defaultStateOptions)
import Bootstrap.Carousel.Slide as Slide
import Bootstrap.Text as Text
import Helpers exposing (errorToString)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import IconManager as Icons
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
    , editMode : Bool
    }


type Msg
    = CarouselMsg Carousel.Msg
    | LoadItems
    | GotResult (Result Http.Error (List QueryResult))
    | AccordionMsg Accordion.State
    | RemoveItem


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
                False
    in
    ( myModel
    , loadResults myModel
    )


noResultsQuery : QueryResult
noResultsQuery =
    QueryResult "No results!" "" 0 ""


subscriptions : ShoppingQuery -> Sub Msg
subscriptions model =
    Sub.batch
        [ Carousel.subscriptions model.carouselState CarouselMsg
        , Accordion.subscriptions model.accordionState AccordionMsg
        ]


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

        RemoveItem ->
            ( { model | id = -1 }, Cmd.none )


updateEditModeSq : Bool -> ShoppingQuery -> ShoppingQuery
updateEditModeSq value model =
    { model | editMode = value }


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


getTitle : ShoppingQuery -> String
getTitle model =
    String.join " " model.tags


view : ShoppingQuery -> Html Msg
view model =
    Accordion.config AccordionMsg
        |> Accordion.withAnimation
        |> Accordion.cards
            [ Accordion.card
                { id = "card1"
                , options = []
                , header =
                    Accordion.header [] <|
                        Accordion.toggle [ class "accordion-custom" ]
                            [ text (getTitle model)
                            , case model.editMode of
                                True ->
                                    Button.button [ Button.danger, Button.small, Button.attrs [ onClick RemoveItem, class "delete_button" ] ] [ Icons.deleteIcon ]

                                False ->
                                    div [] []
                            ]
                , blocks =
                    [ Accordion.block []
                        [ Block.custom <|
                            (Carousel.config CarouselMsg []
                                |> Carousel.withControls
                                |> Carousel.withIndicators
                                |> (Carousel.slides <|
                                        (model.results |> List.map (\x -> displayRecord x))
                                   )
                                |> Carousel.view model.carouselState
                            )
                        , Block.text [] [ text ("W zakresie " ++ (String.fromInt model.priceMin ++ " - " ++ String.fromInt model.priceMax) ++ " zł") ]
                        ]
                    ]
                }
            ]
        |> Accordion.view model.accordionState


displayRecord : QueryResult -> Slide.Config Msg
displayRecord result =
    case result.img of
        "" ->
            Slide.config []
                (Slide.customContent
                    (Card.config
                        [ Card.align Text.alignSmCenter ]
                        |> Card.block [ Block.align Text.alignSmCenter ]
                            [ Block.titleH5 [ style "color" "black" ] [ text "No results :(" ]
                            , Block.text [] [ Button.button [ Button.dark, Button.attrs [ onClick LoadItems ] ] [ text "Load" ] ]
                            ]
                        |> Card.view
                    )
                )

        _ ->
            Slide.config []
                (Slide.customContent
                    (Card.config
                        [ Card.align Text.alignSmCenter
                        ]
                        |> Card.imgTop [ src result.img, class "center", style "max-height" "400px" ]
                            []
                        |> Card.block [ Block.align Text.alignSmCenter ]
                            [ Block.titleH5 [ style "color" "black" ] [ text result.name, setSlideClickable result.link ]
                            , Block.text [ style "color" "gray" ] [ text (Helpers.floatToMoney result.price) ]
                            ]
                        |> Card.view
                    )
                )



--


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
