import argv
import gleam/io
import lab3/config
import lab3/input
import lab3/interpolator

pub fn main() {
  let args = argv.load().arguments

  case config.parse(args) {
    Ok(cfg) -> {
      io.println(
        "Потоковая интерполяция: "
        <> config.method_name(cfg.method)
        <> ", step="
        <> config.format_float(cfg.step),
      )
      io.println("Формат ввода: x y (или 'exit' для завершения)")

      let assert Ok(actor_subject) = interpolator.start(cfg)

      input.read_loop(actor_subject)
    }
    Error(msg) -> {
      io.println("Ошибка: " <> msg)
      config.print_usage()
    }
  }
}
