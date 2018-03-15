module Scenes.Hub.View exposing (..)

import Config.Color exposing (darkYellow, washedYellow)
import Date exposing (minute, second)
import Helpers.Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Scenes.Hub.Types exposing (..)
import Time exposing (Time)
import Views.Hub.InfoWindow exposing (handleHideInfo, info)
import Views.Hub.World exposing (renderWorlds)
import Views.Lives exposing (livesLeft)


hubView : Model -> Html Msg
hubView model =
    div
        [ class "w-100 fixed overflow-y-scroll momentum-scroll z-2"
        , id "hub"
        , style [ heightStyle model.window.height ]
        , handleHideInfo model
        ]
        (hubContent model)


hubContent : Model -> List (Html Msg)
hubContent model =
    [ info model
    , hubTopBar model
    ]
        ++ renderWorlds model


hubTopBar : Model -> Html msg
hubTopBar model =
    div
        [ class "fixed w-100 top-0 tc pa3"
        , style [ background washedYellow ]
        ]
        [ div [ style [ transformStyle <| scale 0.8 ] ] <| livesLeft model.lives
        , p [ class "f7", style [ color darkYellow ] ] [ text <| getTimeLeft model.timeTillNextLife ]
        ]


getTimeLeft : Time -> String
getTimeLeft timeRemaining =
    let
        d =
            Date.fromTime timeRemaining

        ( m, s ) =
            ( minute d % 5, second d )
    in
        if timeRemaining == 0 then
            "full life"
        else
            toString m ++ ":" ++ renderSecond s


renderSecond : Int -> String
renderSecond n =
    if n < 10 then
        "0" ++ toString n
    else
        toString n
