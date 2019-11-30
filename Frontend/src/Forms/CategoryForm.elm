module Forms.CategoryForm exposing (..)

import Bootstrap.Badge as Badge
import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.General.HAlign as HAlign
import Bootstrap.Grid as Grid
import Bootstrap.Text as Text
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import SiteItems.Categories exposing (..)


type alias Tags =
    List String


type alias Model =
    { title : String
    , tags : Tags
    , currentTag : String
    }


type Msg
    = UpdateTitle String
    | UpdateTag String
    | AddTag
    | SubmitForm


init : ( Model, Cmd Msg )
init =
    ( Model "" [] "", Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Category )
update msg model =
    case msg of
        UpdateTitle newTitle ->
            ( { model | title = newTitle }, Cmd.none, Nothing )

        AddTag ->
            ( { model | tags = model.tags ++ [ model.currentTag ], currentTag = "" }, Cmd.none, Nothing )

        UpdateTag newTagVal ->
            ( { model | currentTag = newTagVal }, Cmd.none, Nothing )

        SubmitForm ->
            ( { model | title = "", tags = [] }, Cmd.none, Just (createNewCategory model) )


createNewCategory : Model -> Category
createNewCategory model =
    Category (model.title |> String.length) model.title model.tags [] Loading


view : Model -> Html Msg
view model =
    displayForm model


displayForm : Model -> Html Msg
displayForm model =
    div []
        [ input [ placeholder "title", value model.title, onInput UpdateTitle ] []
        , br [] []
        , model.tags |> List.map (\x -> text (x ++ ", ")) |> div []
        , br [] []
        , input [ placeholder "tag value", value model.currentTag, onInput UpdateTag ] []
        , br [] []
        , Button.button
            [ Button.secondary, Button.attrs [ onClick AddTag ] ]
            [ text "Add tag" ]
        , br [] []
        , Button.button
            [ Button.primary, Button.attrs [ onClick SubmitForm ] ]
            [ text "Submit" ]
        ]



-- TO DO VALIDATION
