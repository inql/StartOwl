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
import Forms.CategoryForm
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, field, map2, map3, string)
import Ports exposing (..)
import SiteItems.Items exposing (..)
import Task
import Time


type alias Model =
    { name : String
    , items : SiteItems.Items.Model
    , categoryForm : Forms.CategoryForm.Model
    }


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : ( String, Maybe String ) -> ( Model, Cmd Msg )
init ( name, loadedItems ) =
    let
        ( items, itemsCmd ) =
            case loadedItems of
                Just i ->
                    SiteItems.Items.decodeItems i

                Nothing ->
                    ( [], Cmd.none )

        ( form, formCmd ) =
            Forms.CategoryForm.init
    in
    ( Model name items form
    , Cmd.batch [ Cmd.map UpdateItems itemsCmd, Cmd.map CategoryFormMsg formCmd, storeName "Eve" ]
    )


type Msg
    = UpdateItems SiteItems.Items.Msg
    | CategoryFormMsg Forms.CategoryForm.Msg
    | CreatedNewCategory Item


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map UpdateItems (SiteItems.Items.subscriptions model.items)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateItems m ->
            let
                ( updatedItems, givenCommand ) =
                    SiteItems.Items.update m model.items
            in
            ( { model | items = updatedItems }, Cmd.map UpdateItems givenCommand )

        CategoryFormMsg m ->
            let
                ( updatedForm, givenCommand, possibleNewCommand ) =
                    Forms.CategoryForm.update m model.categoryForm

                newItems =
                    case possibleNewCommand of
                        Just cat ->
                            model.items ++ [ Section cat ]

                        Nothing ->
                            model.items
            in
            ( { model | categoryForm = updatedForm, items = newItems }, Cmd.batch [ Cmd.map CategoryFormMsg givenCommand, storeItems (encodeItems model.items) ] )

        CreatedNewCategory item ->
            ( { model | items = model.items ++ [ item ] }, Cmd.none )


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
        , Html.map CategoryFormMsg (Forms.CategoryForm.view model.categoryForm)
        , addFooter
        ]


addFooter : Html Msg
addFooter =
    div []
        [ br [] []
        , br [] []
        ]



-- PORTS
