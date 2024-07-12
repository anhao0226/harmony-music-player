import router from '@ohos.router';
import { fetchMvs, MvArea } from '../api/SongApi';
import { CustomImage } from '../components/ImageComponent';
import { SafeAreaComponent } from '../components/SafeAreaComponent';
import { TabBar, TabInterface } from '../components/TabBar';
import { MvModel } from '../models/MvDataModel';

@Component
export struct MvComponent {
  @State tabs: TabInterface[] = [];
  @State viewArea: Area = null;

  aboutToAppear() {
    let tabs: TabInterface[] = [];
    Object.values(MvArea).forEach((text: string) => {
      tabs.push({ text: text });
    })
    this.tabs = tabs;
  }

  @Builder MvListBuilder(tabValue: TabInterface, index: number) {
    MvTabBarView({
      tab: tabValue,
      viewWidth: this.viewArea ? this.viewArea.width as number : 0
    });
  }

  build() {
    Column() {
      SafeAreaComponent() {
        TabBar({
          tabs: $tabs,
          viewBuilder: (tab: TabInterface, index: number) => this.MvListBuilder(tab, index),
          onViewAreaChange: (_, newVal: Area) => this.viewArea = newVal,
        });
      }
    }
  }
}


@Component
struct MvTabBarView {
  @Prop @Watch('onWidthChange') viewWidth: number;
  @State mvs: MvModel[] = [];
  @State listItemWidth: number = 100;
  protected mvArea: MvArea = MvArea.All;
  private tab: TabInterface = null;

  onWidthChange() {
    this.listItemWidth = (this.viewWidth - 5 * 10) / 5;
  }

  aboutToAppear() {
    if (this.tab) {
      this.mvArea = this.tab.text as MvArea;
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
