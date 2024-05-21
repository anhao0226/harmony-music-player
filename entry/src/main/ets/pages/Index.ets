import UIAbility from '@ohos.app.ability.UIAbility';
import { AudioService } from '../common/utils/AudioService';
import { PlayControlComponent } from '../components/PlayControlComponent';
import { TabItemComponent } from '../components/TabItemComponent';
import { CategoryModel, getPlaylistCategory, } from '../view_models/playlist_song_model';
import window from '@ohos.window';
import router from '@ohos.router';
import { CustomTabBar } from '../components/CustomTabBar';

@Entry
@Component
struct Index {
  private readonly TAG = 'INDEX';
  @State currentIndex: number = 0;
  @State isLoading: boolean = false;
  @State navBgColor: string = '#ffffff';
  private context: Context = getContext(this);
  private tabsController: TabsController = new TabsController();
  @State categories: CategoryModel[] = [];
  @State tabItemLoadStateArr: boolean[] = [];
  @StorageLink('WINDOW_STAGE') windowStage: window.WindowStage = null;
  private subWindowClass: window.Window = null;

  onPageShow() {
    this.initData()
  }

  showSubWindow() {
    this.windowStage?.createSubWindow("myCustomDialog", (err, data) => {


      if (err.code) {
        console.error('Failed to create the subwindow. Cause: ' + JSON.stringify(err));
        return;
      }
      this.subWindowClass = data;
      console.info('Succeeded in creating the subwindow. Data: ' + JSON.stringify(data));
      // 2.子窗口创建成功后，设置子窗口的位置、大小及相关属性等。
      this.subWindowClass.moveWindowTo(0, 0, (err) => {
        if (err.code) {
          console.error('Failed to move the window. Cause:' + JSON.stringify(err));
          return;
        }
        console.info('Succeeded in moving the window.');
      });

      this.subWindowClass.resize(1000, 500, (err) => {
        if (err.code) {
          console.error('Failed to change the window size. Cause:' + JSON.stringify(err));
          return;
        }
        console.info('Succeeded in changing the window size.');
      })

      // 3.为子窗口加载对应的目标页面。
      this.subWindowClass.setUIContent("pages/setting", (err) => {
        if (err.code) {
          console.error('Failed to load the content. Cause:' + JSON.stringify(err));
          return;
        }
        console.info('Succeeded in loading the content.');
        // 3.显示子窗口。
        this.subWindowClass.showWindow((err) => {
          if (err.code) {
            console.error('Failed to show the window. Cause: ' + JSON.stringify(err));
            return;
          }
          console.info('Succeeded in showing the window.');
        });
        this.subWindowClass.setWindowBackgroundColor('#E8A027')
      });


    })
  }

  async initData() {
    AudioService.getInstance();
    this.categories = await getPlaylistCategory();
    this.tabItemLoadStateArr = new Array(this.categories.length).fill(false);
  }

  @Builder NavigationTitle() {
    Column() {
    }.width('100%').height('100%').alignItems(HorizontalAlign.Start).backgroundColor('#B6C5D1');
  }

  @Builder TabBuilder(title: string, targetIndex: number) {
    Column({ space: 4 }) {
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? '#DBFFFFFF' : '#99FFFFFF').fontSize(20);
      Divider()
        .strokeWidth(2)
        .color('#DBFFFFFF')
        .opacity(this.currentIndex === targetIndex ? 1 : 0).width(40);
    }
    .animation({ duration: 210 })
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ left: 10, right: 10 })
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(this.currentIndex);
    })
  }

  @Builder Toolbar() {
    Row().backgroundColor(Color.Blue).height(0).width('100%');
  }

  @Builder TabBarItemBuilder(item: CategoryModel, index: number) {
    TabItemComponent({ category: item });
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }){
        Row().height(124).width('100%').backgroundColor('#B6C5D1');
        CustomTabBar({
          items: $categories,
          viewBuilder: this.TabBarItemBuilder.bind(this),
          fontSize: 20,
          barHeight: 56,
          bgColor: '#B6C5D1',
          unselectedColor: '#99FFFFFF',
          selectedColor: '#FFFFFF',
          underlineColor: '#FFFFFF',
        }).margin({ top: 124 - 56 });
      }

      PlayControlComponent().key(this.TAG);
    }

  }

  pageTransition() {
    PageTransitionEnter({ duration: 425, curve: Curve.Smooth, type: RouteType.Pop });
    PageTransitionExit({ duration: 425, curve: Curve.Smooth, type: RouteType.Push });
  }
}
