export interface MenuItemInterface {
  text: string;
  icon?: Resource;
  onTap?: () => void;
}

export interface TabBarDataInterface {
  text: string
  icon?: Resource
}

export interface TabViewBuildData {
  index: number,
  area?: Area,
  item: TabBarDataInterface
}
/**
 * CustomTabBar
 * @deprecated
 */
@Component
export struct CustomTabBar {
  @Link @Watch('onTabsChange') tabs: TabBarDataInterface[];
  private onViewSize: (newVal: Area) => void;
  @BuilderParam viewBuilder: (data: TabViewBuildData) => void;
  @BuilderParam menuBuilder?: () => void = this._defaultMenuBuilder;
  @Provide('TabBarViewArea') tabBarViewArea: Area = null;

  //
  @State barWidth: number = 0;

  @Builder _defaultMenuBuilder() {
  }
  //
  private tabAlign: FlexAlign = FlexAlign.Start;
  private barAnimation = { duration: 325, curve: Curve.EaseInOut }
  private barHeight: number = 46;
  private bgColor: string = '#FFFFFF';
  private selectedColor: string = '#A6C2BE';
  private unselectedColor: string = '#E5000000';
  private fontSize: number = 18;
  private barPadding: Padding | Length = 0;
  private contentPadding: Padding | Length = 0;
  private showUnderline: boolean = true;
  // underline
  @State underlineColor: string = '#A6C2BE';
  @State underlineXOffset: number = 0;
  @State underlineWidth: number = 0;
  protected tabCount: number = 0;
  protected tabAreaList: Area[] = [];
  protected scroller = new Scroller();
  @State @Watch('onCurrIndexChange') currIndex: number = 0;

  onCurrIndexChange() {
    this.handleScrollTo();
  }

  onTabsChange() {
    this.tabCount = this.tabs.length;
    this.tabAreaList = new Array(this.tabCount).fill(null, 0, this.tabCount);
  }

  aboutToAppear() {
    this.onTabsChange();
  }

  handleScrollTo() {
    if (this.currIndex < this.tabs.length && this.tabAreaList[this.currIndex]) {
      animateTo(this.barAnimation, () => {
        const {  width, position } = this.tabAreaList[this.currIndex];
        this.underlineWidth = width as number;
        this.underlineXOffset = position.x as number;
      })
    }
  }

  onItemAreaChange(_: Area, newVal: Area, index: number) {
    this.tabAreaList[index] = newVal;
    if (index === 0) {
      this.underlineWidth = newVal.width as number;
      this.underlineXOffset = newVal.position.x as number;
    }
  }

  getColor(index: number): string {
    return this.currIndex === index ? this.selectedColor : this.unselectedColor;
  }

