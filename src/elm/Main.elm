module Main exposing (main)

import Browser
import Browser.Events as Browser
import Config.Level as Level
import Config.World as Worlds
import Context exposing (Context)
import Css.Color as Color
import Css.Style exposing (backgroundColor, style)
import Exit
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Html.Keyed as Keyed
import Level.Progress as Progress exposing (Progress)
import Lives
import Ports
import Scene.Garden as Garden
import Scene.Hub as Hub
import Scene.Intro as Intro
import Scene.Level as Level
import Scene.Retry as Retry
import Scene.Summary as Summary
import Scene.Title as Title
import Time exposing (millisToPosix)
import Utils.Delay as Delay exposing (trigger)
import Utils.Update exposing (updateModel, updateWith)
import View.Animation exposing (animations)
import View.LoadingScreen as LoadingScreen exposing (LoadingScreen)
import View.Menu as Menu
import Window exposing (Window)



-- Program


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- Model


type alias Flags =
    { now : Int
    , lives : Maybe Lives.Cache
    , level : Maybe Level.Cache
    , randomMessageIndex : Int
    , window : Window
    }


type alias Model =
    { scene : Scene
    , backdrop : Maybe Scene
    }


type Scene
    = Title Title.Model
    | Intro Intro.Model
    | Hub Hub.Model
    | Level Level.Model
    | Retry Retry.Model
    | Summary Summary.Model
    | Garden Garden.Model


type Msg
    = TitleMsg Title.Msg
    | IntroMsg Intro.Msg
    | HubMsg Hub.Msg
    | LevelMsg Level.Msg
    | RetryMsg Retry.Msg
    | SummaryMsg Summary.Msg
    | GardenMsg Garden.Msg
    | InitIntro
    | InitHub Level.Id
    | InitLevel Level.LevelConfig
    | InitRetry
    | InitSummary
    | InitGarden
    | ShowLoadingScreen
    | HideLoadingScreen
    | OpenMenu
    | CloseMenu
    | LoadingScreenGenerated LoadingScreen
    | ResetData
    | WindowSize Int Int
    | UpdateLives Time.Posix
    | GoToHub Level.Id



-- Init


init : Flags -> ( Model, Cmd Msg )
init flags =
    initialContext flags
        |> Title.init
        |> updateWith TitleMsg initialState


initialState : Title.Model -> Model
initialState titleModel =
    { scene = Title titleModel
    , backdrop = Nothing
    }


initialContext : Flags -> Context
initialContext flags =
    { window = flags.window
    , loadingScreen = LoadingScreen.hidden
    , progress = Progress.fromCache flags.level
    , lives = Lives.fromCache (millisToPosix flags.now) flags.lives
    , successMessageIndex = flags.randomMessageIndex
    , menu = Context.Closed
    }



-- Context


getContext : Model -> Context
getContext model =
    case model.scene of
        Title subModel ->
            Title.getContext subModel

        Intro subModel ->
            Intro.getContext subModel

        Hub subModel ->
            Hub.getContext subModel

        Level subModel ->
            Level.getContext subModel

        Retry subModel ->
            Retry.getContext subModel

        Summary subModel ->
            Summary.getContext subModel

        Garden subModel ->
            Garden.getContext subModel


updateContext : (Context -> Context) -> Model -> Model
updateContext toContext model =
    { model | scene = updateSceneContext toContext model.scene }


