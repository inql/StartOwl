module SiteItems.Items exposing (..)

import Bootstrap.Grid as Grid
import Html exposing (..)
import Json.Decode as D
import Json.Encode as E
import SiteItems.Categories exposing (..)
import SiteItems.Clocks exposing (..)


type Item
    = Section Category
    | CustomClock Clock


sampleItemClock : Item
sampleItemClock =
    CustomClock (Tuple.first (SiteItems.Clocks.init 0))


type Msg
    = CategoryMsg Int SiteItems.Categories.Msg
    | ClockMsg Int SiteItems.Clocks.Msg
    | ClockSubsMsg SiteItems.Clocks.Msg


type alias Model =
    { categories : List Category
    , clocks : List Clock
    }


init : ( Model, Cmd Msg )
init =
    let
        ( sampleItemCategory, catCmd ) =
            SiteItems.Categories.init 1
    in
    ( Model [] [ sampleClock ]
    , Cmd.batch [ Cmd.map (CategoryMsg 1) catCmd ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    model.clocks
        |> List.map (\x -> Sub.map ClockSubsMsg (SiteItems.Clocks.subscriptions x))
        |> Sub.batch


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
              }
            , Cmd.map (CategoryMsg id) cmdMsg
            )

        ClockMsg id message ->
            ( { model
                | clocks =
                    model.clocks
                        |> List.map (\x -> Tuple.first (SiteItems.Clocks.update message x))
              }
            , Cmd.none
            )

        ClockSubsMsg message ->
            ( { model
                | clocks =
                    model.clocks
                        |> List.map (\x -> Tuple.first (SiteItems.Clocks.update message x))
              }
            , Cmd.none
            )


addNewCategory : String -> List String -> Model -> Model
addNewCategory name tags model =
    { model | categories = model.categories ++ [ Category (List.length model.categories + 1) name tags [] Loading ] }


addNewClock : Model -> Model
addNewClock model =
    { model | clocks = model.clocks ++ [ sampleClock ] }


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
            )


view : Model -> Html Msg
view model =
    let
        categoriesWithId =
            model.categories |> List.map (\x -> ( x.id, Section x ))

        clocksWithId =
            model.clocks |> List.map (\x -> ( x.id, CustomClock x ))

        items =
            categoriesWithId ++ clocksWithId |> List.sortBy Tuple.first |> List.map (\x -> Tuple.second x)
    in
    displayItems items


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


encodeCategories : Model -> List E.Value
encodeCategories model =
    model.categories
        |> List.map
            (\x -> encodeCategory x)


encodeClocks : Model -> List E.Value
encodeClocks model =
    model.clocks |> List.map (\x -> encodeClock x)


type alias SimplifiedCategory =
    { id : Int
    , name : String
    , tags : List String
    }


decodeItems : String -> ( Model, Cmd Msg )
decodeItems jsonString =
    case D.decodeString decodeCategories jsonString of
        Ok val ->
            ( Model (val |> List.map (\x -> Category x.id x.name x.tags [] Loading)) [], Cmd.none )

        Err _ ->
            ( Model [] [ sampleClock ], Cmd.none )


decodeCategories : D.Decoder (List SimplifiedCategory)
decodeCategories =
    D.list decodeCat


decodeCat : D.Decoder SimplifiedCategory
decodeCat =
    D.map3 SimplifiedCategory
        (D.field "id" D.int)
        (D.field "title" D.string)
        (D.field "tags" (D.list D.string))
