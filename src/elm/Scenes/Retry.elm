module Scenes.Retry exposing (..)

import Config.Color exposing (..)
import Data.Transit exposing (Transit(..))
import Helpers.Css.Animation exposing (..)
import Helpers.Css.Style exposing (..)
import Helpers.Css.Timing exposing (..)
import Helpers.Css.Transform exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import State exposing (livesLeft)
import Types exposing (..)
import Views.Lives exposing (renderLivesLeft)


retryView : Model -> Html Msg
retryView model =
    div
        [ class "fixed z-5 flex justify-center items-center w-100 top-0 left-0"
        , style
            [ heightStyle model.window.height
            , background washedYellow
            , animationStyle
                { name = "fade-in"
                , duration = 1000
                , timing = Linear
                }
            ]
        ]
        [ div [ class "tc", style [ ( "margin-top", pc -8 ) ] ]
            [ div [] <| renderLivesLeft <| lifeState model
            , div [ style [ color darkYellow ] ]
                [ p [ class "mt3" ] [ text "You lost a life ..." ]
                , p
                    [ style
                        [ animationWithOptionsStyle
                            { name = "fade-in"
                            , duration = 1000
                            , delay = Just 2500
                            , timing = Ease
                            , iteration = Nothing
                            , fill = Forwards
                            }
                        ]
                    , class "o-0"
                    ]
                    [ text "But don't feel disheartened" ]
                ]
            , div
                [ style
                    [ animationWithOptionsStyle
                        { name = "bounce-up"
                        , duration = 1500
                        , delay = Just 3000
                        , timing = Linear
                        , fill = Forwards
                        , iteration = Nothing
                        }
                    , transformStyle [ translate 0 (toFloat <| model.window.height + 100) ]
                    ]
                ]
                [ tryAgain model ]
            ]
        ]


lifeState : Model -> Transit Int
lifeState model =
    let
        lives =
            model.timeTillNextLife |> livesLeft |> floor
    in
    case model.scene of
        Transition _ ->
            Static lives

        _ ->
            Transitioning lives


tryAgain : Model -> Html Msg
tryAgain model =
    div [ style [ marginTop 50 ], class "pointer" ]
        [ div
            [ styles
                [ [ background lightGreen
                  , color "white"
                  , paddingLeft 25
                  , paddingRight 20
                  , paddingTop 15
                  , paddingBottom 15
                  ]
                , leftPill
                ]
            , class "dib"
            , onClick GoToHub
            ]
            [ p [ class "ma0" ] [ text "X" ] ]
        , div
            [ styles
                [ [ background mediumGreen
                  , color "white"
                  , paddingLeft 20
                  , paddingRight 25
                  , paddingTop 15
                  , paddingBottom 15
                  ]
                , rightPill
                ]
            , class "dib"
            , onClick RestartLevel
            ]
            [ p [ class "ma0" ] [ text "Try again?" ] ]
        ]
