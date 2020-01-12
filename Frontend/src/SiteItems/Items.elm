module SiteItems.Items exposing (..)

import Bootstrap.Accordion as Accordion
import Bootstrap.Grid as Grid
import Helpers exposing (getTimeZoneForName)
import Html exposing (..)
import Json.Decode as D
import Json.Encode as E
import SiteItems.Categories exposing (..)
import SiteItems.Clocks exposing (..)
import SiteItems.ShoppingQueries exposing (..)
import Time exposing (..)


type Item
    = Section Category
    | CustomClock Clock
    | Query ShoppingQuery


type Msg
    = CategoryMsg Int SiteItems.Categories.Msg
    | ClockMsg Int SiteItems.Clocks.Msg
    | ShoppingQueryMsg Int SiteItems.ShoppingQueries.Msg
    | ClockSubsMsg SiteItems.Clocks.Msg
    | UpdateAllUrls (List String)


type alias Model =
    { categories : List Category
    , clocks : List Clock
    , shoppingQueries : List ShoppingQuery
    , shouldUpdate : Bool
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ model.shoppingQueries
            |> List.map (\x -> Sub.map (ShoppingQueryMsg x.id) (SiteItems.ShoppingQueries.subscriptions x))
            |> Sub.batch
        , model.clocks
            |> List.map (\x -> Sub.map ClockSubsMsg (SiteItems.Clocks.subscriptions x))
            |> Sub.batch
        , model.categories
            |> List.map (\x -> Sub.map (CategoryMsg x.id) (SiteItems.Categories.subscriptions x))
            |> Sub.batch
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CategoryMsg id message ->
            let
                searchedMaybeItem =
                    model.categories
                        |> List.filter
                            (\x ->
                                if x.id == id then
                                    True

                                else
                                    False
                            )
                        |> List.head

                searchedItem =
                    case searchedMaybeItem of
                        Just cat ->
                            cat

                        Nothing ->
                            sampleCategory -1

                ( updatedItem, cmdMsg ) =
                    SiteItems.Categories.update message searchedItem

                newShouldUpdate =
                    updatedItem.status == SiteItems.Categories.Delete
            in
            ( { model
                | categories =
                    model.categories
                        |> List.map
                            (\cat ->
                                if cat.id == id then
                                    updatedItem

                                else
                                    cat
                            )
                        |> List.filter (\x -> x.status /= SiteItems.Categories.Delete)
                , shouldUpdate = newShouldUpdate
              }
            , Cmd.map (CategoryMsg id) cmdMsg
            )

        ClockMsg id message ->
            let
                newItems =
                    model.clocks
                        |> List.map
                            (\x ->
                                if x.id == id then
                                    Tuple.first (SiteItems.Clocks.update message x)

                                else
                                    x
                            )

                newShouldUpdate =
                    newItems |> List.any (\x -> x.id < 0)
            in
            ( { model
                | clocks =
                    newItems
                        |> List.filter (\x -> x.id >= 0)
                , shouldUpdate = newShouldUpdate
              }
            , Cmd.none
            )

        ShoppingQueryMsg id message ->
            let
                searchedMaybeItem =
                    model.shoppingQueries
                        |> List.filter
                            (\x ->
                                if x.id == id then
                                    True

                                else
                                    False
                            )
                        |> List.head

                searchedItem =
                    case searchedMaybeItem of
                        Just sq ->
                            sq

                        Nothing ->
                            Tuple.first (SiteItems.ShoppingQueries.init -1 -1 -1 [])

                ( updatedItem, cmdMsg ) =
                    SiteItems.ShoppingQueries.update message searchedItem

                newShouldUpdate =
                    updatedItem.id < 0
            in
            ( { model
                | shoppingQueries =
                    model.shoppingQueries
                        |> List.map
                            (\x ->
                                if x.id == id then
                                    updatedItem

                                else
                                    x
                            )
                        |> List.filter (\x -> x.id >= 0)
                , shouldUpdate = newShouldUpdate
              }
            , Cmd.map (ShoppingQueryMsg updatedItem.id) cmdMsg
            )

        ClockSubsMsg message ->
            ( { model
                | clocks =
                    model.clocks
                        |> List.map (\x -> Tuple.first (SiteItems.Clocks.update message x))
              }
            , Cmd.none
            )

        UpdateAllUrls urls ->
            ( { model
                | categories = model.categories |> List.map (\x -> Tuple.first (SiteItems.Categories.update (UpdateUrls urls) x))
              }
            , Cmd.none
            )


toggleEditMode : Bool -> Model -> Model
toggleEditMode value model =
    { model
        | categories = model.categories |> List.map (updateEditModeCat value)
        , clocks = model.clocks |> List.map (updateEditModeClock value)
        , shoppingQueries = model.shoppingQueries |> List.map (updateEditModeSq value)
    }


getNextId : Model -> Int
getNextId model =
    case getItemListWithId model |> List.reverse |> List.head of
        Just x ->
            Tuple.first x + 1

        Nothing ->
            1


addNewCategory : String -> List String -> List String -> Model -> ( Model, Cmd Msg )
addNewCategory name tags urls model =
    let
        id =
            getNextId model

        ( newCat, newCmd ) =
            SiteItems.Categories.init id name tags urls
    in
    ( { model | categories = model.categories ++ [ newCat ] }, Cmd.map (CategoryMsg id) newCmd )


addNewClock : String -> Time.Zone -> Model -> ( Model, Cmd Msg )
addNewClock name timezone model =
    let
        ( newClock, cmd ) =
            SiteItems.Clocks.init (getNextId model) name timezone
    in
    ( { model | clocks = model.clocks ++ [ newClock ] }, Cmd.map (ClockMsg newClock.id) cmd )


addNewShoppingQuery : Int -> Int -> List String -> Model -> ( Model, Cmd Msg )
addNewShoppingQuery min max tags model =
    let
        id =
            getNextId model

        ( newSQ, cmd ) =
            SiteItems.ShoppingQueries.init id min max tags
    in
    ( { model | shoppingQueries = model.shoppingQueries ++ [ newSQ ] }, Cmd.map (ShoppingQueryMsg id) cmd )


filterCategories : List Item -> List Category
filterCategories items =
    items
        |> List.filterMap
            (\x ->
                case x of
                    Section cat ->
                        Just cat

                    CustomClock c ->
                        Nothing

                    Query s ->
                        Nothing
            )


getItemListWithId : Model -> List ( Int, Item )
getItemListWithId model =
    let
        categoriesWithId =
            model.categories |> List.map (\x -> ( x.id, Section x ))

        clocksWithId =
            model.clocks |> List.map (\x -> ( x.id, CustomClock x ))

        shoppingQueriesWithId =
            model.shoppingQueries |> List.map (\x -> ( x.id, Query x ))
    in
    categoriesWithId ++ clocksWithId ++ shoppingQueriesWithId |> List.sortBy Tuple.first


getItemList : Model -> List Item
getItemList model =
    getItemListWithId model |> List.map (\x -> Tuple.second x)


view : Model -> Html Msg
view model =
    displayItems (getItemList model)


displayItems : List Item -> Html Msg
displayItems items =
    items |> List.map (\x -> Grid.row [] [ Grid.col [] [ displayItem x, br [] [] ] ]) |> Grid.container []


displayItem : Item -> Html Msg
displayItem item =
    case item of
        Section category ->
            Html.map (CategoryMsg category.id) (SiteItems.Categories.view category)

        CustomClock clock ->
            Html.map (ClockMsg clock.id) (SiteItems.Clocks.view clock)

        Query s ->
            Html.map (ShoppingQueryMsg s.id) (SiteItems.ShoppingQueries.view s)


encodeCategories : Model -> List E.Value
encodeCategories model =
    model.categories |> List.map (\x -> encodeCategory x)


encodeClocks : Model -> List E.Value
encodeClocks model =
    model.clocks |> List.map (\x -> encodeClock x)


encodeShoppingQueries : Model -> List E.Value
encodeShoppingQueries model =
    model.shoppingQueries |> List.map (\x -> encodeShoppingQuery x)


type alias SimplifiedCategory =
    { id : Int
    , name : String
    , tags : List String
    }


type alias SimplifiedClock =
    { id : Int
    , title : String
    }


type alias SimplifiedQuery =
    { id : Int
    , priceMin : Int
    , priceMax : Int
    , tags : List String
    }


decodeCategories : String -> List String -> ( Model, Cmd Msg )
decodeCategories jsonString urls =
    case D.decodeString (D.list decodeCat) jsonString of
        Ok val ->
            let
                tmp =
                    val |> List.map (\x -> SiteItems.Categories.init x.id x.name x.tags urls)

                cats =
                    tmp |> List.map (\x -> Tuple.first x)

                cmds =
                    tmp |> List.map (\x -> Cmd.map (CategoryMsg (Tuple.first x).id) (Tuple.second x))
            in
            ( Model cats [] [] True, Cmd.batch <| cmds )

        Err _ ->
            ( Model [] [] [] True, Cmd.none )


decodeShoppingQueries : String -> ( Model, Cmd Msg )
decodeShoppingQueries jsonString =
    case D.decodeString (D.list decodeShoppingQuery) jsonString of
        Ok val ->
            let
                queriesWCmd =
                    val |> List.map (\x -> SiteItems.ShoppingQueries.init x.id x.priceMin x.priceMax x.tags)

                queries =
                    queriesWCmd |> List.map (\x -> Tuple.first x)

                cmds =
                    queriesWCmd |> List.map (\x -> Cmd.map (ShoppingQueryMsg (Tuple.first x).id) (Tuple.second x))
            in
            ( Model [] [] queries True, Cmd.batch <| cmds )

        Err _ ->
            ( Model [] [] [] True, Cmd.none )


decodeClocks : String -> ( Model, Cmd Msg )
decodeClocks jsonString =
    case D.decodeString (D.list decodeClock) jsonString of
        Ok val ->
            let
                clocksWithCmds =
                    val
                        |> List.map (\x -> SiteItems.Clocks.init x.id x.title (getTimeZoneForName x.title))
                        |> List.map (\( x, y ) -> ( x, Cmd.map (ClockMsg x.id) y ))

                clocks =
                    clocksWithCmds |> List.map (\x -> Tuple.first x)

                cmds =
                    clocksWithCmds |> List.map (\x -> Tuple.second x)
            in
            ( Model [] clocks [] True, Cmd.batch cmds )

        Err _ ->
            ( Model [] [] [] True, Cmd.none )


decodeClock : D.Decoder SimplifiedClock
decodeClock =
    D.map2 SimplifiedClock
        (D.field "id" D.int)
        (D.field "title" D.string)


decodeCat : D.Decoder SimplifiedCategory
decodeCat =
    D.map3 SimplifiedCategory
        (D.field "id" D.int)
        (D.field "title" D.string)
        (D.field "tags" (D.list D.string))


decodeShoppingQuery : D.Decoder SimplifiedQuery
decodeShoppingQuery =
    D.map4 SimplifiedQuery
        (D.field "id" D.int)
        (D.field "priceMin" D.int)
        (D.field "priceMax" D.int)
        (D.field "tags" (D.list D.string))
