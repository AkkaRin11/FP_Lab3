import gleam/list
import lab3/types.{type Point}

pub fn interpolate(points: List(Point), x: Float) -> Result(Float, Nil) {
  case list.length(points) {
    n if n >= 2 -> Ok(compute(points, x))
    _ -> Error(Nil)
  }
}

fn compute(points: List(Point), x: Float) -> Float {
  compute_terms(points, points, x, 0.0, 1.0)
}

fn compute_terms(
  all_points: List(Point),
  remaining: List(Point),
  x: Float,
  acc: Float,
  basis: Float,
) -> Float {
  case remaining {
    [] -> acc
    [_, ..rest] -> {
      let order = list.length(all_points) - list.length(remaining)
      let dd = divided_difference(all_points, order)
      let new_acc = acc +. dd *. basis
      
      let new_basis = case remaining {
        [p, ..] -> basis *. { x -. p.x }
        [] -> basis
      }
      
      compute_terms(all_points, rest, x, new_acc, new_basis)
    }
  }
}

fn divided_difference(points: List(Point), order: Int) -> Float {
  case order {
    0 -> {
      case list.first(points) {
        Ok(p) -> p.y
        Error(_) -> 0.0
      }
    }
    1 -> {
      case points {
        [p0, p1, ..] -> { p1.y -. p0.y } /. { p1.x -. p0.x }
        _ -> 0.0
      }
    }
    _ -> recursive_divided_diff(points, order)
  }
}

fn recursive_divided_diff(points: List(Point), order: Int) -> Float {
  case points, list.drop(points, 1) {
    [p_first, ..], [_, ..rest_tail] -> {
      let points_tail = [p_first, ..rest_tail]
      let left = divided_difference(list.drop(points, 1), order - 1)
      let right = divided_difference(points, order - 1)
      
      case list.first(points_tail), get_nth(points_tail, order) {
        Ok(p0), Ok(pn) -> { left -. right } /. { pn.x -. p0.x }
        _, _ -> 0.0
      }
    }
    _, _ -> 0.0
  }
}

fn get_nth(points: List(Point), n: Int) -> Result(Point, Nil) {
  case n {
    0 -> list.first(points)
    _ -> {
      case points {
        [] -> Error(Nil)
        [_, ..rest] -> get_nth(rest, n - 1)
      }
    }
  }
}
