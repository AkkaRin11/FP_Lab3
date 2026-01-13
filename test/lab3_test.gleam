import gleeunit
import gleeunit/should
import lab3/config
import lab3/linear
import lab3/newton
import lab3/types.{Config, Linear, Newton, Point}

pub fn main() {
  gleeunit.main()
}

pub fn config_parse_linear_test() {
  config.parse(["linear", "step", "0.5"])
  |> should.be_ok
  |> should.equal(Config(method: Linear, step: 0.5))
}

pub fn config_parse_newton_test() {
  config.parse(["newton", "n", "4", "step", "1.0"])
  |> should.be_ok
  |> should.equal(Config(method: Newton(window_size: 4), step: 1.0))
}

pub fn config_parse_error_test() {
  config.parse([])
  |> should.be_error
  |> should.equal("Не указан метод интерполяции")

  config.parse(["linear"])
  |> should.be_error
  |> should.equal("Не указан параметр step")

  config.parse(["step", "0.5"])
  |> should.be_error
  |> should.equal("Не указан метод интерполяции")

  config.parse(["linear", "step", "abc"])
  |> should.be_error
  |> should.equal("Неверное значение step: abc")

  config.parse(["newton", "n", "1", "step", "0.5"])
  |> should.be_error
  |> should.equal("Размер окна для Newton должен быть >= 2")
}

pub fn linear_interpolation_test() {
  let points = [Point(0.0, 0.0), Point(1.0, 1.0), Point(2.0, 0.0)]

  linear.interpolate(points, 0.0) |> should.equal(Ok(0.0))
  linear.interpolate(points, 1.0) |> should.equal(Ok(1.0))
  linear.interpolate(points, 2.0) |> should.equal(Ok(0.0))

  linear.interpolate(points, 0.5) |> should.equal(Ok(0.5))
  linear.interpolate(points, 1.5) |> should.equal(Ok(0.5))

  linear.interpolate(points, -0.1) |> should.be_error
  linear.interpolate(points, 2.1) |> should.be_error
}

pub fn newton_interpolation_test() {
  let points = [Point(0.0, 0.0), Point(1.0, 1.0), Point(2.0, 4.0)]
  // y = x^2

  newton.interpolate(points, 0.0) |> should.equal(Ok(0.0))
  newton.interpolate(points, 1.0) |> should.equal(Ok(1.0))
  newton.interpolate(points, 2.0) |> should.equal(Ok(4.0))

  newton.interpolate(points, 0.5) |> should.equal(Ok(0.25))
  newton.interpolate(points, 1.5) |> should.equal(Ok(2.25))
}

pub fn newton_interpolation_insufficient_points_test() {
  let points = [Point(0.0, 0.0)]
  newton.interpolate(points, 0.5) |> should.be_error
}

pub fn config_format_float_test() {
  config.format_float(3.14159265) |> should.equal("3.141593")
  config.format_float(1.0) |> should.equal("1.0")
  config.format_float(0.1234567) |> should.equal("0.123457")
}
