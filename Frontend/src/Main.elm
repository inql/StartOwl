module Main exposing (..)

import Bootstrap.Badge as Badge
import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.General.HAlign as HAlign
import Bootstrap.Grid as Grid
import Bootstrap.Modal as Modal
import Bootstrap.Tab as Tab
import Bootstrap.Utilities.Spacing as Spacing
import Browser
import Forms.CategoryForm
import Forms.ClockForm exposing (..)
import Forms.ShoppingQueryForm exposing (..)
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes as Attr exposing (class, href, style, value)
import Html.Events as Ev exposing (onClick, onInput)
import IconManager as Icons
import Json.Decode exposing (Decoder, field, map2, map3, string)
import MultiInput
import Ports exposing (..)
import Regex exposing (Regex)
import SiteItems.Categories exposing (Category)
import SiteItems.Items exposing (..)


type alias Model =
    { name : String
    , items : SiteItems.Items.Model
    , categoryForm : Forms.CategoryForm.Model
    , clockForm : Forms.ClockForm.Model
    , shoppingQueryForm : Forms.ShoppingQueryForm.Model
    , sourceWebsites : List String
    , settingsVisibility : Modal.Visibility
    , tabState : Tab.State
    , urls : List String
    , state : MultiInput.State
    }


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : ( ( String, List String ), ( Maybe String, Maybe String, Maybe String ) ) -> ( Model, Cmd Msg )
init ( ( name, urls ), ( loadedCategories, loadedClocks, loadedQueries ) ) =
    let
        ( categories, categoriesCmd ) =
            case loadedCategories of
                Just i ->
                    SiteItems.Items.decodeCategories i

                Nothing ->
                    ( SiteItems.Items.Model [] [] [], Cmd.none )

        ( clocks, clockCmd ) =
            case loadedClocks of
                Just i ->
                    SiteItems.Items.decodeClocks i

                Nothing ->
                    ( SiteItems.Items.Model [] [] [], Cmd.none )

        ( queries, queriesCmd ) =
            case loadedQueries of
                Just i ->
                    SiteItems.Items.decodeShoppingQueries i

                Nothing ->
                    ( SiteItems.Items.Model [] [] [], Cmd.none )

        ( form, formCmd ) =
            Forms.CategoryForm.init

        ( clockForm, clockFormCmd ) =
            Forms.ClockForm.init

        shoppingQueryForm =
            Forms.ShoppingQueryForm.init

        items =
            SiteItems.Items.Model
                (categories.categories
                    |> List.map (\category -> { category | urls = urls })
                )
                clocks.clocks
                queries.shoppingQueries
    in
    ( Model name items form clockForm shoppingQueryForm [] Modal.hidden Tab.initialState urls (MultiInput.init "urls-input")
    , Cmd.batch
        [ Cmd.map UpdateItems categoriesCmd
        , Cmd.map CategoryFormMsg formCmd
        , Cmd.map ClockFormMsg clockFormCmd
        , Cmd.map UpdateItems clockCmd
        , Cmd.map UpdateItems queriesCmd
        ]
    )


type ModalMsg
    = CloseModal
    | ShowModal


