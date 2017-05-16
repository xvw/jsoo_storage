let _ = 
  WebStorage.Local.on_change 
    (fun ev _ -> 
      let x = WebStorage.Local.dump_change_state ev in 
      Firebug.console##log(x)
    )