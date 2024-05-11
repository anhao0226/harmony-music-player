import UIAbility from '@ohos.app.ability.UIAbility';
import { AudioService } from '../common/utils/AudioService';
import { AudioPlayController } from '../components/AudioPlayController';
import { TabItemComponent } from '../components/TabItemComponent';
import { CategoryModel, getPlaylistCategory, } from '../view_models/playlist_song_model';
import window from '@ohos.window';

@Entry
@Component
struct Index {
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
    }.width('100%').height('100%').alignItems(HorizontalAlign.Start);
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
    Row().backgroundColor(Color.Blue).height('100%').width('100%')
  }

  build() {
    Column() {
      Navigation() {
        Tabs({ controller: this.tabsController }) {
          ForEach(this.categories, (item: CategoryModel, index: number) => {
            TabContent() {
              if (this.currentIndex === index || this.tabItemLoadStateArr[index]) {
                TabItemComponent({ category: item });
              }
            }
            .padding({ left: 10, right: 10 })
            .tabBar(this.TabBuilder(item.name, index))
            .backgroundColor('#F1F3F5');

          }, (item: CategoryModel) => item.id.toString());

        }
        .barWidth('100%')
        .vertical(false)
        .animationDuration(400)
        .barMode(BarMode.Scrollable)
        .onChange(async (index) => {
          this.currentIndex = index;
          this.tabItemLoadStateArr[this.currentIndex] = true;
        });

      }
      .navBarWidth('100%')
      .backgroundColor('#B6C5D1')
      .title(this.NavigationTitle())
      .titleMode(NavigationTitleMode.Mini)
      .hideBackButton(true)
      .hideToolBar(false)
      .layoutWeight(1);


      // AudioPlayController().height(60).width('100%');
    }

  }

  pageTransition() {
    PageTransitionEnter({ duration: 425, curve: Curve.Smooth, type: RouteType.Pop });
    PageTransitionExit({ duration: 425, curve: Curve.Smooth, type: RouteType.Push });
  }
}
