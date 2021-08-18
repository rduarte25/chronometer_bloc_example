class Ticker {
  const Ticker();
  Stream<int> tick() {
    return Stream.periodic(Duration(milliseconds: 1), (x) => x + 1);
  }
}
