import { BottomBarControlComponent } from '../components/BottomBarControlComponent'
import { CustomTabBar, TabBarDataInterface, TabViewBuildData } from '../components/CustomTabBar'
import { SafeAreaComponent } from '../components/SafeAreaComponent';
import { PlaylistTabView } from '../components/PlaylistTabView';
import { CategoryModel, getPlaylistCategory } from '../view_models/playlist_song_model';

@Component
export struct HomePage {
  private TAG: string = 'HOME_PAGE';
  @State tabs: TabBarDataInterface[] = [];
  @State viewArea: Area = null;

  aboutToAppear() {
    this.initData();
  }

  async initData() {
    const categories = await getPlaylistCategory();
    let tabs_: TabBarDataInterface[] = [];
    categories.forEach((value: CategoryModel) => tabs_.push({ text: value.name }));
    this.tabs = tabs_;
  }

  @Builder TabBarViewBuilder(viewData: TabViewBuildData) {
    PlaylistTabView({
      category: viewData.item,
      viewWidth: this.viewArea ? this.viewArea.width as number : 0,
    });
  }

  build() {
    Column() {
      SafeAreaComponent() {
        Column() {
          CustomTabBar({
            tabs: $tabs,
            fontSize: 22,
            unselectedColor: '#66000000',
            selectedColor: '#99000000',
            underlineColor: '#99000000',
            viewBuilder: (viewData: TabViewBuildData) => this.TabBarViewBuilder(viewData),
            onViewSize: (newVal: Area) => {
              this.viewArea = newVal;
            },
          }).layoutWeight(1);
          //
          BottomBarControlComponent().key(this.TAG);
        }
      }
    }
  }
}