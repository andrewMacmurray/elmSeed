module View exposing (..)

import Config.Color exposing (darkYellow)
import Helpers.Animation exposing (embeddedAnimations)
import Helpers.Style exposing (color)
import Html exposing (..)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Html.Keyed as K
import Scenes.Hub.View exposing (hubView)
import Scenes.Level.View exposing (levelView)
import Scenes.Retry.View exposing (retryView)
import Scenes.Summary.View exposing (summaryView)
import Scenes.Title.View exposing (titleView)
import Scenes.Tutorial.View exposing (tutorialView)
import Types exposing (Model, Msg(..), Scene(..))
import Views.Backdrop exposing (backdrop)
import Views.Loading exposing (loadingScreen)


view : Model -> Html Msg
view model =
    div []
        [ embeddedAnimations model.xAnimations
        , reset
        , loadingScreen model
        , renderScene model
        , backdrop
        ]


renderScene : Model -> Html Msg
renderScene model =
    let
        keyedDiv =
            K.node "div" []
    in
        case model.scene of
            Hub ->
                hubView model

            Title ->
                titleView model

            Level ->
                keyedDiv
                    [ ( "level", levelView model.levelModel |> Html.map LevelMsg ) ]

            Summary ->
                keyedDiv
                    [ ( "summary", summaryView model )
                    , ( "level", levelView model.levelModel |> Html.map LevelMsg )
                    ]

            Retry ->
                keyedDiv
                    [ ( "retry", retryView model )
                    , ( "level", levelView model.levelModel |> Html.map LevelMsg )
                    ]

            Tutorial ->
                keyedDiv
                    [ ( "tutorial", tutorialView model.tutorialModel |> Html.map TutorialMsg )
                    , ( "level", levelView model.levelModel |> Html.map LevelMsg )
                    ]


reset : Html Msg
reset =
    p
        [ onClick ClearCache
        , class "dib top-0 right-1 tracked pointer f7 absolute z-999"
        , style [ color darkYellow ]
        ]
        [ text "reset" ]
