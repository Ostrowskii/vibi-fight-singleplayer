import /App/
import /HTML/

type MenuState {
  menu_state{}
}

type MenuEvent {
  evt_ignore{}
}

init : MenuState =
  menu_state{}

def on_event(evt: MenuEvent, state: MenuState) -> MenuState:
  state

def render(state: MenuState) -> HTML(MenuEvent):
  <main class="menu-page">
    <style>{text{css()}}</style>
    <section class="menu-card">
      <div class="menu-eyebrow">{text{"Vibi Fight"}}</div>
      <h1 class="menu-title">{text{"Escolha como entrar"}}</h1>
      <p class="menu-copy">{text{"Campanha leva para o modo historia. Area de testes abre o lobby da luta casual."}}</p>
      <div class="menu-actions">
        <a class="menu-link menu-link--primary" href="./story/">{text{"Campanha"}}</a>
        <a class="menu-link" href="./play/">{text{"Area de testes"}}</a>
      </div>
    </section>
  </main>

def css() -> String:
  ""
  ++ ":root{--bg:#d3bb94;--panel:#efe2c6;--text:#2a2115;--muted:#6b593c;--border:#7a613c;--button:#966320;--button-alt:#b58a43;}*{box-sizing:border-box;}html,body{margin:0;width:100%;height:100%;background:var(--bg);color:var(--text);font-family:'Trebuchet MS','Segoe UI',sans-serif;}body{min-height:100svh;}a{text-decoration:none;}"
  ++ ".menu-page{min-height:100svh;padding:32px 20px;display:grid;place-items:center;}.menu-card{width:min(100%,520px);display:grid;gap:18px;justify-items:center;text-align:center;padding:36px 28px;background:var(--panel);border:1px solid var(--border);}.menu-eyebrow{font-size:12px;letter-spacing:.18em;text-transform:uppercase;color:var(--muted);font-weight:800;}.menu-title{margin:0;font-size:48px;line-height:1;}.menu-copy{margin:0;color:var(--muted);line-height:1.6;max-width:34ch;}.menu-actions{width:min(100%,280px);display:grid;gap:12px;}.menu-link{display:inline-flex;align-items:center;justify-content:center;width:100%;min-height:48px;padding:11px 15px;border-radius:999px;background:var(--button-alt);color:#fff8eb;font-weight:800;}.menu-link--primary{background:var(--button);}@media (max-width:720px){.menu-page{padding:20px 14px;}.menu-title{font-size:38px;}}"

main : App =
  app{MenuState, MenuEvent, init, render, on_event}