updateSceneContext : (Context -> Context) -> Scene -> Scene
updateSceneContext toContext scene =
    case scene of
        Title model ->
            Title (Title.updateContext toContext model)

        Intro model ->
            Intro (Intro.updateContext toContext model)

        Hub model ->
            Hub (Hub.updateContext toContext model)

        Level model ->
            Level (Level.updateContext toContext model)

        Retry model ->
            Retry (Retry.updateContext toContext model)

        Summary model ->
            Summary (Summary.updateContext toContext model)

        Garden model ->
            Garden (Garden.updateContext toContext model)



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ scene, backdrop } as model) =
    case ( msg, scene, backdrop ) of
        ( TitleMsg title, Title titleModel, _ ) ->
            updateTitle title titleModel model

        ( IntroMsg intro, Intro introModel, _ ) ->
            updateIntro intro introModel model

        ( HubMsg hub, Hub hubModel, _ ) ->
            updateHub hub hubModel model

        ( LevelMsg level, Level levelModel, _ ) ->
            updateLevel level levelModel model

        ( LevelMsg level, _, Just (Level levelModel) ) ->
            updateLevelBackdrop level levelModel model

        ( RetryMsg retry, Retry retryModel, _ ) ->
            updateRetry retry retryModel model

        ( SummaryMsg summary, Summary summaryModel, _ ) ->
            updateSummary summary summaryModel model

        ( GardenMsg garden, Garden gardenModel, _ ) ->
            updateGarden garden gardenModel model

        ( InitIntro, _, _ ) ->
            initIntro model

        ( InitHub level, _, _ ) ->
            initHub level model

        ( InitLevel level, _, _ ) ->
            initLevel level model

        ( InitRetry, _, _ ) ->
            initRetry model

        ( InitSummary, _, _ ) ->
            initSummary model

        ( InitGarden, _, _ ) ->
            initGarden model

        ( ShowLoadingScreen, _, _ ) ->
            ( updateContext Context.closeMenu model
            , LoadingScreen.generate LoadingScreenGenerated
            )

        ( LoadingScreenGenerated screen, _, _ ) ->
            ( updateContext (Context.showLoadingScreen screen) model, Cmd.none )

        ( HideLoadingScreen, _, _ ) ->
            ( updateContext Context.hideLoadingScreen model, Cmd.none )

        ( OpenMenu, _, _ ) ->
            ( updateContext Context.openMenu model, Cmd.none )

        ( CloseMenu, _, _ ) ->
            ( updateContext Context.closeMenu model, Cmd.none )

        ( GoToHub level, _, _ ) ->
            ( model, withLoadingScreen (InitHub level) )

        ( ResetData, _, _ ) ->
            ( model, Ports.clearCache )

        ( WindowSize width height, _, _ ) ->
            ( updateContext (Context.setWindow width height) model
            , Cmd.none
            )

        ( UpdateLives now, _, _ ) ->
            updateLives now model

        _ ->
            ( model, Cmd.none )



-- Title


updateTitle : Title.Msg -> Title.Model -> Model -> ( Model, Cmd Msg )
updateTitle =
    updateScene Title TitleMsg Title.update |> Exit.onExit exitTitle


exitTitle : Model -> Title.Destination -> ( Model, Cmd Msg )
exitTitle model destination =
    case destination of
        Title.ToHub ->
            ( model, goToHubReachedLevel model )

        Title.ToIntro ->
            ( model, trigger InitIntro )

        Title.ToGarden ->
            ( model, goToGarden )



-- Intro


initIntro : Model -> ( Model, Cmd Msg )
initIntro =
    initScene Intro IntroMsg Intro.init >> closeMenu


updateIntro : Intro.Msg -> Intro.Model -> Model -> ( Model, Cmd Msg )
updateIntro =
    updateScene Intro IntroMsg Intro.update |> Exit.onExit exitIntro


exitIntro : Model -> () -> ( Model, Cmd Msg )
exitIntro model _ =
    ( model, Cmd.batch [ goToHubReachedLevel model, Ports.fadeMusic () ] )



-- Hub


initHub : Level.Id -> Model -> ( Model, Cmd Msg )
initHub level =
    initScene Hub HubMsg (Hub.init level) >> closeMenu


updateHub : Hub.Msg -> Hub.Model -> Model -> ( Model, Cmd Msg )
updateHub =
    updateScene Hub HubMsg Hub.update |> Exit.onExit exitHub


exitHub : Model -> Hub.Destination -> ( Model, Cmd Msg )
exitHub model destination =
    case destination of
        Hub.ToLevel level ->
            handleStartLevel model level

        Hub.ToGarden ->
            ( model, goToGarden )


handleStartLevel : Model -> Level.Id -> ( Model, Cmd Msg )
handleStartLevel model level =
    ( model, withLoadingScreen (InitLevel (Worlds.levelConfig level)) )



-- Level


initLevel : Level.LevelConfig -> Model -> ( Model, Cmd Msg )
initLevel config =
    initScene Level LevelMsg (Level.init config) >> closeMenu


updateLevel : Level.Msg -> Level.Model -> Model -> ( Model, Cmd Msg )
updateLevel =
    updateScene Level LevelMsg Level.update |> Exit.onExit exitLevel


updateLevelBackdrop : Level.Msg -> Level.Model -> Model -> ( Model, Cmd Msg )
updateLevelBackdrop =
    updateBackdrop Level LevelMsg Level.update |> Exit.ignore


exitLevel : Model -> Level.Status -> ( Model, Cmd Msg )
exitLevel model levelStatus =
    case levelStatus of
        Level.Win ->
            levelWin model

        Level.Lose ->
            levelLose model

        Level.Restart ->
            ( model, reloadCurrentLevel model )

        Level.Exit ->
            ( model, goToHubCurrentLevel model )

        Level.NotStarted ->
            ( model, Cmd.none )

        Level.InProgress ->
            ( model, Cmd.none )


