import router from '@ohos.router';
import { fetchMvs, MvArea } from '../api/SongApi';
import { CustomTabBar, TabBarDataInterface, TabViewBuildData } from '../components/CustomTabBar';
import { CustomImage } from '../components/ImageComponent';
import { SafeAreaComponent } from '../components/SafeAreaComponent';
import { MvModel } from '../models/MvDataModel';

@Component
export struct MvComponent {
  @State tabs: TabBarDataInterface[] = [];
  @State viewArea: Area = null;

  aboutToAppear() {
    let tabs_: TabBarDataInterface[] = [];
    Object.values(MvArea).forEach((text: string) => {
      tabs_.push({ text: text });
    })
    this.tabs = tabs_;
  }

  @Builder MvListBuilder(viewData: TabViewBuildData) {
    MvTabBarView({
      viewData,
      viewWidth: this.viewArea ? this.viewArea.width as number : 0
    });
  }

  build() {
    Column() {
      SafeAreaComponent() {
        CustomTabBar({
          tabs: $tabs,
          fontSize: 22,
          selectedColor: '#99000000',
          unselectedColor: '#66000000',
          underlineColor: '#99000000',
          onViewSize: (area: Area) => this.viewArea = area,
          viewBuilder: (data: TabViewBuildData) => this.MvListBuilder(data),
        });
      }
    }
  }
}


@Component
struct MvTabBarView {
  private viewData: TabViewBuildData = null;
  @Prop @Watch('onWidthChange') viewWidth: number;
  @State mvs: MvModel[] = [];
  @State listItemWidth: number = 100;
  protected mvArea: MvArea = MvArea.All;

  onWidthChange() {
    this.listItemWidth = (this.viewWidth - 5 * 10) / 5;
  }

  aboutToAppear() {
    if (this.viewData) {
      this.mvArea = this.viewData.item.text as MvArea;
    }
    fetchMvs({ area: this.mvArea, limit: 30 }).then((result) => {
      this.mvs = result;
    })
  }

  setImageSize(src: string, width: number, height: number): string {
    return `${src}?param=${width}y${height}`
  }

  build() {
    Column() {
      List({ space: 10 }) {
        ForEach(this.mvs, (item: MvModel) => {
          ListItem() {
            Column({ space: 6 }) {
              CustomImage({
                imageSrc: this.setImageSize(item.cover, 400, 100 * 16 / 9),
                imageWidth: this.listItemWidth,
                imageBorderRadius: 4,
                imageAspectRatio: 16 / 9,
              });
              Text(item.name).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis });
            }.alignItems(HorizontalAlign.Start)
          }.onClick(() => {
            router.pushUrl({ url: 'pages/MvPlayerPage', params: { mvId: item.id } })
          })
        }, (item: MvModel) => `MV_ITEM_${item.id}`);
      }
      .lanes(5)
      .height(0)
      .width('100%')
      .layoutWeight(1)
      .margin({ top: 10 })
    }.height('100%').width('100%');
  }
}
