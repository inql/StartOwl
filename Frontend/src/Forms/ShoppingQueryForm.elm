module Forms.ShoppingQueryForm exposing (..)

import Bootstrap.Button as Button
import Html exposing (..)
import Html.Events exposing (onClick)


type alias Model =
    { priceMin : Int
    }


init : Model
init =
    Model 12


type Msg
    = SubmitForm


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Model )
update msg model =
    case msg of
        SubmitForm ->
            ( model, Cmd.none, Just model )


view : Model -> Html Msg
view model =
    div []
        [ Button.button [ Button.dark, Button.attrs [ onClick SubmitForm ] ] []
        ]
