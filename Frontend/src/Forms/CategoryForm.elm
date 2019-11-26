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
    { items : List String
    }


type alias Model =
    { title : String, tags : Tags }


type Msg
    = UpdateTitle String
    | SubmitForm


init : ( Model, Cmd Msg )
init =
    ( Model "" (Tags [ "music" ]), Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateTitle newTitle ->
            ( { model | title = newTitle }, Cmd.none )

        SubmitForm ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    displayForm model


displayForm : Model -> Html Msg
displayForm model =
    div []
        [ input [ placeholder "title", value model.title, onInput UpdateTitle ] []
        , br [] []
        , text "tagi tagi tagi tagi"
        , br [] []
        , Button.button
            [ Button.primary, Button.attrs [ onClick SubmitForm ] ]
            [ text "Load more" ]
        ]
