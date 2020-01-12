module Main exposing (..)

import Bookmarks.BookmarksController exposing (..)
import Bootstrap.Accordion as Accordion
import Bootstrap.Badge as Badge
import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.General.HAlign as HAlign
import Bootstrap.Grid as Grid
import Bootstrap.Modal as Modal
import Bootstrap.Navbar as Navbar
import Bootstrap.Tab as Tab
import Bootstrap.Utilities.Spacing as Spacing
import Browser
import Forms.CategoryForm
import Forms.ClockForm exposing (..)
import Forms.ShoppingQueryForm exposing (..)
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes as Attr exposing (class, href, src, style, value)
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
    , bookmarks : Bookmarks
    , categoryForm : Forms.CategoryForm.Model
    , clockForm : Forms.ClockForm.Model
    , shoppingQueryForm : Forms.ShoppingQueryForm.Model
    , sourceWebsites : List String
    , settingsVisibility : Modal.Visibility
    , tabState : Tab.State
    , urls : List String
    , state : MultiInput.State
    , navbarState : Navbar.State
    , accordionState : Accordion.State
    , editMode : Bool
    }


main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : ( ( String, List String, Maybe String ), ( Maybe String, Maybe String, Maybe String ) ) -> ( Model, Cmd Msg )
init ( ( name, urls, bookmarks ), ( loadedCategories, loadedClocks, loadedQueries ) ) =
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

        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg

        bkmrks =
            case bookmarks of
                Just json ->
                    decodeBookmarks json

                _ ->
                    Bookmarks.BookmarksController.Model []
    in
    ( Model name items bkmrks form clockForm shoppingQueryForm [] Modal.hidden Tab.initialState urls (MultiInput.init "urls-input") navbarState Accordion.initialState False
    , Cmd.batch
        [ Cmd.map UpdateItems categoriesCmd
        , Cmd.map CategoryFormMsg formCmd
        , Cmd.map ClockFormMsg clockFormCmd
        , Cmd.map UpdateItems clockCmd
        , Cmd.map UpdateItems queriesCmd
        , navbarCmd
        ]
    )


type ModalMsg
    = CloseModal
    | ShowModal


type Msg
    = UpdateItems SiteItems.Items.Msg
    | UpdateBookmark Bookmarks.BookmarksController.Msg
    | CategoryFormMsg Forms.CategoryForm.Msg
    | ClockFormMsg Forms.ClockForm.Msg
    | ShoppingQueryFormMsg Forms.ShoppingQueryForm.Msg
    | UpdateName String
    | TabMsg Tab.State
    | MultiInputMsg MultiInput.Msg
    | SettingsMsg ModalMsg
    | AnimateModal Modal.Visibility
    | ToggleEditMode
    | NavbarMsg Navbar.State
    | NewBookmark
    | AccordionMsg Accordion.State


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map UpdateItems (SiteItems.Items.subscriptions model.items)
        , Sub.map ClockFormMsg (Forms.ClockForm.subscriptions model.clockForm)
        , MultiInput.subscriptions model.state
            |> Sub.map MultiInputMsg
        , Modal.subscriptions model.settingsVisibility AnimateModal
        , Navbar.subscriptions model.navbarState NavbarMsg
        , Accordion.subscriptions model.accordionState AccordionMsg
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

        UpdateBookmark m ->
            let
                updatedBookmarks =
                    Bookmarks.BookmarksController.update m model.bookmarks
            in
            ( { model | bookmarks = updatedBookmarks }, storeBookmarks (encodeBookmarks updatedBookmarks) )

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

        ToggleEditMode ->
            let
                toggledEditMode =
                    model.editMode |> not
            in
            ( { model
                | editMode = toggledEditMode
                , items = toggleEditMode toggledEditMode model.items
                , bookmarks = toggleEditForBookmarks toggledEditMode model.bookmarks
              }
            , Cmd.none
            )

        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )

        NewBookmark ->
            ( { model | bookmarks = addNewBookmark model.editMode model.bookmarks }, Cmd.none )

        AccordionMsg state ->
            ( { model | accordionState = state }, Cmd.none )


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


view : Model -> Browser.Document Msg
view model =
    { title = "Start Owl"
    , body =
        [ div []
            [ addNavbar model
            , div [ class "text-center" ]
                [ List.range 1 4
                    |> List.map (\_ -> br [] [])
                    |> div []
                , img [ src "assets/logo.png" ] []
                , div []
                    [ h1 []
                        [ text "Hello"
                        , Badge.badgeDark [ Spacing.ml1 ] [ text model.name ]
                        ]
                    ]
                , br [] []
                , Html.map UpdateItems (SiteItems.Items.view model.items)
                , Grid.container [] [ showForm model ]
                , addFooter
                ]
            ]
        ]
    }


addNavbar : Model -> Html Msg
addNavbar model =
    Navbar.config NavbarMsg
        |> Navbar.withAnimation
        |> Navbar.secondary
        |> Navbar.attrs []
        |> (Navbar.items <|
                ((model.bookmarks |> Bookmarks.BookmarksController.view |> List.map (\x -> Navbar.itemLink [] [ Html.map UpdateBookmark x ]))
                    ++ [ Navbar.itemLink [] [ Button.button [ Button.dark, Button.attrs [ onClick <| NewBookmark ] ] [ text "+" ] ] ]
                )
           )
        |> Navbar.customItems
            [ Navbar.textItem []
                [ Button.button
                    [ Button.dark
                    , Button.small
                    , Button.attrs [ onClick <| ToggleEditMode ]
                    ]
                    [ Icons.editModeIcon ]
                ]
            , Navbar.textItem [] [ showSettings model ]
            ]
        |> Navbar.view model.navbarState


addFooter : Html Msg
addFooter =
    div []
        [ br [] []
        , br [] []
        ]


showForm : Model -> Html Msg
showForm model =
    Accordion.config AccordionMsg
        |> Accordion.withAnimation
        |> Accordion.cards
            [ Accordion.card
                { id = "forms"
                , options = []
                , header =
                    Accordion.header [] <|
                        Accordion.toggle []
                            [ text "Add new Form" ]
                , blocks =
                    [ Accordion.block []
                        [ Block.custom <|
                            (Tab.config TabMsg
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
                            )
                        ]
                    ]
                }
            ]
        |> Accordion.view model.accordionState


showSettings : Model -> Html Msg
showSettings model =
    div []
        [ Button.button
            [ Button.small, Button.dark, Button.attrs [ onClick <| SettingsMsg ShowModal ] ]
            [ Icons.settingsIcon ]
        , Modal.config (SettingsMsg CloseModal)
            |> Modal.withAnimation AnimateModal
            |> Modal.large
            |> Modal.attrs [ style "color" "black" ]
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
