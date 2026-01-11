import gleam/option.{type Option}

pub type Point {
  Point(x: Float, y: Float)
}

pub type InterpolationMethod {
  Linear
  Newton(window_size: Int)
}

pub type Config {
  Config(method: InterpolationMethod, step: Float)
}

pub type Message {
  AddPoint(Point)
  Shutdown
}

pub type State {
  State(
    points: List(Point),
    config: Config,
    last_output_x: Option(Float),
  )
}
