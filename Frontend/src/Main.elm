module Main exposing (..)

import Bootstrap.Badge as Badge
import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.General.HAlign as HAlign
import Bootstrap.Grid as Grid
import Bootstrap.Popover as Popover
import Bootstrap.Text as Text
import Bootstrap.Utilities.Spacing as Spacing
import Browser
import Forms.CategoryForm
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, href, style, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode exposing (Decoder, field, map2, map3, string)
import Ports exposing (..)
import SiteItems.Categories exposing (Category)
import SiteItems.Items exposing (..)


type alias Model =
    { name : String
    , items : SiteItems.Items.Model
    , categoryForm : Forms.CategoryForm.Model
    , sourceWebsites : List String
    , popoverState : Popover.State
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
                    ( SiteItems.Items.Model [] [], Cmd.none )

        ( form, formCmd ) =
            Forms.CategoryForm.init
    in
    ( Model name items form [] Popover.initialState
    , Cmd.batch [ Cmd.map UpdateItems itemsCmd, Cmd.map CategoryFormMsg formCmd ]
    )


type Msg
    = UpdateItems SiteItems.Items.Msg
    | CategoryFormMsg Forms.CategoryForm.Msg
    | UpdateName String
    | PopoverMsg Popover.State


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

                ( itemsAfterAdding, commandAfterAdd ) =
                    case possibleNewCommand of
                        Just cat ->
                            let
                                newItems =
                                    addNewCategory cat.title cat.tags model.items
                            in
                            ( newItems, storeItems (encodeCategories newItems) )

                        Nothing ->
                            ( model.items, Cmd.none )
            in
            ( { model | categoryForm = updatedForm, items = itemsAfterAdding }, Cmd.batch [ Cmd.map CategoryFormMsg givenCommand, commandAfterAdd ] )

        UpdateName newName ->
            ( { model | name = newName }, storeName newName )

        PopoverMsg state ->
            ( { model | popoverState = state }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "text-center" ]
        [ CDN.stylesheet
        , div []
            [ div
                [ style "position" "absolute"
                , style "right" "0"
                , style "top" "0"
                ]
                [ addPopover model ]
            , h1 []
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


addPopover : Model -> Html Msg
addPopover model =
    Popover.config
        (Button.button
            [ Button.primary
            , Button.large
            , Button.attrs <|
                Popover.onClick model.popoverState PopoverMsg
            ]
            [ text "Settings"
            ]
        )
        |> Popover.left
        |> Popover.content []
            [ showSettings model ]
        |> Popover.view model.popoverState


showSettings : Model -> Html Msg
showSettings model =
    div []
        [ Badge.badgeWarning [] [ input [ value model.name, onInput UpdateName ] [] ]
        ]
