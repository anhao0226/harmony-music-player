@Component
export struct AnimationBar {
  @State bars: number[] = [];
  @Prop isPlaying: boolean;
  @Prop barCount: number;

  aboutToAppear() {
    this.bars = new Array(this.barCount).fill(3);
  }

  build() {
    Row({ space: 2 }) {
      ForEach(this.bars, (item, index: number) => {
        AnimationBarItem({ barWidth: 2, isPlaying: this.isPlaying });
      }, (_: number, index: number) => index.toString());
    }
    .width(30)
    .height(40)
    .alignItems(VerticalAlign.Bottom)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.Pink);
  }
}

@Component
struct AnimationBarItem {
  @Prop barWidth: number;
  @Prop @Watch('onStateChange') isPlaying: boolean;
  @State aniHeight: number = 10;
  private timer: number = -1;
  private hasTimer: boolean = false;
  private maxHeight: number = 30;

  aboutToAppear() {
    this.onStateChange();
    this.aniHeight = this.randomHeight();
  }

  aboutToDisappear() {
    if (this.timer) clearTimeout(this.timer);
  }

  randomHeight() {
    return Math.round(Math.random() * this.maxHeight);
  }

  onStateChange() {
    if (this.isPlaying) {
      this.startAnimation();
    } else clearTimeout(this.timer);
  }

  startAnimation() {
    if (this.isPlaying) {
      clearTimeout(this.timer);
      this.timer = setTimeout(() => {
        animateTo({ duration: 325, curve: Curve.EaseInOut }, () => {
          this.aniHeight = this.randomHeight();
        })
        if (this.isPlaying) this.startAnimation();
      }, 326)
    }

  }

  build() {
    Column().width(this.barWidth).height(this.aniHeight)
      .borderRadius({ topLeft: this.barWidth, topRight: this.barWidth })
      .backgroundColor(Color.Red);
  }
}