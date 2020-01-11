module Forms.ShoppingQueryForm exposing (..)

import Bootstrap.Button as Button
import Helpers exposing (defaultSeparators)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import MultiInput


type alias Model =
    { priceMin : Int
    , priceMax : Int
    , tags : List String
    , state : MultiInput.State
    }


inputId =
    "tags-form"


init : Model
init =
    Model 0 0 [] (MultiInput.init inputId)


type Msg
    = UpdatePriceMin String
    | UpdatePriceMax String
    | SubmitForm
    | MultiInputMsg MultiInput.Msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ MultiInput.subscriptions model.state
            |> Sub.map MultiInputMsg
        ]


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Model )
update msg model =
    case msg of
        SubmitForm ->
            case validateForm model of
                True ->
                    ( init, Cmd.none, Just model )

                _ ->
                    ( model, Cmd.none, Nothing )

        UpdatePriceMax max ->
            ( { model | priceMax = Maybe.withDefault 0 (String.toInt max) }, Cmd.none, Nothing )

        UpdatePriceMin min ->
            ( { model | priceMin = Maybe.withDefault 0 (String.toInt min) }, Cmd.none, Nothing )

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
    ( { model | tags = nextItems, state = nextState }, Cmd.map toOuterMsg nextCmd )


view : Model -> Html Msg
view model =
    div []
        [ input [ placeholder "price minimum", value (String.fromInt model.priceMin), onInput UpdatePriceMin ] []
        , input [ placeholder "price maximum", value (String.fromInt model.priceMax), onInput UpdatePriceMax ] []
        , br [] []
        , viewTags model
        , br [] []
        , Button.button
            [ Button.dark, Button.attrs [ onClick SubmitForm ] ]
            []
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
    (model.tags |> List.length) > 0
