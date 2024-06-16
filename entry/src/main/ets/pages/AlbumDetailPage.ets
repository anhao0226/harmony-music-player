import router from '@ohos.router';

import { SongModel, defaultSongItem, } from '../view_models/playlist_song_model';
import { BottomBarControlComponent } from '../components/BottomBarControlComponent';
import { SongInfoDialogComponent } from '../components/SongInfoIDialogContent';
import { ArtistAlbumModel, } from '../view_models/ArtistDetailModel';
import { CommonLayoutLComponent, CommonLayoutRComponent } from '../components/CommonPageLayoutComponent';
import { SongListComponent } from '../components/SongListComponent';
import { SongDataSource } from '../view_models/SongDataSource';
import { CommonDataSource } from '../models/CommonDataSource';
import { Song } from '../models/SongModel';
import { fetchAlbumDetail } from '../api/SongApi';
import { Album } from '../models/AlbumDetailModel';


@Entry
@Component
struct AlbumDetailPage {
  private readonly TAG = 'ALBUM_DETAIL_PAGE'
  @State pageOffset: number = 0;
  @State playingSong: SongModel = defaultSongItem;
  @State leftBgColor: string = '#B6C5D1';
  @State trackCount: number = 0;
  @State dialogData: SongModel | null = null;
  @State album: ArtistAlbumModel | null = null;
  @State _album: Album = null;
  private _songs: CommonDataSource<Song> = new CommonDataSource<Song>();
  private _dialogData: Song | null = null;
  private songInfoDialogController: CustomDialogController = new CustomDialogController({
    alignment: DialogAlignment.Center,
    builder: SongInfoDialogComponent({ data: this._dialogData })
  })

  onPageShow() {
    const params = router.getParams();
    const albumId = (params && params.hasOwnProperty('albumId')) ? params['albumId'] : '';
    this.initData(albumId);
  }

  initData(albumId: number) {
    fetchAlbumDetail(albumId).then((res) => {
      this._album = res.album;
      this._songs.pushDataFromArray(res.songs);
    })
  }

  @Builder BodyBuilder() {
    Column() {
      SongListComponent({
        songList: this._songs,
        songCount: this.album ? this.album.size : 0,
      });
    }
    .padding({ left: 12, right: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 14, topRight: 14 })
    .layoutWeight(1);
  }

  build() {
    Column() {
      Row() {
        CommonLayoutLComponent({
          imgSrc: this._album ? this._album.picUrl : '',
          name: this._album ? this._album.name : '',
          description: this._album ? this._album.description : ''
        });

        CommonLayoutRComponent({
          bodyBuilder: this.BodyBuilder.bind(this),
        });
      }.width('100%').layoutWeight(1);

      //
      BottomBarControlComponent().key(this.TAG);

    }.height('100%').width('100%').backgroundColor('#F1F3F5');
  }

  pageTransition() {
    PageTransitionEnter({ duration: 425, curve: Curve.EaseInOut, type: RouteType.Pop });
    PageTransitionExit({ duration: 425, curve: Curve.EaseInOut, type: RouteType.Push });
  }
}



