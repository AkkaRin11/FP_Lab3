import gleam/string
import gleam/float
import gleam/int
import gleam/io
import gleam/erlang/process
import lab3/types.{type Point, type Message, AddPoint, Point, Shutdown}

@external(erlang, "io", "get_line")
fn get_line(prompt: String) -> String

pub fn read_loop(actor_subject: process.Subject(Message)) {
  let line = get_line("> ")
  let input = string.trim(line)

  case input {
    "exit" -> {
      process.send(actor_subject, Shutdown)
      process.sleep(50)
    }
    "" -> read_loop(actor_subject)
    _ -> {
      case parse_point(input) {
        Ok(point) -> {
          process.send(actor_subject, AddPoint(point))
          process.sleep(10)
          read_loop(actor_subject)
        }
        Error(_) -> {
          io.println("Ошибка: неверный формат. Используйте: x y")
          read_loop(actor_subject)
        }
      }
    }
  }
}

fn parse_point(input: String) -> Result(Point, Nil) {
  case string.split(input, " ") {
    [x_str, y_str] -> {
      case parse_number(x_str), parse_number(y_str) {
        Ok(x), Ok(y) -> Ok(Point(x: x, y: y))
        _, _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

fn parse_number(s: String) -> Result(Float, Nil) {
  case float.parse(s) {
    Ok(f) -> Ok(f)
    Error(_) -> {
      case int.parse(s) {
        Ok(i) -> Ok(int.to_float(i))
        Error(_) -> Error(Nil)
      }
    }
  }
}
