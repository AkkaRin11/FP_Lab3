import gleam/option.{type Option, None, Some}
import lab3/types.{type Point}

pub fn interpolate(points: List(Point), x: Float) -> Result(Float, Nil) {
  case find_surrounding_points(points, x) {
    Ok(#(p1, p2)) -> {
      let y = p1.y +. { x -. p1.x } *. { p2.y -. p1.y } /. { p2.x -. p1.x }
      Ok(y)
    }
    Error(_) -> Error(Nil)
  }
}

fn find_surrounding_points(
  points: List(Point),
  x: Float,
) -> Result(#(Point, Point), Nil) {
  do_find_surrounding(points, x, None)
}

fn do_find_surrounding(
  points: List(Point),
  x: Float,
  prev: Option(Point),
) -> Result(#(Point, Point), Nil) {
  case points {
    [] -> Error(Nil)
    [current, ..rest] -> {
      case prev {
        None -> {
          case current.x <=. x {
            True -> do_find_surrounding(rest, x, Some(current))
            False -> Error(Nil)
          }
        }
        Some(p1) -> {
          case current.x >=. x {
            True -> Ok(#(p1, current))
            False -> do_find_surrounding(rest, x, Some(current))
          }
        }
      }
    }
  }
}
