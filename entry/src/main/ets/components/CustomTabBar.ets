/**
 * TabBarItemInterface
 */
export interface TabBarItemInterface {
  getText: () => string;
}

/**
 * CustomTabBar
 */
@Component
export struct CustomTabBar {
  @State currentIndex: number = 0;
  @State barWidth: number = 0;
  @BuilderParam viewBuilder: (item: TabBarItemInterface, index: number) => void;
  //
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
  private underlineHeight: number = 3;
  @State underlineXOffset: number = 0;
  @State underlineWidth: number = 0;

  aboutToAppear() {
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

  onItemAreaChange(oldVal: Area, newVal: Area, index: number) {
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
            }.height(this.barHeight)
            // underline
            UnderlineCanvas({
              lineHeight: 5,
              lineWidth: this.underlineWidth,
              lineColor: this.underlineColor,
            }).offset({ x: this.underlineXOffset })

          }
          .height(this.barHeight + this.underlineHeight + 3)
          .alignItems(HorizontalAlign.Start);
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off);
      }.width('100%').justifyContent(FlexAlign.Center).backgroundColor(this.bgColor);

      /**
       * _TabBarView
       */
      _TabBarView({
        items: $items,
        currentIndex: this.currentIndex,
        viewBuilder: this.viewBuilder,
        onViewChange: (index: number) => {
          this.currentIndex = index;
          this.handleScrollTo();
        }
      }).layoutWeight(1)
    }
  }
}

/**
 * _TabBarView
 */
@Component
struct _TabBarView {
  @Prop @Watch('onIndexChange') currentIndex: number;
  @BuilderParam viewBuilder: (item: TabBarItemInterface, index: number) => void;
  @Link items: any[];
  private scroller: Scroller = new Scroller()
  private itemViewWidth: number = 0;
  private touchUpOffsetX: number = 0;
  private touchDownOffsetX: number = 0;
  private checkSwipeGesture: boolean = false;
  private itemAnimation = { duration: 325, curve: Curve.EaseInOut }
  private onViewChange: (index: number) => void;

  handleTouchEvent(event: TouchEvent) {
    if (event.type === TouchType.Down) {
      this.touchDownOffsetX = event.touches[0].screenX;
    } else if (event.type === TouchType.Move) {
    } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      const { xOffset } = this.scroller.currentOffset();
      const currentIndex = Math.floor((xOffset + (2 * this.itemViewWidth / 3)) / this.itemViewWidth);
      const dx = currentIndex * this.itemViewWidth;
      this.handleScrollTo(dx);
      if (currentIndex === this.currentIndex) {
        this.touchUpOffsetX = event.touches[0].screenX;
        this.checkSwipeGesture = true
      }
      this.updateCurrentIndex(currentIndex);
    }
  }

  handleSwipeGesture(event: GestureEvent) {
    if (this.checkSwipeGesture) {
      const swipeX = this.touchUpOffsetX - this.touchDownOffsetX;
      const currentIndex = swipeX < 0 ? (this.currentIndex + 1) : (this.currentIndex - 1);
      const dx = currentIndex * this.itemViewWidth
      this.handleScrollTo(dx);
      this.updateCurrentIndex(currentIndex);
    }
    this.checkSwipeGesture = false;
  }

  handleScrollTo(xOffset: number) {
    this.scroller.scrollTo({ yOffset: 0, xOffset: xOffset, animation: this.itemAnimation });
  }

  updateCurrentIndex(index: number) {
    this.currentIndex = index;
    if (this.onViewChange) this.onViewChange(index);
  }

  handleScrollAreaChange(oldVal: Area, newVal: Area) {
    this.itemViewWidth = newVal.width as number;
  }

  onIndexChange() {
    const dx = this.currentIndex * this.itemViewWidth
    this.handleScrollTo(dx);
  }

  build() {
    Scroll(this.scroller) {
      Row() {
        ForEach(this.items, (_, index) => {
          Column() {
            if (this.currentIndex === index) {
              this.viewBuilder(this.items[index], index);
            }
          }.width('100%').height('100%');
        }, (_, index) => `${index}_TAB_VIEW`);
      }.layoutWeight(1);
    }
    .scrollBar(BarState.Off)
    .onAreaChange((oldVal: Area, newVal: Area) => this.handleScrollAreaChange(oldVal, newVal))
    .edgeEffect(EdgeEffect.None)
    .scrollable(ScrollDirection.Horizontal)
    .onTouch((event: TouchEvent) => this.handleTouchEvent(event))
    .parallelGesture(SwipeGesture({ direction: SwipeDirection.Horizontal })
      .onAction((event: GestureEvent) => this.handleSwipeGesture(event)));
  }
}

@Component
struct UnderlineCanvas {
  @Prop lineColor: string;
  @Prop @Watch('onLineWidthChange') lineWidth: number;
  @Prop lineHeight: number;

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
    this.context.lineTo(this.lineWidth, 0)
    this.context.lineCap = 'round'
    this.context.lineWidth = this.lineHeight;
    this.context.strokeStyle = this.lineColor;
    this.context.stroke()
  }

  build() {
    Canvas(this.context)
      .width(this.lineWidth)
      .height(this.lineHeight)
      .onReady(() => {
        this.drawLine();
      });
  }
}