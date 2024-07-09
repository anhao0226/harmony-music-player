export enum CrossFadeState {showFirst, showSecond}

@Component
export struct AnimatedCrossFade {
  @Prop @Watch('onStateChange') state: boolean;
  @BuilderParam firstChild: (() => any | void);
  @BuilderParam secondChild: (() => any | void);
  @State showSecond: boolean = false;
  @State _currState: CrossFadeState = CrossFadeState.showFirst;
  private duration: number = 1000;
  private curve: Curve = Curve.Ease;

  aboutToAppear() {
    this.onStateChange();
  }

  onStateChange() {
    animateTo({
      duration: this.duration,
      curve: this.curve,
    }, () => {
      this._currState = this.getState();
    });
  }

  getState(): CrossFadeState {
    return this.state ? CrossFadeState.showFirst : CrossFadeState.showSecond;
  }

  @Builder ChildWrapper(showState: CrossFadeState) {
    Column() {
      if (showState === CrossFadeState.showFirst) {
        this.firstChild();
      } else if (showState === CrossFadeState.showSecond) {
        this.secondChild();
      }
    }
    .transition({ type: TransitionType.Insert, opacity: 1 })
    .transition({ type: TransitionType.Delete, opacity: 0 });
  }

  build() {
    Column() {
      if (this._currState === CrossFadeState.showFirst) {
        this.ChildWrapper(CrossFadeState.showFirst);
      } else if (this._currState === CrossFadeState.showSecond) {
        this.ChildWrapper(CrossFadeState.showSecond);
      }
    }
  }
}