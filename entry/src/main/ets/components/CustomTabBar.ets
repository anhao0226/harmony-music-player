/**
 * TabBarItemInterface
 */
export interface TabBarItemInterface {
  getText: () => string;
}

export interface MenuItemInterface {
  text: string;
  icon?: Resource;
  onTap?: () => void;
}

/**
 * CustomTabBar
 */
@Component
export struct CustomTabBar {
  @State currentIndex: number = 0;
  @State barWidth: number = 0;
  @BuilderParam viewBuilder: (item: TabBarItemInterface, index: number) => void;
  @BuilderParam menuBuilder?: () => void = this._defaultMenuBuilder;

  @Builder _defaultMenuBuilder() {
  }
  //
  @Link tabs: TabBarItemInterface[];
  @Link items: TabBarItemInterface[];
  private itemCount: number = 0;
  private itemAreaList: Area[] = [];
  private itemAnimation = { duration: 325, curve: Curve.EaseInOut }
  //
  private barHeight: number = 46;
  private scroller = new Scroller();
  private bgColor: string = '#FFFFFF';
  //
  private selectedColor: string = '#A6C2BE';
  private unselectedColor: string = '#E5000000';
  private fontSize: number = 18;
  // underline
  @State underlineColor: string = '#A6C2BE';
  @State underlineHeight: number = 3;
  @State underlineXOffset: number = 0;
  @State underlineWidth: number = 0;

  aboutToAppear() {
    console.log('CustomTabBar aboutToAppear');
    this.itemCount = this.items.length;
    this.itemAreaList = new Array(this.itemCount).fill(null);
  }

  handleScrollTo() {
    if (this.currentIndex < this.items.length && this.itemAreaList[this.currentIndex]) {
      animateTo(this.itemAnimation, () => {
        const {  width, position } = this.itemAreaList[this.currentIndex];
        this.underlineWidth = width as number;
        this.underlineXOffset = position.x as number;
      })
    }
  }

  onItemAreaChange(_: Area, newVal: Area, index: number) {
    this.itemAreaList[index] = newVal;
    if (index === 0) {
      this.underlineWidth = newVal.width as number;
    }
  }

  getTextColor(index: number): string {
    return this.currentIndex === index ? this.selectedColor : this.unselectedColor;
  }

