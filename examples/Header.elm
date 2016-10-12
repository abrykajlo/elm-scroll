port module Header exposing (..)
import Scroll exposing (Move)
import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Animation as UI exposing (px, percent, width, height, backgroundColor)
import Time exposing (second)
import Platform.Cmd as Cmd exposing (Cmd)
import Color exposing (rgb, rgba)

main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
    [ UI.subscription Animate [model.style]
    , scroll Header
    ]


type Msg
    = Grow
    | Header Move
    | Shrink
    | Animate UI.Msg


type alias Model =
    { style : UI.State
    }


init : (Model, Cmd Msg)
init = 
  ({ style =
      UI.style
        [ UI.width (px 700)
        , UI.height (px 90)
        , UI.backgroundColor (rgba 75 75 75 1)
        ]
  }
  , Cmd.none
  )



update : Msg -> Model -> (Model, Cmd Msg)
update message model =
    case message of
      Header move ->
        Scroll.handle
            [ update Grow
              |> Scroll.onCrossDown 400
            , update Shrink
              |> Scroll.onCrossUp 400
            ]
            move model

      Grow ->
        let
            newStyle =
              UI.interrupt
                [ UI.to
                  [ UI.height (px 200) ]
                ]
                model.style
        in
           ({ model | style = newStyle }, Cmd.none)

      Shrink ->
        let
            newStyle =
              UI.interrupt
                [ UI.to
                  [ UI.height (px 90) ]
                ]
                model.style
        in
           ({ model | style = newStyle }, Cmd.none)

      Animate animMsg ->
        ({ model | style = UI.update animMsg model.style }, Cmd.none)
    
onModel : Model -> UI.Msg -> (Model, Cmd Msg)
onModel model animMsg =
  ({ model | style = UI.update animMsg model.style }, Cmd.none)

view : Model -> Html Msg
view model =
  div []
    [
      div
        (UI.render model.style
                    ++ [ style
                         [ ( "position", "fixed" )
                         ]
                       ]
        ) []
      , div
          [ style
            [ ("height", "3000px") ]
          ]
          []
    ]


port scroll : (Move -> msg) -> Sub msg
