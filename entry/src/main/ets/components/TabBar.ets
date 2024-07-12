enum _SwipeDirection { Left, Right, Up, Down, None }

interface _SwipeValue {
  offset: number,
  direction: _SwipeDirection,
  time: number
}

export interface TabInterface {
  text: string
  icon?: Resource
}
//
export type TabBuilderCallBack = ((tab: TabInterface, index: number) => void | void);

@Component
export struct TabBar {
  @Link @Watch('onTabsChange') tabs: TabInterface[];
  @BuilderParam viewBuilder: TabBuilderCallBack = this._defaultViewBuilder;
  private labelColor: ResourceColor = '#99000000';
  private labelSize: Length = 22;
  private labelPadding: Length | Padding = { left: 16, right: 16 };
  private unselectedLabelColor: ResourceColor = '#66000000';
  private underlineColor: ResourceColor = '#99000000';
  private onViewAreaChange: (oldVal: Area, newVal: Area) => void;
  //
  @State tabItemWidth: number = 0;
  @State currIndex: number = 0;
  @State underlineXOffset: number = 0;
  @State underlineWidth: number = 0;
  @State viewState: boolean[] = null;
  //
  private tabCount: number = 0;
  private tabAreas: Area[] = null;
  private viewItemWidth: number = 0;
  private startTouchEvent: TouchEvent = null;
  private tabScroller: Scroller = new Scroller();
  private viewScroller: Scroller = new Scroller();

  aboutToAppear() {
    this.onTabsChange();
  }

  onTabsChange() {
    this.tabCount = this.tabs.length;
    this.tabAreas = new Array<Area>(this.tabCount).fill(null, 0, this.tabCount);
    this.viewState = new Array<boolean>(this.tabCount).fill(false, 0, this.tabCount);
    this.viewState[0] = true;
  }

  scrollToByIndex(index: number) {
    //
    this.viewScroller.scrollTo({
      xOffset: index * this.viewItemWidth,
      yOffset: 0,
      animation: { duration: 325, curve: Curve.EaseInOut }
    });

    //
    animateTo({ duration: 325, curve: Curve.EaseInOut }, () => {
      this.underlineWidth = this.tabAreas[index].width as number;
      this.underlineXOffset = this.tabAreas[index].position.x as number;
    })
  }

