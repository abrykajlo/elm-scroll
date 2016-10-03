import Scroll exposing (Move)
import Html exposing (..)
import Html.Attributes exposing (..)
import Animation as UI exposing (px, percent, width, height, backgroundColor)
import Animation.Properties exposing (..)
import Time exposing (second)
import Platform.Cmd as Cmd exposing (Cmd)

main =
    app.html


app =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

subscriptions : Model -> Sub msg
subscriptions model =
  scroll Move


port tasks : (Task Never ()) -> Cmd msg
port tasks = app.tasks

type Msg
    = Header Move
    | Shrink
    | Grow
    | Animate UI.Action


type alias Model =
    { style : Animation msg }


init : Model
init = 
  { style =
      Animation.style
        [ Animation.width 100 percent
        , Animation.height 90 px
        , Animation.backgroundColor 75 75 75 1
        ]
  }


update : Msg -> Model -> (Model, Cmd Msg)
update message model =
    case message of
        Animate message ->
            onModel model message
        Grow ->
            UI.animate
                |> UI.duration (2*second)
                |> UI.props
                    [ Height (UI.to 200) px ]
                |> onModel model
        Shrink ->
            UI.animate
                |> UI.props
                    [ Height (UI.to 90) px ]
                |> onModel model
        Header move ->
            Scroll.handle
                [ update Grow
                  |> Scroll.onCrossDown 400
                , update Shrink
                  |> Scroll.onCrossUp 400
                ]
                move model
    
onModel : Model -> Msg -> (Model, Cmd Msg)
onModel model message =
  let
      newStyle =
        UI.interrupt
          [ UI.to message ]
          model.style

  in
     { model | style = newStyle }


view : Model -> Html Msg
view message model =
    div [] 
        [ div [ style <| ("position", "fixed") :: UI.render model.style ]
            []
        , div [ style [("height", "10000px")] ] [] ]


port scroll : Move -> Sub msg
