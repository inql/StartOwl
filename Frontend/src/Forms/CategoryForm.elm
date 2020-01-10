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
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events as Ev exposing (onClick, onInput)
import MultiInput
import Regex exposing (Regex)


inputId =
    "tags-input"


type alias Tags =
    List String


type alias Model =
    { title : String
    , tags : Tags
    , currentTag : String
    , state : MultiInput.State
    }


type Msg
    = UpdateTitle String
    | SubmitForm
    | MultiInputMsg MultiInput.Msg


init : ( Model, Cmd Msg )
init =
    ( Model "" [] "" (MultiInput.init inputId), Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ MultiInput.subscriptions model.state
            |> Sub.map MultiInputMsg
        ]


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Model )
update msg model =
    case msg of
        UpdateTitle newTitle ->
            ( { model | title = newTitle }, Cmd.none, Nothing )

        SubmitForm ->
            case validateForm model of
                True ->
                    ( { model | title = "", tags = [] }, Cmd.none, Just model )

                _ ->
                    ( model, Cmd.none, Nothing )

        MultiInputMsg m ->
            let
                ( newModel, cmds ) =
                    updateTags m { separators = defaultSeparators } model MultiInputMsg
            in
            ( newModel, cmds, Nothing )


updateTags : MultiInput.Msg -> MultiInput.UpdateConfig -> Model -> (MultiInput.Msg -> Msg) -> ( Model, Cmd Msg )
updateTags msg updateConf model toOuterMsg =
    let
        ( nextState, nextItems, nextCmd ) =
            MultiInput.update updateConf msg model.state model.tags
    in
    ( { model | tags = nextItems |> List.filter validateTag, state = nextState }, Cmd.map toOuterMsg nextCmd )


view : Model -> Html Msg
view model =
    displayForm model


displayForm : Model -> Html Msg
displayForm model =
    div []
        [ input [ placeholder "title", value model.title, onInput UpdateTitle ] []
        , br [] []
        , viewTags model
        , br [] []
        , Button.button
            [ Button.primary, Button.attrs [ onClick SubmitForm ] ]
            [ text "Submit" ]
        ]


viewTags : Model -> Html Msg
viewTags model =
    div []
        [ h2 [] [ Html.text "Tags" ]
        , MultiInput.view
            { placeholder = "Add tags"
            , toOuterMsg = MultiInputMsg
            , isValid = validateTag
            }
            []
            model.tags
            model.state
        , br [] []
        ]


validateTag : String -> Bool
validateTag value =
    --(value |> matches "^[a-z0-9]+(?:-[a-z0-9]+)*$") && ((value |> String.length) < 30)
    True


validateForm : Model -> Bool
validateForm model =
    (model.title |> String.isEmpty |> not) && (model.tags |> List.isEmpty |> not)



-- MULTIINPUT