  handleTouchEvent(event?: TouchEvent) {
    if (event.type == TouchType.Down) {
      this.startTouchEvent = event;
    } else if (event.type == TouchType.Move) {
      const { direction, offset } = this.calcSwiperValue(this.startTouchEvent, event);
      const ratio: number = (this.tabAreas[this.currIndex].width as number) / this.viewItemWidth;
      const { position, width } = this.tabAreas[this.currIndex];
      if (direction == _SwipeDirection.Left) {
        animateTo({ duration: 325, curve: Curve.EaseInOut }, () => {
          this.underlineXOffset = (position.x as number) + ratio * offset;
        })
      } else if (direction == _SwipeDirection.Right) {
        animateTo({ duration: 325, curve: Curve.EaseInOut }, () => {
          this.underlineXOffset = (position.x as number) - ratio * offset;
        })
      }
    } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      let currIndex: number = this.currIndex;
      const scrollMinRatio: number = 1 / 3;
      const swiperMinSpeed: number = 100 / Math.pow(10, 9);
      const swiperVal: _SwipeValue = this.calcSwiperValue(this.startTouchEvent, event);
      if (swiperVal.direction != _SwipeDirection.None) {
        const swiperSpeed: number = swiperVal.offset / swiperVal.time;
        if (swiperSpeed > swiperMinSpeed) {
          if (swiperVal.direction == _SwipeDirection.Left) {
            currIndex = currIndex + 1;
          } else if (swiperVal.direction == _SwipeDirection.Right) {
            currIndex = currIndex - 1;
          }
        } else if (swiperVal.direction == _SwipeDirection.Left || swiperVal.direction == _SwipeDirection.Right) {
          let xOffset: number = this.viewScroller.currentOffset().xOffset;
          if (swiperVal.direction == _SwipeDirection.Right) {
            let scrollMinVal = (1 - scrollMinRatio) * this.viewItemWidth;
            currIndex = Math.floor((xOffset + scrollMinVal) / this.viewItemWidth);
          } else if (swiperVal.direction == _SwipeDirection.Left) {
            let scrollMinVal: number = scrollMinRatio * this.viewItemWidth;
            currIndex = Math.floor((xOffset + scrollMinVal) / this.viewItemWidth);
          }
        }
      }

      if (currIndex < 0) {
        currIndex = 0;
      } else if (currIndex > this.tabCount - 1) {
        currIndex = this.tabCount - 1;
      }
      this.scrollToByIndex(currIndex);
      let timer = setTimeout(() => {
        this.viewState[this.currIndex] = false;
        this.viewState[currIndex] = true;
        clearTimeout(timer);
      }, 325);
      this.currIndex = currIndex;
    }
  }

  calcSwiperValue(start: TouchEvent, end: TouchEvent): _SwipeValue {
    const endObject: TouchObject = end.touches[0];
    const startObject: TouchObject = start.touches[0];
    const swiperX: number = endObject.screenX - startObject.screenX;
    const swiperY: number = endObject.screenY - startObject.screenY;
    let offset: number = 0;
    let direction: _SwipeDirection = _SwipeDirection.None;
    if (Math.abs(swiperX) > Math.abs(swiperY)) {
      direction = swiperX > 0 ? _SwipeDirection.Right : _SwipeDirection.Left;
      offset = Math.abs(swiperX);
    } else {
      direction = swiperY > 0 ? _SwipeDirection.Down : _SwipeDirection.Up;
      offset = Math.abs(swiperY);
    }
    return { direction, offset, time: end.timestamp - start.timestamp };
  }

  getTextColor(index: number): ResourceColor {
    return this.currIndex == index ? this.labelColor : this.unselectedLabelColor;
  }

  getLabelWidth(): number {
    return this.viewItemWidth / this.tabCount;
  }

  getViewState(index: number): Visibility {
    return this.viewState[index] ? Visibility.Visible : Visibility.Hidden;
  }

  @Builder _defaultViewBuilder() {
    Text('')
  }

  build() {
    Column() {
      /**
       * Tabs
       */
      Scroll(this.tabScroller) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Row() {
            ForEach(this.tabs, (item: TabInterface, index: number) => {
              Column() {
                Text(item.text)
                  .fontColor(this.getTextColor(index))
                  .fontSize(this.labelSize)
                  .fontWeight(FontWeight.Medium);
              }
              .padding(this.labelPadding)
              .onClick(() => {
                this.currIndex = index;
                this.scrollToByIndex(index);
              })
              .onAreaChange((oldVal, newVal) => {
                this.tabAreas[index] = newVal;
                if (index === 0) {
                  this.underlineWidth = newVal.width as number;
                }
              });
            }, (item, index) => `TABBAR_ITEM_${index}`);
          }
          .height('100%')
          .justifyContent(FlexAlign.Start);
          //
          Column()
            .height(4)
            .width(this.underlineWidth)
            .backgroundColor(this.underlineColor)
            .borderRadius(4)
            .offset({ x: this.underlineXOffset });
        }
      }
      .height(65)
      .width('100%')
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .align(Alignment.Start);
      /**
       *  View
       */
      Scroll(this.viewScroller) {
        Row({ space: 0 }) {
          ForEach(this.tabs, (item: TabInterface, index: number) => {
            Column() {
              Column() {
                this.viewBuilder(item, index);
              }.visibility(this.viewState[index] ? Visibility.Visible : Visibility.None);
            }.width('100%').height('100%');
          }, (item: TabInterface, index: number) => `TABBAR_VIEW_ITEM_${index}`);
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .scrollable(ScrollDirection.Horizontal)
      .onTouch((event?: TouchEvent) => {
        this.handleTouchEvent(event);
      })
      .onAreaChange((oldVal: Area, newVal: Area) => {
        this.viewItemWidth = (newVal.width as number);
        this.onViewAreaChange(oldVal, newVal);
      });
    }
  }
}

