import gleam/float
import gleam/int
import gleam/io
import gleam/option.{type Option, None, Some}
import lab3/types.{type Config, type InterpolationMethod, Config, Linear, Newton}

pub fn parse(args: List(String)) -> Result(Config, String) {
  do_parse(args, None, None)
}

fn do_parse(
  args: List(String),
  method: Option(InterpolationMethod),
  step: Option(Float),
) -> Result(Config, String) {
  case args {
    [] -> {
      case method, step {
        Some(m), Some(s) -> Ok(Config(method: m, step: s))
        None, _ -> Error("Не указан метод интерполяции")
        _, None -> Error("Не указан параметр step")
      }
    }

    ["linear", ..rest] -> do_parse(rest, Some(Linear), step)

    ["newton", "n", n_str, ..rest] -> {
      case int.parse(n_str) {
        Ok(n) if n >= 2 -> do_parse(rest, Some(Newton(window_size: n)), step)
        Ok(_) -> Error("Размер окна для Newton должен быть >= 2")
        Error(_) -> Error("Неверное значение n: " <> n_str)
      }
    }

    ["step", step_str, ..rest] -> {
      case float.parse(step_str) {
        Ok(s) if s >. 0.0 -> do_parse(rest, method, Some(s))
        Ok(_) -> Error("Шаг должен быть > 0")
        Error(_) -> Error("Неверное значение step: " <> step_str)
      }
    }

    [unknown, ..rest] -> {
      io.println("Предупреждение: неизвестный параметр '" <> unknown <> "'")
      do_parse(rest, method, step)
    }
  }
}

pub fn method_name(method: InterpolationMethod) -> String {
  case method {
    Linear -> "Linear"
    Newton(n) -> "Newton (n=" <> int.to_string(n) <> ")"
  }
}

pub fn format_float(f: Float) -> String {
  let rounded = int.to_float(float.round(f *. 1_000_000.0)) /. 1_000_000.0
  float.to_string(rounded)
}

pub fn print_usage() {
  io.println(
    "
Использование:
  gleam run -- linear step 0.7
  gleam run -- newton n 4 step 0.5

Параметры:
  linear              Линейная интерполяция
  newton n <число>    Интерполяция Ньютона с окном из N точек
  step <число>        Шаг дискретизации (обязательно)
",
  )
}
