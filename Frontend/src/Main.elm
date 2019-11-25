module Main exposing (..)

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
import Json.Decode exposing (Decoder, field, map2, map3, string)
import SiteItems.Items exposing (..)
import Task
import Time


type alias Model =
    { name : String
    , items : SiteItems.Items.Model
    }


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "Dave" SiteItems.Items.init
    , Cmd.none
    )


type Msg
    = UpdateItems SiteItems.Items.Msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map UpdateItems (SiteItems.Items.subscriptions model.items)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateItems m ->
            let
                ( updatedItems, givenCoomand ) =
                    SiteItems.Items.update m model.items
            in
            ( { model | items = updatedItems }, Cmd.map UpdateItems givenCoomand )


view : Model -> Html Msg
view model =
    div [ class "text-center" ]
        [ CDN.stylesheet
        , div []
            [ h1 []
                [ text "Hello"
                , Badge.badgeSuccess [ Spacing.ml1 ] [ text model.name ]
                ]
            ]
        , Html.map UpdateItems (SiteItems.Items.view model.items)
        , addOthers
        , addFooter
        ]


addOthers : Html Msg
addOthers =
    div []
        []


addFooter : Html Msg
addFooter =
    div []
        [ br [] []
        , br [] []
        ]
