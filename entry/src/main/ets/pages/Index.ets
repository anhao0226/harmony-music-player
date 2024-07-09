import { AudioService } from '../common/utils/AudioService';
import { SearchPage } from './SearchPage';
import { HomePage } from './HomePage';
import { MvComponent } from './MvPage';

@Entry
@Component
struct Index {
  private readonly TAG = 'INDEX';
  @State currIndex: number = 0;

  onPageShow() {
    AudioService.getInstance();
  }

  getColor(index: number): string {
    return this.currIndex == index ? '#99000000' : '#66000000'
  }

  @Builder TabBuilder(iconData: Resource, text: string, targetIndex: number) {
    Column() {
      Image(iconData).width(32).fillColor(this.getColor(targetIndex));
      Text(text).fontColor(this.getColor(targetIndex));
    }
  }

  build() {
    Tabs({ barPosition: BarPosition.Start, index: 0 }) {
      TabContent() {
        HomePage();
      }.tabBar(this.TabBuilder($r('app.media.ic_public_home_line'), 'Home', 0));
      TabContent() {
        SearchPage();
      }.tabBar(this.TabBuilder($r('app.media.ic_public_menu_search_line'), 'Search', 1));
      TabContent() {
        MvComponent();
      }.tabBar(this.TabBuilder($r('app.media.ic_public_movie_line'), 'Mv', 2))
    }
    .vertical(true)
    .barWidth(100)
    .barHeight(300)
    .onChange((index: number) => {
      this.currIndex = index;
    })
    .scrollable(false)
    .backgroundColor('#F1F3F5');

  }

  pageTransition() {
    PageTransitionEnter({ duration: 425, curve: Curve.Smooth, type: RouteType.Pop });
    PageTransitionExit({ duration: 425, curve: Curve.Smooth, type: RouteType.Push });
  }
}