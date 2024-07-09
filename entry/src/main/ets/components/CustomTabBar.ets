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
 */

@Component
export struct CustomTabBar {
  @Link @Watch('onTabsChange') tabs: TabBarDataInterface[];
  private onViewSize: (newVal: Area) => void;
  @BuilderParam viewBuilder: (data: TabViewBuildData) => void;
  @BuilderParam menuBuilder?: () => void = this._defaultMenuBuilder;

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
  @State underlineHeight: number = 3;
  @State underlineXOffset: number = 0;
  @State underlineWidth: number = 0;
  protected tabCount: number = 0;
  protected tabAreaList: Area[] = [];
  protected scroller = new Scroller();
  @State @Watch('onCurrIndexChange') currIndex: number = 0;

  onCurrIndexChange() {
    this.handleScrollTo();
  }

  onTabsChange(){
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
      /**
       * TabBars
       */
      Row() {
        Scroll(this.scroller) {
          Column() {
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
            .height(this.barHeight - this.underlineHeight)
            .justifyContent(this.tabAlign)
            .width('100%');
            // underline
            _UnderlineComponent({
              compHeight: this.underlineHeight,
              compWidth: this.underlineWidth,
              fillColor: this.underlineColor,
            }).offset({ x: this.underlineXOffset });
          }
          .width('100%')
          .height(this.barHeight)
          .alignItems(HorizontalAlign.Start);
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
        currIndex: $currIndex,
        viewBuilder: this.viewBuilder,
        onViewSwiper: (ratio: number, swiperVal: number) => {
          //
          const area: Area = this.tabAreaList[this.currIndex];
          let offsetX: number = area.position.x as number;
          //
          console.log(`swiperVal: ${swiperVal}`);
          if (swiperVal <= 0 && this.currIndex < this.tabCount - 1) {

            const nextIndex: number = this.currIndex + 1;
            const nextArea: Area = this.tabAreaList[nextIndex];
            const width: number = (nextArea.position.x as number - (area.position.x as number));
            this.underlineXOffset = offsetX + width * ratio;
            console.log(`width: ${width}`);
            console.log(`offsetX: ${offsetX}`);
          } else if (this.currIndex > 0 && swiperVal > 0) {
            const prevIndex: number = this.currIndex - 1;
            const prevArea: Area = this.tabAreaList[prevIndex];
            const width: number = (area.position.x as number) - (prevArea.position.x as number);
            console.log(`width: ${width}`);
            console.log(`offsetX: ${offsetX}`);
            this.underlineXOffset = (offsetX + width) - width * (1 + ratio);
          }

        },
        onViewSizeChange: (oldVal: Area, newVal: Area) => {
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
  @Link @Watch('onCurrIndexChange') currIndex: number;
  @BuilderParam viewBuilder: (data: TabViewBuildData) => void;
  private onViewSizeChange?: (oldVal: Area, newVal: Area) => void;
  private onViewSwiper?: (ratio: number, swiperVal: number) => void;
  //
  @State viewStateList: boolean[] = [];
  protected prevIndex: number = 0;
  protected tabsCount: number = 0;
  protected viewArea: Area = null;
  protected scroller: Scroller = new Scroller()
  protected touchDownOffsetX: number = 0;
  protected scrollStopEvents: (() => void)[] = [];
  protected startSwiperTime: number = 0;
  protected minSwiperSpeed: number = 100 / 1000000000;
  protected timer: number = -1;
  protected animationDuration: number = 325;
  protected viewWidth: number = 0;

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

  checkSwiperEvent(event: TouchEvent): boolean {
    let hasSwiperEvent: boolean = false;
    const minSwiperSpeed: number = 100 / 1000000000;
    const timeDiff: number = event.timestamp - this.startSwiperTime;
    const touchUpOffsetX: number = event.touches[0].screenX;
    const swipeXDiff: number = touchUpOffsetX - this.touchDownOffsetX;
    const swiperSpeed: number = Math.abs(swipeXDiff / timeDiff);
    if (Math.abs(swipeXDiff) > 100 && swiperSpeed > minSwiperSpeed) {
      hasSwiperEvent = true;
      const currIndex_ = swipeXDiff < 0 ? (this.currIndex + 1) : (this.currIndex - 1);
      if (currIndex_ >= 0 && currIndex_ < this.tabsCount && currIndex_ !== this.currIndex) {
        this.currIndex = currIndex_;
      }
    }
    return hasSwiperEvent;
  }

  handleTouchEvent(event: TouchEvent) {
    if (event.type === TouchType.Down) {
      this.touchDownOffsetX = event.touches[0].screenX;
      this.startSwiperTime = event.timestamp;
    } else if (event.type === TouchType.Move) {
      if (this.onViewSwiper) {
        const touchUpOffsetX: number = event.touches[0].screenX;
        const swipeXDiff: number = touchUpOffsetX - this.touchDownOffsetX;
        this.onViewSwiper(Math.abs(swipeXDiff / this.viewWidth), swipeXDiff);
      }
    } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      if (!this.checkSwiperEvent(event)) {
        const { xOffset } = this.scroller.currentOffset();
        const minChangePageVal: number = this.viewWidth * (2 / 3);
        const modVal: number = xOffset % this.viewWidth;
        let currIndex_: number = modVal > minChangePageVal ? this.currIndex + 1 : this.currIndex;
        if (currIndex_ === this.currIndex) {
          this.scrollToIndexView(currIndex_);
        } else if (currIndex_ > 0 && currIndex_ < this.tabsCount) {
          this.currIndex = currIndex_;
        }
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
    if (this.onViewSizeChange) this.onViewSizeChange(oldVal, newVal);
    this.viewArea = newVal;
    this.viewWidth = newVal.width as number;
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
          }
          .width('100%')
          .height('100%')
        }, (_, index) => `TAB_VIEW_${index}`);
      }
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .onAreaChange((oldVal: Area, newVal: Area) => this.handleViewAreaChange(oldVal, newVal))
    .edgeEffect(EdgeEffect.Spring)
    .scrollable(ScrollDirection.Horizontal)
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