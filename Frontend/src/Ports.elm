port module Ports exposing (storeItems, storeName)

import Json.Encode as E


port storeName : String -> Cmd msg


port storeItems : List E.Value -> Cmd msg
