module SiteItems.ShoppingQueries exposing (..)

import Bootstrap.Carousel as Carousel
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
    , results : List QueryResult
    , carouselState : Carousel.State
    }


type Msg
    = CarouselMsg Carousel.Msg


init : Int -> Int -> Int -> List String -> ( ShoppingQuery, Cmd Msg )
init id pMin pMax tags =
    ( ShoppingQuery id pMin pMax tags [] Carousel.initialState, Cmd.none )


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
    Carousel.config CarouselMsg []
        |> Carousel.withControls
        |> (Carousel.slides <|
                (model.results |> List.map (\x -> displayRecord x))
           )
        |> Carousel.view model.carouselState


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