  build() {
    Column() {
      Text(this.underlineXOffset.toString());
      /**
       * TabBars
       */
      Row() {
        Scroll(this.scroller) {
          Stack({ alignContent: Alignment.TopStart }) {
            Row({ space: 24 }) {
              ForEach(this.tabs, (item: TabBarDataInterface, index: number) => {
                Column() {
                  if (item.icon) {
                    Image(item.icon).width(34).fillColor(this.getColor(index))
                  }
                  Text(item.text)
                    .fontSize(this.fontSize)
                    .fontColor(this.getColor(index)).animation(this.barAnimation)
                }
                .onClick(() => {
                  this.currIndex = index;
                  this.handleScrollTo();
                })
                .onAreaChange((oldVal: Area, newVal: Area) => {
                  this.onItemAreaChange(oldVal, newVal, index);
                });
              }, (_, index) => `${index}_TAB_ITEM`);
            }
            .height(this.barHeight)
            .justifyContent(this.tabAlign)
            .width('100%');
            // underline
            _UnderlineComponent({
              compHeight: 2,
              compWidth: this.underlineWidth,
              fillColor: this.underlineColor,
            }).offset({ x: this.underlineXOffset });
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off).layoutWeight(1);
        if (this.menuBuilder) this.menuBuilder();
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding(this.barPadding);
      /**
       * _TabBarView
       */
      _TabBarView({
        tabs: $tabs,
        currIndex: this.currIndex,
        viewBuilder: (data) => this.viewBuilder(data),
        onViewChange: (index: number) => {
          this.currIndex = index;
        },
        onViewTouchEnd: () => {
          this.handleScrollTo();
        },
        onViewScroll: (ratio: number, swiperVal: number) => {
          const area: Area = this.tabAreaList[this.currIndex];
          let offsetX: number = area.position.x as number;
          if (swiperVal <= 0 && this.currIndex < this.tabCount - 1) {
            const nextIndex: number = this.currIndex + 1;
            const nextArea: Area = this.tabAreaList[nextIndex];
            const width: number = (nextArea.position.x as number - (area.position.x as number));
            this.underlineXOffset = offsetX + width * ratio;
          } else if (this.currIndex > 0 && swiperVal > 0) {
            const prevIndex: number = this.currIndex - 1;
            const prevArea: Area = this.tabAreaList[prevIndex];
            const width: number = (area.position.x as number) - (prevArea.position.x as number);
            this.underlineXOffset = (offsetX + width) - width * (1 + ratio);
          }

        },
        onViewAreaChange: (oldVal: Area, newVal: Area) => {
          this.tabBarViewArea = newVal;
          if (this.onViewSize) this.onViewSize(newVal);
        }
      });
    }
  }
}

/**
 * _TabBarView
 */
@Component
struct _TabBarView {
  @Link @Watch('onTabsChange') tabs: any[];
  @Prop @Watch('onCurrIndexChange') currIndex: number;
  @BuilderParam viewBuilder: (data: TabViewBuildData) => void;
  private onViewAreaChange?: (oldVal: Area, newVal: Area) => void;
  private onViewScroll?: (ratio: number, swiperVal: number) => void;
  private onViewChange?: (index: number) => void;
  private onViewTouchEnd?: () => void;
  //
  @State viewStateList: boolean[] = [];
  private prevIndex: number = 0;
  private tabsCount: number = 0;
  private viewArea: Area = null;
  private scroller: Scroller = new Scroller()
  private touchDownOffsetX: number = 0;
  private scrollStopEvents: (() => void)[] = [];
  private startSwiperTime: number = 0;
  private minSwiperSpeed: number = 100 / 1000000000;
  private timer: number = -1;
  private animationDuration: number = 325;
  private viewWidth: number = 0;
  private minChangePageVal: number = 0;

  aboutToAppear() {
    this.onTabsChange();
  }

  aboutToDisappear() {
    clearTimeout(this.timer);
  }

  onTabsChange() {
    this.tabsCount = this.tabs.length;
    if (this.tabsCount > 0) {
      this.viewStateList = new Array(this.tabsCount).fill(false, 0, this.tabsCount);
      this.viewStateList[this.currIndex] = true;
    }
  }

  onCurrIndexChange() {
    this.timer = setTimeout(() => {
      this.viewStateList[this.currIndex] = true;
      clearTimeout(this.timer);
    }, this.animationDuration);
    this.scrollToIndexView(this.currIndex);
    this.prevIndex = this.currIndex;
  }

  checkSwiperGesture(event: TouchEvent): boolean {
    let hasSwiperEvent: boolean = false;
    const timeDiff: number = event.timestamp - this.startSwiperTime;
    const touchUpOffsetX: number = event.touches[0].screenX;
    const swipeXDiff: number = touchUpOffsetX - this.touchDownOffsetX;
    const swiperSpeed: number = Math.abs(swipeXDiff / timeDiff);
    if (Math.abs(swipeXDiff) > 100 && swiperSpeed > this.minSwiperSpeed) {
      hasSwiperEvent = true;
      const currIndex_ = swipeXDiff < 0 ? (this.currIndex + 1) : (this.currIndex - 1);
      if (currIndex_ >= 0 && currIndex_ < this.tabsCount) {
        this.onViewChange(currIndex_);
      }
    }
    return hasSwiperEvent;
  }

  handleTouchEvent(event: TouchEvent) {
    if (event.type === TouchType.Down) {
      this.touchDownOffsetX = event.touches[0].screenX;
      this.startSwiperTime = event.timestamp;
    } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      if (!this.checkSwiperGesture(event)) {
        const { xOffset } = this.scroller.currentOffset();
        let currIndex_: number = Math.floor((xOffset + this.minChangePageVal) / this.viewWidth);
        if (currIndex_ === this.currIndex) {
          this.onViewTouchEnd();
          this.scrollToIndexView(currIndex_);
        } else if (currIndex_ > 0 && currIndex_ < this.tabsCount) {
          this.onViewChange(currIndex_);
        }
      }
    } else {
      if (this.onViewScroll) {
        const touchUpOffsetX: number = event.touches[0].screenX;
        const swipeXDiff: number = touchUpOffsetX - this.touchDownOffsetX;
        this.onViewScroll(Math.abs(swipeXDiff / this.viewWidth), swipeXDiff);
      }
    }
  }

  scrollToIndexView(currIndex: number) {
    this.scroller.scrollTo({
      yOffset: 0,
      xOffset: currIndex * this.viewWidth,
      animation: { duration: this.animationDuration, curve: Curve.Ease },
    });
  }

  handleViewAreaChange(oldVal: Area, newVal: Area) {
    this.viewArea = newVal;
    this.viewWidth = newVal.width as number;
    this.minChangePageVal = this.viewWidth * (2 / 3);
    if (this.onViewAreaChange) this.onViewAreaChange(oldVal, newVal);
  }

  build() {
    Scroll(this.scroller) {
      Row() {
        ForEach(this.tabs, (_, index) => {
          Column() {
            Column() {
              this.viewBuilder({
                index: index,
                item: this.tabs[index],
                area: this.viewArea,
              });
            }.visibility(this.viewStateList[index] ? Visibility.Visible : Visibility.None);
          }.width('100%').height('100%');
        }, (_, index) => `TAB_VIEW_${index}`);
      }
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .onAreaChange((oldVal: Area, newVal: Area) => this.handleViewAreaChange(oldVal, newVal))
    .edgeEffect(EdgeEffect.Spring)
    .scrollable(ScrollDirection.Horizontal)
    .onScroll((xOffset: number, yOffset: number) => {

    })
    .onTouch((event: TouchEvent) => this.handleTouchEvent(event));
  }
}

@Component
struct _UnderlineComponent {
  @Prop fillColor: string;
  @Prop compWidth: number;
  @Prop compHeight: number;

  build() {
    Row()
      .width(this.compWidth)
      .height(this.compHeight)
      .backgroundColor(this.fillColor)
      .borderRadius(this.compHeight);
  }
}