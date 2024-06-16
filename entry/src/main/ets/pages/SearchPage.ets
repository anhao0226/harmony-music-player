import router from '@ohos.router';
import { fetchSearchData } from '../api/SearchApi';
import { AlbumInter, ArtistInter, SongInter } from '../view_models/SearchModel';

@Entry
@Component
struct SearchPage {
  @State _songs: SongInter[] = [];
  @State _albums: AlbumInter[] = [];
  @State _artists: ArtistInter[] = [];

  handleSearchData(keywords: string) {
    fetchSearchData(keywords).then((value) => {
      this._songs = value.songs;
      this._albums = value.albums;
      this._artists = value.artists;
    })
  }

  build() {
    Navigation() {
      Column({ space: 18 }) {
        TextInput().height(56).onChange((value: string) => {
          this.handleSearchData(value);
        });
        Scroll() {
          Column() {
            if (this._artists.length) {
              _ArtistComponent({ data: $_artists });
            }
            if (this._songs.length) {
              _SongComponent({ data: $_songs });
            }
          }
        }.scrollable(ScrollDirection.Vertical);
      }.width('100%').height('100%').padding(26)
    }
    .titleMode(NavigationTitleMode.Free)
    .navBarWidth('100%')
    .title('Search')
    .backgroundColor('#FFFFFF');
  }
}

@Extend(Text) function songTagStyle(color: ResourceColor) {
  .border({ width: 1.4 })
  .borderRadius(3)
  .fontWeight(FontWeight.Bold)
  .borderColor(color)
  .fontColor(color)
  .fontSize(10)
  .padding({ left: 2, right: 2, top: 0.4, bottom: 0.4 })
}

export enum TapType { MORE }

type OnTapCallback = (tapType: TapType, value: SongInter) => void;

@Component
struct _AlbumComponent {
  private data: AlbumInter;

  build() {

  }
}

@Component
struct _ArtistComponent {
  @Link data: ArtistInter[];

  build() {
    Column({ space: 10 }) {
      Text('Artist').fontSize(22).fontWeight(FontWeight.Bold).padding({ top: 20 });
      ForEach(this.data, (item: ArtistInter) => {
        Row({ space: 10 }) {
          Image(item.picUrl).width(56).aspectRatio(1).borderRadius(6);
          Text(item.name).fontSize(20);
        }.width('100%').onClick(() => {
          router.pushUrl({
            url: 'pages/ArtistDetailPage',
            params: { artistId: item.id }
          });
        });
      }, (item: ArtistInter, _) => `${item.id}_ALBUM_ITEM`);
    }.alignItems(HorizontalAlign.Start);
  }
}

@Component
struct _SongComponent {
  @Link data: SongInter[];

  formatArtists(ars: ArtistInter[]): string {
    let str: string = '';
    if (ars.length === 0) return str;
    if (ars.length === 1) return ars[0].name;
    let length = ars.length;
    str = ars[0].name;
    for (let i = 1; i < length; i++) {
      str += '/' + ars[i].name;
    }
    console.log(str);
    return str;
  }

  @Builder SongTagUI(fee: number) {
    if (fee === 0) {
      // Text('free').songTagStyle('#A6C2BE');
    } else if (fee === 1) {
      Text('VIP').songTagStyle($r('app.color.song_item_tag_color'));
    } else {
      // Text('other').songTagStyle('#F5DC62');
    }
  }

  @Builder IndexUI(index: number) {
    Text(new String(index).padStart(2, '0'))
      .width(40)
      .fontSize(20)
      .textAlign(TextAlign.Center)
      .fontColor('#66000000');
  }

  build() {
    Column({ space: 10 }) {
      Text('Songs').fontSize(22).fontWeight(FontWeight.Bold).padding({ top: 20 });
      ForEach(this.data, (item: SongInter, _) => {
        Row({ space: 10 }) {
          Column({ space: 4 }) {

            Text(item.name)
              .fontSize(20)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontColor('E5000000');

            Row({ space: 4 }) {
              this.SongTagUI(item.fee);
              Text(this.formatArtists(item.artists))
                .fontSize(15)
                .fontColor('#66000000')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
            }
          }.alignItems(HorizontalAlign.Start).layoutWeight(1);

          Blank();

          Image($r('app.media.ic_public_more_2_fill'))
            .width(36)
            .padding({ left: 5, right: 5 })
            .fillColor('#66000000')
            .onClick(() => {
              // if (this.onTap) this.onTap(TapType.MORE, this.data);
            })
        }.width('100%')
      }, (item: SongInter) => `${item.id}_SONG_ITEM`);
    }.alignItems(HorizontalAlign.Start)
  }
}