levelWin : Model -> ( Model, Cmd Msg )
levelWin model =
    if shouldIncrement (getContext model) then
        ( model, trigger InitSummary )

    else
        ( model, goToHubCurrentLevel model )


levelLose : Model -> ( Model, Cmd Msg )
levelLose model =
    if livesRemaining model == 1 then
        ( updateContext Context.decrementLife model, goToHubCurrentLevel model )

    else
        ( model, trigger InitRetry )



-- Retry


initRetry : Model -> ( Model, Cmd Msg )
initRetry =
    copyCurrentSceneToBackdrop
        >> initScene Retry RetryMsg Retry.init
        >> closeMenu


updateRetry : Retry.Msg -> Retry.Model -> Model -> ( Model, Cmd Msg )
updateRetry =
    updateScene Retry RetryMsg Retry.update |> Exit.onExit exitRetry


exitRetry : Model -> Retry.Destination -> ( Model, Cmd Msg )
exitRetry model destination =
    case destination of
        Retry.ToLevel ->
            ( clearBackdrop model, reloadCurrentLevel model )

        Retry.ToHub ->
            ( clearBackdrop model, goToHubCurrentLevel model )



-- Summary


initSummary : Model -> ( Model, Cmd Msg )
initSummary =
    copyCurrentSceneToBackdrop
        >> initScene Summary SummaryMsg Summary.init
        >> closeMenu


updateSummary : Summary.Msg -> Summary.Model -> Model -> ( Model, Cmd Msg )
updateSummary =
    updateScene Summary SummaryMsg Summary.update |> Exit.onExit exitSummary


exitSummary : Model -> Summary.Destination -> ( Model, Cmd Msg )
exitSummary model destination =
    case destination of
        Summary.ToHub ->
            ( clearBackdrop model, goToHubReachedLevel model )

        Summary.ToGarden ->
            ( clearBackdrop model, trigger InitGarden )



-- Garden


initGarden : Model -> ( Model, Cmd Msg )
initGarden =
    initScene Garden GardenMsg Garden.init >> closeMenu


updateGarden : Garden.Msg -> Garden.Model -> Model -> ( Model, Cmd Msg )
updateGarden =
    updateScene Garden GardenMsg Garden.update |> Exit.onExit exitGarden


exitGarden : Model -> () -> ( Model, Cmd Msg )
exitGarden model _ =
    ( model, goToHubReachedLevel model )



-- Util


initScene :
    (subModel -> Scene)
    -> (subMsg -> msg)
    -> (Context -> ( subModel, Cmd subMsg ))
    -> Model
    -> ( Model, Cmd msg )
initScene =
    load asForeground


updateScene :
    (subModel -> Scene)
    -> (subMsg -> msg)
    -> (subMsg -> subModel -> Exit.With payload ( subModel, Cmd subMsg ))
    -> Exit.Handle payload subMsg subModel Model msg
updateScene toScene =
    Exit.handle (composeScene toScene asForeground)


updateBackdrop :
    (subModel -> Scene)
    -> (subMsg -> msg)
    -> (subMsg -> subModel -> Exit.With payload ( subModel, Cmd subMsg ))
    -> Exit.Handle payload subMsg subModel Model msg
updateBackdrop toScene =
    Exit.handle (composeScene toScene asBackdrop)


load :
    (Model -> Scene -> Model)
    -> (subModel -> Scene)
    -> (subMsg -> msg)
    -> (Context -> ( subModel, Cmd subMsg ))
    -> Model
    -> ( Model, Cmd msg )
load toModel toScene msg initScene_ model =
    getContext model
        |> Context.closeMenu
        |> initScene_
        |> updateWith msg (toScene >> toModel model)


composeScene : (subModel -> Scene) -> (Model -> Scene -> Model) -> (subModel -> Model -> Model)
composeScene toScene toModel sceneModel model =
    toModel model (toScene sceneModel)


asForeground : Model -> Scene -> Model
asForeground model scene =
    { model | scene = scene }


asBackdrop : Model -> Scene -> Model
asBackdrop model scene =
    { model | backdrop = Just scene }


copyCurrentSceneToBackdrop : Model -> Model
copyCurrentSceneToBackdrop model =
    { model | backdrop = Just model.scene }


clearBackdrop : Model -> Model
clearBackdrop model =
    { model | backdrop = Nothing }



-- Misc


withLoadingScreen : Msg -> Cmd Msg
withLoadingScreen msg =
    Delay.sequence
        [ ( 0, ShowLoadingScreen )
        , ( 1000, msg )
        , ( 1500, HideLoadingScreen )
        ]


