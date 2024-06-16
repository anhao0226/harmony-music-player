import { AudioService } from '../common/utils/AudioService';
import { BottomBarControlComponent } from '../components/BottomBarControlComponent';
import { TabItemComponent } from '../components/TabItemComponent';
import { CategoryModel, getPlaylistCategory, PlaylistModel, } from '../view_models/playlist_song_model';
import window from '@ohos.window';
import { CustomTabBar } from '../components/CustomTabBar';
import { getDarkColor, getImageMainColor, getNetworkImagePixelMap, rgbaToHexColor } from '../common/utils/ColorUtil';
import image from '@ohos.multimedia.image';
import router from '@ohos.router';

@Entry
@Component
struct Index {
  private readonly TAG = 'INDEX';
  @State currentIndex: number = 0;
  @State isLoading: boolean = false;
  @State navBgColor: string = '#ffffff';
  @State categories: CategoryModel[] = [];
  @State tabItemLoadStateArr: boolean[] = [];
  @StorageLink('WINDOW_STAGE') windowStage: window.WindowStage = null;
  @State bgImgPixelMap: image.PixelMap | null = null;

  onPageShow() {
    this.initData()
  }

  async initData() {
    AudioService.getInstance();
    this.categories = await getPlaylistCategory();
    this.tabItemLoadStateArr = new Array(this.categories.length).fill(false);
  }

  async updateNavBackgroundColor(imgSrc: string) {
    try {
      let pixelMap = await getNetworkImagePixelMap(imgSrc);
      const mainColor = await getImageMainColor(pixelMap);
      let darkColor = getDarkColor(mainColor, 0.4);
      this.navBgColor = rgbaToHexColor(darkColor);
    } catch (err) {
      console.log(err);
    }
  }

  @Builder TabBarViewBuilder(item: CategoryModel, index: number) {
    TabItemComponent({
      category: item,
      onDataChange: (value: PlaylistModel) => {
        this.updateNavBackgroundColor(value.coverImgUrl);
      }
    });
  }

  @Builder menuBuilder() {
    Row() {
      Row()
        .backgroundColor('#19000000')
        .height(30)
        .width('100%')
        .borderRadius(42)
        .onClick(() => {
          router.pushUrl({ url: 'pages/SearchPage' });
        })
    }.width(150).padding({ right: 30 });
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Row()
        .height(122)
        .width('100%')
        .backgroundColor(this.navBgColor)
        .backgroundBlurStyle(BlurStyle.Thin)
        .blur(2)
        .animation({ duration: 468, curve: Curve.EaseInOut })

      Column() {
        Row().height(66).width('100%');
        CustomTabBar({
          fontSize: 20,
          barHeight: 56,
          items: $categories,
          tabs: $categories,
          menuBuilder: this.menuBuilder.bind(this),
          viewBuilder: this.TabBarViewBuilder.bind(this),
          unselectedColor: '#66FFFFFF',
          selectedColor: '#FFFFFF',
          underlineColor: '#FFFFFF',
        }).layoutWeight(1);
        //
        BottomBarControlComponent().key(this.TAG);

      }
    }
  }

  pageTransition() {
    PageTransitionEnter({ duration: 425, curve: Curve.Smooth, type: RouteType.Pop });
    PageTransitionExit({ duration: 425, curve: Curve.Smooth, type: RouteType.Push });
  }
}

/**
 *
 *
 *
 * showSubWindow() {
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

 */