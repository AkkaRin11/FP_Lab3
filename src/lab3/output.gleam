import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/io
import lab3/types.{type Config, type Point, Linear, Newton}
import lab3/linear
import lab3/newton
import lab3/config

pub fn interpolate_and_output(
  points: List(Point),
  cfg: Config,
  last_output_x: Option(Float),
) -> Float {
  let assert Ok(first) = list.first(points)
  let assert Ok(last) = list.last(points)

  let start_x = case last_output_x {
    None -> first.x
    Some(x) -> x +. cfg.step
  }

  let end_x = case last_output_x {
    None -> last.x
    Some(x) -> x +. cfg.step
  }

  output_range(points, cfg, start_x, end_x)
}

pub fn output_range(
  points: List(Point),
  cfg: Config,
  start_x: Float,
  end_x: Float,
) -> Float {
  do_output_range(points, cfg, start_x, end_x, start_x)
}

fn do_output_range(
  points: List(Point),
  cfg: Config,
  current_x: Float,
  end_x: Float,
  last_x: Float,
) -> Float {
  case current_x <=. end_x {
    True -> {
      case interpolate(points, cfg.method, current_x) {
        Ok(y) -> {
          let method_prefix = case cfg.method {
            Linear -> "linear"
            Newton(_) -> "newton"
          }
          io.println(
            "> "
            <> method_prefix
            <> ": "
            <> config.format_float(current_x)
            <> " "
            <> config.format_float(y),
          )
          do_output_range(points, cfg, current_x +. cfg.step, end_x, current_x)
        }
        Error(_) -> last_x
      }
    }
    False -> last_x
  }
}

fn interpolate(
  points: List(Point),
  method: types.InterpolationMethod,
  x: Float,
) -> Result(Float, Nil) {
  case method {
    Linear -> linear.interpolate(points, x)
    Newton(_) -> newton.interpolate(points, x)
  }
}
