module SiteItems.ClockSet exposing (..)

import SiteItems.Clocks exposing (..)


type alias Model =
    { id : Int
    , clocks : List Clock
    }


type Msg
    = ClockMsg Int SiteItems.Clocks.Msg


update : Msg -> Model -> Model
update msg model =
    case msg of
        ClockMsg id m ->
            { model
                | clocks =
                    model.clocks
                        |> List.map
                            (\x ->
                                if x.id == id then
                                    Tuple.first (SiteItems.Clocks.update m x)

                                else
                                    x
                            )
            }