type Msg
    = UpdateItems SiteItems.Items.Msg
    | CategoryFormMsg Forms.CategoryForm.Msg
    | ClockFormMsg Forms.ClockForm.Msg
    | ShoppingQueryFormMsg Forms.ShoppingQueryForm.Msg
    | UpdateName String
    | TabMsg Tab.State
    | MultiInputMsg MultiInput.Msg
    | SettingsMsg ModalMsg
    | AnimateModal Modal.Visibility


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map UpdateItems (SiteItems.Items.subscriptions model.items)
        , Sub.map ClockFormMsg (Forms.ClockForm.subscriptions model.clockForm)
        , MultiInput.subscriptions model.state
            |> Sub.map MultiInputMsg
        , Modal.subscriptions model.settingsVisibility AnimateModal
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateItems m ->
            let
                ( updatedItems, givenCommand ) =
                    SiteItems.Items.update m model.items
            in
            ( { model | items = updatedItems }
            , Cmd.batch
                [ Cmd.map UpdateItems givenCommand
                , storeCategories (encodeCategories updatedItems)
                , storeClocks (encodeClocks updatedItems)
                , storeShoppingQueries (encodeShoppingQueries updatedItems)
                ]
            )

        CategoryFormMsg m ->
            let
                ( updatedForm, givenCommand, possibleNewCommand ) =
                    Forms.CategoryForm.update m model.categoryForm

                ( itemsAfterAdding, commandAfterAdd ) =
                    case possibleNewCommand of
                        Just cat ->
                            let
                                newItems =
                                    addNewCategory cat.title cat.tags model.urls model.items
                            in
                            ( newItems, storeCategories (encodeCategories newItems) )

                        Nothing ->
                            ( model.items, Cmd.none )
            in
            ( { model | categoryForm = updatedForm, items = itemsAfterAdding }, Cmd.batch [ Cmd.map CategoryFormMsg givenCommand, commandAfterAdd ] )

        ClockFormMsg m ->
            let
                ( updatedForm, givenCommand, possibleNewCommand ) =
                    Forms.ClockForm.update m model.clockForm

                ( itemsAfterAdding, commandAfterAdd ) =
                    case possibleNewCommand of
                        Just newClock ->
                            let
                                ( newItems, cmdAfterAdding ) =
                                    addNewClock newClock.name newClock.zone model.items
                            in
                            ( newItems, Cmd.batch [ storeClocks (encodeClocks newItems), Cmd.map UpdateItems cmdAfterAdding ] )

                        Nothing ->
                            ( model.items, Cmd.none )
            in
            ( { model | clockForm = updatedForm, items = itemsAfterAdding }, Cmd.batch [ Cmd.map ClockFormMsg givenCommand, commandAfterAdd ] )

        ShoppingQueryFormMsg m ->
            let
                ( updatedForm, givenCommand, possibleNew ) =
                    Forms.ShoppingQueryForm.update m model.shoppingQueryForm

                ( itemsAfterAdding, commandsAfterAdd ) =
                    case possibleNew of
                        Just newQuery ->
                            let
                                ( newItems, cmdAfterAdding ) =
                                    addNewShoppingQuery newQuery.priceMin newQuery.priceMax newQuery.tags model.items
                            in
                            ( newItems, Cmd.batch [ storeShoppingQueries (encodeShoppingQueries newItems), Cmd.map UpdateItems cmdAfterAdding ] )

                        Nothing ->
                            ( model.items, Cmd.none )
            in
            ( { model | shoppingQueryForm = updatedForm, items = itemsAfterAdding }, Cmd.batch [ commandsAfterAdd ] )

        UpdateName newName ->
            ( { model | name = newName }, storeName newName )

        SettingsMsg modalMsg ->
            case modalMsg of
                ShowModal ->
                    ( { model | settingsVisibility = Modal.shown }, Cmd.none )

                CloseModal ->
                    ( { model | settingsVisibility = Modal.hidden }, Cmd.none )

        AnimateModal visibility ->
            ( { model | settingsVisibility = visibility }, Cmd.none )

        TabMsg state ->
            ( { model | tabState = state }
            , Cmd.none
            )

        MultiInputMsg m ->
            let
                ( newModel, newCmd ) =
                    updateUrls m { separators = defaultSeparators } model MultiInputMsg

                newUrls =
                    newModel.urls |> List.filter (\x -> matches urlsRegex x) |> List.take maxValidWebsites
            in
            ( { newModel | urls = newUrls }, Cmd.batch [ newCmd, storeUrls model.urls ] )


