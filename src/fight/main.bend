import /App/
import /HTML/
import /play/main/ as Play

init : Play.AppState =
  Play.fight_app_init()

def on_event(evt: Play.FightEvent, state: Play.AppState) -> Play.AppState:
  Play.on_event(evt, state)

def render(state: Play.AppState) -> HTML(Play.FightEvent):
  Play.fight_render(state)

main : App =
  app{Play.AppState, Play.FightEvent, init, render, on_event}