  build() {
    Column() {
      /**
       * Menus
       */
      Row() {
        Scroll(this.scroller) {
          Column() {
            Row({ space: 24 }) {
              ForEach(this.items, (item: TabBarItemInterface, index: number) => {
                Column() {
                  Text(item.getText())
                    .fontSize(this.fontSize)
                    .fontColor(this.getTextColor(index)).animation(this.itemAnimation)
                }
                .onClick(() => {
                  this.currentIndex = index;
                  this.handleScrollTo();
                })
                .onAreaChange((oldVal: Area, newVal: Area) => {
                  this.onItemAreaChange(oldVal, newVal, index);
                });
              }, (_, index) => `${index}_TAB_ITEM`);
            }.height(this.barHeight - this.underlineHeight)
            // underline
            _UnderlineComponent({
              compHeight: this.underlineHeight,
              compWidth: this.underlineWidth,
              fillColor: this.underlineColor,
            }).offset({ x: this.underlineXOffset });

          }
          .height(this.barHeight)
          .alignItems(HorizontalAlign.Start);
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off).layoutWeight(1);
        //

        if (this.menuBuilder) this.menuBuilder();

      }.width('100%').justifyContent(FlexAlign.Center);

      /**
       * _TabBarView
       */
      _TabBarView({
        items: $items,
        sharedIndex: this.currentIndex,
        viewBuilder: this.viewBuilder,
        onViewChange: (index: number) => {
          this.currentIndex = index;
          this.handleScrollTo();
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
  @Link @Watch('handleItemsChange') items: any[];
  @Prop @Watch('handleShareIndexChange') sharedIndex: number;
  @State currentIndex: number = 0;
  @State viewStateList: boolean[] = [];
  @BuilderParam viewBuilder: (item: TabBarItemInterface, index: number) => void;
  //
  private scroller: Scroller = new Scroller()
  private itemViewWidth: number = 0;
  //
  private touchUpOffsetX: number = 0;
  private touchDownOffsetX: number = 0;
  private checkSwipeGesture: boolean = false;
  //
  private onViewChange: (index: number) => void;
  private scrollStopEvents: (() => void)[] = [];

  aboutToAppear() {
    this.initViewState();
  }

  updateCurrentIndex(index: number) {
    if (index === this.currentIndex) return;
    // 渲染对应下标View
    this.viewStateList[index] = true;
    // 添加滑动结束执行的函数且销毁上一显示View
    const _callback = (_index: number) => () => (this.viewStateList[_index] = false);
    this.scrollStopEvents.push(_callback(this.currentIndex))
    // 滑动到指定下标View
    this.scrollToIndexView(index);
    // 更新currentIndex
    this.currentIndex = index;
    if (this.onViewChange) this.onViewChange(index);
  }

  handleTouchEvent(event: TouchEvent) {
    console.log('handleTouchEvent');
    if (event.type === TouchType.Down) {
      this.touchDownOffsetX = event.touches[0].screenX;
    } else if (event.type === TouchType.Move) {
    } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      const { xOffset } = this.scroller.currentOffset();
      const minChangePageVal: number = 2 * this.itemViewWidth / 3;
      const index: number = Math.floor((xOffset + minChangePageVal) / this.itemViewWidth);
      if (index === this.currentIndex) {
        this.scrollToIndexView(index);
        this.touchUpOffsetX = event.touches[0].screenX;
        this.checkSwipeGesture = true;
      } else this.updateCurrentIndex(index);
    }
  }

  scrollToIndexView(index: number) {
    const xOffset = index * this.itemViewWidth
    this.scroller.scrollTo({
      yOffset: 0,
      xOffset: xOffset,
      animation: { duration: 325, curve: Curve.EaseInOut }
    });
  }

  handleSwipeGesture(event: GestureEvent) {
    console.log('handleSwipeGesture');
    if (this.checkSwipeGesture) {
      const swipeX = this.touchUpOffsetX - this.touchDownOffsetX;
      const index = swipeX < 0 ? (this.currentIndex + 1) : (this.currentIndex - 1);
      if (index >= 0 && index !== this.currentIndex) {
        this.updateCurrentIndex(index);
      }
      this.checkSwipeGesture = false;
    }
  }

  handleScrollAreaChange(oldVal: Area, newVal: Area) {
    this.itemViewWidth = newVal.width as number;
  }

  handleShareIndexChange() {
    this.updateCurrentIndex(this.sharedIndex);
  }

  initViewState() {
    const itemCount = this.items.length;
    if (itemCount > 0) {
      this.viewStateList = new Array(itemCount).fill(false, 0, itemCount);
      this.viewStateList[this.currentIndex] = true;
    }
  }

  handleItemsChange() {
    this.initViewState();
  }

  build() {
    Scroll(this.scroller) {
      Row() {
        ForEach(this.items, (_, index) => {
          Column() {
            if (this.viewStateList[index]) {
              this.viewBuilder(this.items[index], index);
            }
          }.width('100%').height('100%');
        }, (_, index) => `${index}_TAB_VIEW`);
      }
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .onAreaChange((oldVal: Area, newVal: Area) => this.handleScrollAreaChange(oldVal, newVal))
    .edgeEffect(EdgeEffect.None)
    .scrollable(ScrollDirection.Horizontal)
    .onTouch((event: TouchEvent) => this.handleTouchEvent(event))
    .parallelGesture(SwipeGesture({ direction: SwipeDirection.Horizontal })
      .onAction((event: GestureEvent) => this.handleSwipeGesture(event)))
    .onScrollStop(() => {
      this.scrollStopEvents.forEach((callback) => callback())
      console.log(JSON.stringify(this.viewStateList));
      this.scrollStopEvents = [];
    })
  }
}

@Component
struct _UnderlineComponent {
  @Prop fillColor: string;
  @Prop compWidth: number;
  @Prop compHeight: number;

  build() {
    Row().width(this.compWidth).height(this.compHeight).backgroundColor(this.fillColor);
  }
}

@Component
struct UnderlineComponent {
  @Prop _color: string;
  @Prop @Watch('onLineWidthChange') _width: number;
  @Prop _height: number;

  //用来配置CanvasRenderingContext2D对象的参数，包括是否开启抗锯齿，true表明开启抗锯齿。
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  //用来创建CanvasRenderingContext2D对象，通过在canvas中调用CanvasRenderingContext2D对象来绘制。
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  onLineWidthChange() {
    this.drawLine();
  }

  drawLine() {
    this.context.beginPath()
    this.context.moveTo(0, 0)
    this.context.lineTo(this._width, 0)
    this.context.lineCap = 'round'
    this.context.lineWidth = this._height;
    this.context.strokeStyle = this._color;
    this.context.stroke()
  }

  build() {
    Row().width(this._width).height(this._height).backgroundColor(this._color);
  }
}