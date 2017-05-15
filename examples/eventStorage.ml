let puts x = Firebug.console##log(x)

let _ = WebStorage.Local.onchange (fun ev -> 
  puts "test"
)