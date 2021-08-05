class Timer{
  float time;
  Timer(float set)
  {
    time = set;
  }
  float getTime() {
    return(time);
  }
  void setTime(float set) {
    time = set;
  }
  void countDown() {
    time -= 1/frameRate;
  }
}