updateUrls : MultiInput.Msg -> MultiInput.UpdateConfig -> Model -> (MultiInput.Msg -> Msg) -> ( Model, Cmd Msg )
updateUrls msg updateConf model toOuterMsg =
    let
        ( nextState, nextUrls, nextCmd ) =
            MultiInput.update updateConf msg model.state model.urls
    in
    ( { model | urls = nextUrls, state = nextState }, Cmd.map toOuterMsg nextCmd )


defaultSeparators : List String
defaultSeparators =
    [ "\n", "\t", " ", "," ]


view : Model -> Html Msg
view model =
    div [ class "text-center" ]
        [ List.range 1 4
            |> List.map (\_ -> br [] [])
            |> div []
        , div []
            [ div
                [ style "position" "absolute"
                , style "right" "0"
                , style "top" "0"
                ]
                [ showSettings model ]
            , h1 []
                [ text "Hello"
                , Badge.badgeDark [ Spacing.ml1 ] [ text model.name ]
                ]
            ]
        , br [] []
        , Html.map UpdateItems (SiteItems.Items.view model.items)
        , showForm model
        , addFooter
        ]


addFooter : Html Msg
addFooter =
    div []
        [ br [] []
        , br [] []
        ]


showForm : Model -> Html Msg
showForm model =
    Grid.container []
        [ Tab.config TabMsg
            |> Tab.pills
            |> Tab.items
                [ Tab.item
                    { id = "tabItem1"
                    , link = Tab.link [] [ text "Add new Category" ]
                    , pane =
                        Tab.pane [ Spacing.mt3 ]
                            [ Html.map CategoryFormMsg (Forms.CategoryForm.view model.categoryForm)
                            ]
                    }
                , Tab.item
                    { id = "tabItem2"
                    , link = Tab.link [] [ text "Add new Clock" ]
                    , pane =
                        Tab.pane [ Spacing.mt3 ]
                            [ Html.map ClockFormMsg (Forms.ClockForm.view model.clockForm)
                            ]
                    }
                , Tab.item
                    { id = "tabItem3"
                    , link = Tab.link [] [ text "Add new shopping query" ]
                    , pane =
                        Tab.pane [ Spacing.mt3 ]
                            [ Html.map ShoppingQueryFormMsg (Forms.ShoppingQueryForm.view model.shoppingQueryForm)
                            ]
                    }
                ]
            |> Tab.view model.tabState
        ]


showSettings : Model -> Html Msg
showSettings model =
    div []
        [ Button.button
            [ Button.outlineSuccess, Button.attrs [ onClick <| SettingsMsg ShowModal ] ]
            [ Icons.settingsIcon ]
        , Modal.config (SettingsMsg CloseModal)
            -- Configure the modal to use animations providing the new AnimateModal msg
            |> Modal.withAnimation AnimateModal
            |> Modal.large
            |> Modal.h1 [] [ text "Settings" ]
            |> Modal.body []
                [ text "Your name "
                , input [ value model.name, onInput UpdateName ] []
                , br [] []
                , showUrls model
                ]
            |> Modal.footer []
                [ Button.button
                    [ Button.outlinePrimary
                    , Button.attrs [ onClick <| AnimateModal Modal.hiddenAnimated ]
                    ]
                    [ text "Close" ]
                ]
            |> Modal.view model.settingsVisibility
        ]


urlsRegex =
    ".+\\..+\\..+"


maxValidWebsites =
    10


showUrls : Model -> Html Msg
showUrls model =
    let
        isValid =
            matches urlsRegex

        validwebsite =
            List.filter isValid model.urls

        nvalidwebsite =
            List.length validwebsite
    in
    Html.div []
        [ Html.h2 [] [ Html.text "Source Websites" ]
        , MultiInput.view
            { placeholder = "Format : www.example.com", toOuterMsg = MultiInputMsg, isValid = isValid }
            []
            model.urls
            model.state
        , Html.p []
            [ Html.text <|
                "You've introduced ("
                    ++ String.fromInt nvalidwebsite
                    ++ "/"
                    ++ String.fromInt maxValidWebsites
                    ++ ") valid websites"
            ]
        ]
