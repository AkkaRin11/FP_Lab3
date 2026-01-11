import gleam/erlang/process
import gleam/list
import gleam/option.{None, Some}
import gleam/otp/actor
import lab3/output
import lab3/types.{
  type Config, type Message, type State, AddPoint, Linear, Newton, Shutdown,
  State,
}

pub fn start(
  config: Config,
) -> Result(process.Subject(Message), actor.StartError) {
  case
    actor.new(State(points: [], config: config, last_output_x: None))
    |> actor.on_message(handle_message)
    |> actor.start
  {
    Ok(act) -> Ok(act.data)
    Error(e) -> Error(e)
  }
}

fn handle_message(state: State, msg: Message) -> actor.Next(State, Message) {
  case msg {
    AddPoint(point) -> {
      let new_points = list.append(state.points, [point])

      let min_points = case state.config.method {
        Linear -> 2
        Newton(n) -> n
      }

      case list.length(new_points) >= min_points {
        True -> {
          let window = case state.config.method {
            Linear -> new_points
            Newton(n) -> take_last_n(new_points, n)
          }

          let new_last_x =
            output.interpolate_and_output(
              window,
              state.config,
              state.last_output_x,
            )

          actor.continue(State(
            points: new_points,
            config: state.config,
            last_output_x: Some(new_last_x),
          ))
        }
        False -> actor.continue(State(..state, points: new_points))
      }
    }

    Shutdown -> {
      let min_points = case state.config.method {
        Linear -> 2
        Newton(n) -> n
      }

      case list.length(state.points) >= min_points, list.last(state.points) {
        True, Ok(last_point) -> {
          case state.last_output_x {
            Some(last_x) -> {
              let window = case state.config.method {
                Linear -> state.points
                Newton(n) -> take_last_n(state.points, n)
              }

              let _ =
                output.output_range(
                  window,
                  state.config,
                  last_x +. state.config.step,
                  last_point.x,
                )
              Nil
            }
            None -> Nil
          }
        }
        _, _ -> Nil
      }
      actor.stop()
    }
  }
}

fn take_last_n(list: List(a), n: Int) -> List(a) {
  let len = list.length(list)
  case len <= n {
    True -> list
    False -> list.drop(list, len - n)
  }
}
