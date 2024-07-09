import router from '@ohos.router';
import { fetchHotSearchDetail, fetchSongs, fetchSuggestSearchResult } from '../api/SongApi';
import { AudioService } from '../common/utils/AudioService';
import { ActionType, SongItemComponent } from '../components/SongItemComponent';
import { SearchDetail } from '../models/HotSearchDetailModel';
import { Song } from '../models/SongModel';
import { Artist } from '../models/SuggestSearchModel';

@Component
export struct SearchPage {
  @State hotSearch: SearchDetail[] = [];
  @State showSearchResult: boolean = false;
  @State searchVal: string = '';

  aboutToAppear() {
    fetchHotSearchDetail().then((result: SearchDetail[]) => {
      this.hotSearch = result;
    })
  }

  @Builder OrderListBuilder() {

  }

  build() {
    Navigation() {
      Column({ space: 18 }) {
        //
        TextInput({ text: '', placeholder: 'input your word...' })
          .height(54)
          .margin({ top: 20, left: 20, right: 20 })
          .fontSize(22)
          .borderRadius(30)
          .placeholderColor(Color.Grey)
          .placeholderFont({ size: 16, weight: 400 })
          .caretColor(Color.Blue)
          .fontColor(Color.Black)
          .backgroundColor('#FFFFFF')
          .onChange((value: string) => {
            this.showSearchResult = value.length ? true : false;
            this.searchVal = value;
          })


        Scroll() {
          if (this.showSearchResult) {
            _SearchResult({
              searchVal: this.searchVal,
            });
          } else {
            Row({ space: 20 }) {
              Column({ space: 10 }) {
                Text('Hot')
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 10, right: 10 });
                ForEach(this.hotSearch, (item: SearchDetail, index: number) => {
                  Row({ space: 6 }) {
                    Text((index + 1).toString())
                      .fontSize(18)
                      .fontColor(index < 3 ? '#E5E84026' : '#99000000')
                      .fontWeight(FontWeight.Bold);
                    Text(item.searchWord).fontSize(18);
                  }
                }, (_, index) => `SEARCH_ITEM_${index}`);
              }
              .backgroundColor('#FFFFFF')
              .alignItems(HorizontalAlign.Start)
              .width(260)
              .borderRadius(10)
              .padding(16)

              Column({ space: 10 }) {
                Text('Artist')
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 10, right: 10 });
                ForEach(this.hotSearch, (item: SearchDetail, index: number) => {
                  Row({ space: 6 }) {
                    Text((index + 1).toString()).fontSize(18)
                      .fontColor(index < 3 ? '#E5E84026' : '#99000000')
                      .fontWeight(FontWeight.Bold);
                    Text(item.searchWord).fontSize(18);
                  }
                }, (_, index) => `SEARCH_ITEM_${index}`);
              }
              .backgroundColor('#FFFFFF')
              .alignItems(HorizontalAlign.Start)
              .width(260)
              .borderRadius(10)
              .padding(16)


              Column({ space: 10 }) {
                Text('Mv')
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 10, right: 10 });
                ForEach(this.hotSearch, (item: SearchDetail, index: number) => {
                  Row({ space: 6 }) {
                    Text((index + 1).toString()).fontSize(18)
                      .fontColor(index < 3 ? '#E5E84026' : '#99000000')
                      .fontWeight(FontWeight.Bold);
                    Text(item.searchWord).fontSize(18);
                  }
                }, (_, index) => `SEARCH_ITEM_${index}`);
              }
              .backgroundColor('#FFFFFF')
              .alignItems(HorizontalAlign.Start)
              .width(260)
              .borderRadius(10)
              .padding(16)

            }.padding({ bottom: 20 }).width('100%').justifyContent(FlexAlign.Center);
          }
        }
        .scrollable(ScrollDirection.Vertical)
        .layoutWeight(1)
        .padding({ bottom: 20 })
        .scrollBar(BarState.Off)
        .margin({ left: 20, right: 20 });
      }.width('100%').height('100%');
    }
    .titleMode(NavigationTitleMode.Full)
    .navBarWidth('100%')
    .title('Search');
    // .backgroundColor('#FFFFFF');
  }
}

@Component
struct _SearchResult {
  @Prop @Watch('onSearchValChange') searchVal: string;
  @State songs: Song[] = [];
  @State artists: Artist[] = [];

  aboutToAppear() {
    this.handleSearchData();
  }

  onSearchValChange() {
    this.handleSearchData();
  }

  handleSearchData() {
    fetchSuggestSearchResult(this.searchVal).then((value) => {
      this.artists = value.artists;
      let songIds: number[] = [];
      value.songs.forEach((item) => songIds.push(item.id));
      fetchSongs(songIds).then((result) => {
        this.songs = result.songs;
      });
    })
  }

  build() {
    Column() {
      /**
       *
       */
      Column({ space: 10 }) {
        Text('Artist').fontSize(24).fontWeight(FontWeight.Medium).margin({ top: 20 }).fontColor('#99000000');
        Column() {
          ForEach(this.artists, (item: Artist) => {
            Row({ space: 10 }) {
              Image(item.picUrl).width(64).aspectRatio(1).borderRadius(6);
              Text(item.name).fontSize(20);
            }.width('100%').onClick(() => {
              router.pushUrl({
                url: 'pages/ArtistDetailPage',
                params: { artistId: item.id }
              });
            });
          }, (item: Artist, _) => `${item.id}_ALBUM_ITEM`);
        }.backgroundColor('#FFFFFF').borderRadius(10).padding(10);
      }.alignItems(HorizontalAlign.Start);
      /**
       * Songs
       */
      Column({ space: 10 }) {
        Text('Songs').fontSize(24).fontWeight(FontWeight.Medium).margin({ top: 20 }).fontColor('#99000000');
        Column() {
          ForEach(this.songs, (item: Song, index: number) => {
            SongItemComponent({
              data: item,
              actions: [ActionType.Mv, ActionType.AddToPlaylist, ActionType.MORE],
              onItemTap: () => {
                AudioService.getInstance().updatePlaylist([item]);
                AudioService.getInstance().start();
                router.pushUrl({ url: 'pages/SongPlayerPage', params: { songId: item.id } })
              },
            }).height(66);
          }, (item: Song, index: number) => `SONG_ITEM_${item.id}`);
        }.backgroundColor('#FFFFFF').borderRadius(10).padding(10);
      }.alignItems(HorizontalAlign.Start);
    }.height('100%');
  }
}