goToGarden : Cmd Msg
goToGarden =
    Delay.sequence
        [ ( 0, ShowLoadingScreen )
        , ( 2500, HideLoadingScreen )
        , ( 0, InitGarden )
        ]


reloadCurrentLevel : Model -> Cmd Msg
reloadCurrentLevel =
    withLoadingScreen << InitLevel << Worlds.levelConfig << currentLevel


goToHubCurrentLevel : Model -> Cmd Msg
goToHubCurrentLevel =
    trigger << GoToHub << currentLevel


goToHubReachedLevel : Model -> Cmd Msg
goToHubReachedLevel =
    trigger << GoToHub << reachedLevel


updateLives : Time.Posix -> Model -> ( Model, Cmd Msg )
updateLives now model =
    model
        |> updateContext (Context.updateLives now)
        |> andCmd saveCurrentLives


andCmd : (Model -> Cmd Msg) -> Model -> ( Model, Cmd Msg )
andCmd cmdF model =
    ( model, cmdF model )


closeMenu : ( Model, Cmd msg ) -> ( Model, Cmd msg )
closeMenu =
    updateModel (updateContext Context.closeMenu)


saveCurrentLives : Model -> Cmd Msg
saveCurrentLives =
    getContext >> Context.cacheCurrentLives


livesRemaining : Model -> Int
livesRemaining =
    getContext >> .lives >> Lives.remaining


reachedLevel : Model -> Level.Id
reachedLevel =
    getContext >> .progress >> Progress.reachedLevel


currentLevel : Model -> Level.Id
currentLevel =
    getContext >> .progress >> currentLevelWithDefault


currentLevelWithDefault : Progress -> Level.Id
currentLevelWithDefault progress =
    progress
        |> Progress.currentLevel
        |> Maybe.withDefault (Progress.reachedLevel progress)


shouldIncrement : Context -> Bool
shouldIncrement context =
    Progress.currentLevelComplete context.progress == Just False



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.onResize WindowSize
        , updateLivesSubscription model
        , sceneSubscriptions model
        ]


updateLivesSubscription : Model -> Sub Msg
updateLivesSubscription model =
    case model.scene of
        Hub _ ->
            Time.every 100 UpdateLives

        _ ->
            Time.every 5000 UpdateLives


sceneSubscriptions : Model -> Sub Msg
sceneSubscriptions model =
    case model.scene of
        Title titleModel ->
            Sub.map TitleMsg (Title.subscriptions titleModel)

        _ ->
            Sub.none



-- View


view : Model -> Html Msg
view model =
    div []
        [ animations
        , LoadingScreen.view (getContext model)
        , menu model.scene
        , stage
            [ viewBackdrop model.backdrop
            , viewScene model.scene
            ]
        , background
        ]


stage : List (List ( String, Html msg )) -> Html msg
stage =
    Keyed.node "div" [] << List.concat


viewBackdrop : Maybe Scene -> List ( String, Html Msg )
viewBackdrop =
    Maybe.map viewScene >> Maybe.withDefault []


viewScene : Scene -> List ( String, Html Msg )
viewScene scene =
    case scene of
        Hub model ->
            [ ( "hub", Hub.view model |> Html.map HubMsg ) ]

        Intro model ->
            [ ( "intro", Intro.view model |> Html.map IntroMsg ) ]

        Title model ->
            [ ( "title", Title.view model |> Html.map TitleMsg ) ]

        Level model ->
            [ ( "level", Level.view model |> Html.map LevelMsg ) ]

        Summary model ->
            [ ( "summary", Summary.view model |> Html.map SummaryMsg ) ]

        Retry model ->
            [ ( "retry", Retry.view model |> Html.map RetryMsg ) ]

        Garden model ->
            [ ( "garden", Garden.view model |> Html.map GardenMsg ) ]



-- Menu


menu : Scene -> Html Msg
menu scene =
    let
        renderMenu =
            Menu.view
                { close = CloseMenu
                , open = OpenMenu
                , resetData = ResetData
                }
    in
    case scene of
        Title model ->
            renderMenu model.context TitleMsg Title.menuOptions

        Hub model ->
            renderMenu model.context HubMsg Hub.menuOptions

        Level model ->
            renderMenu model.context LevelMsg (Level.menuOptions model)

        Garden model ->
            renderMenu model.context GardenMsg Garden.menuOptions

        _ ->
            Menu.fadeOut


background : Html msg
background =
    div
        [ style [ backgroundColor Color.lightYellow ]
        , class "fixed w-100 h-100 top-0 left-0 z-0"
        ]
        []
