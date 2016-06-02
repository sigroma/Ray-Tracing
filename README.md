# Ray Tracing

Port of [Ray Tracing In One Weekend](https://github.com/petershirley/raytracinginoneweekend) by Peter Shirley.

**This implementation is realy realy slow! You'd better run it with small parameters.**

# Compare with cpp implementation

All the tests ran on my old windows pc with i5-3470 CPU.
The test parameters are 120x80 with 100 sample rate.

| Language     | Time(ms) |
| ------------ | :------- |
| Cpp          | 17620    |
| Cpp(openmp)  | 5605     |
| Elixir       | 1344745  |
| Elixir(async)| 382015   |
