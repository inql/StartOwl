module SiteItems.ShoppingQueries exposing (..)

import Bootstrap.Carousel as Carousel exposing (defaultStateOptions)
import Bootstrap.Carousel.Slide as Slide
import Html exposing (..)
import Json.Encode as E


type alias QueryResult =
    { img : String
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
    }


type Msg
    = CarouselMsg Carousel.Msg


init : Int -> Int -> Int -> List String -> ( ShoppingQuery, Cmd Msg )
init id pMin pMax tags =
    ( ShoppingQuery id
        pMin
        pMax
        tags
        "DESCRIPTION"
        [ QueryResult "none" 3.14 "none", QueryResult "Exmaple" 3.14 "Example" ]
        (Carousel.initialStateWithOptions
            { defaultStateOptions
                | interval = Just 2000
                , pauseOnHover = False
            }
        )
    , Cmd.none
    )


subscriptions : ShoppingQuery -> Sub Msg
subscriptions model =
    Carousel.subscriptions model.carouselState CarouselMsg


update : Msg -> ShoppingQuery -> ( ShoppingQuery, Cmd Msg )
update msg model =
    case msg of
        CarouselMsg subMsg ->
            ( { model | carouselState = Carousel.update subMsg model.carouselState }, Cmd.none )


view : ShoppingQuery -> Html Msg
view model =
    div []
        [ text (String.fromInt model.priceMin ++ " - " ++ String.fromInt model.priceMax)
        , Carousel.config CarouselMsg []
            |> Carousel.withControls
            |> Carousel.withIndicators
            |> (Carousel.slides <|
                    (model.results |> List.map (\x -> displayRecord x))
               )
            |> Carousel.view model.carouselState
        ]


displayRecord : QueryResult -> Slide.Config msg
displayRecord result =
    Slide.config []
        (Slide.customContent
            (div []
                [ text result.link
                ]
            )
        )


encodeShoppingQuery : ShoppingQuery -> E.Value
encodeShoppingQuery model =
    E.object
        [ ( "id", E.int model.id )
        , ( "priceMin", E.int model.priceMin )
        , ( "priceMax", E.int model.priceMax )
        , ( "tags", E.list E.string model.tags )
        ]
