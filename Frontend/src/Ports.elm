port module Ports exposing (storeCategories, storeClocks, storeName, storeShoppingQueries, storeUrls)

import Json.Encode as E


port storeName : String -> Cmd msg


port storeCategories : List E.Value -> Cmd msg


port storeClocks : List E.Value -> Cmd msg


port storeShoppingQueries : List E.Value -> Cmd msg


port storeUrls : List String -> Cmd msg
