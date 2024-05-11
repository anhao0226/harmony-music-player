import router from '@ohos.router';
import { ArtistModel, formatArtists, SongModel } from '../view_models/playlist_song_model'

@CustomDialog
export struct SongInfoDialogContent {
  private data: SongModel | null = null;
  controller?: CustomDialogController

  build() {
    Column() {
      if (this.data) {
        Row() {
          Text('Name');
          Text(this.data.name);
        }.padding(10)

        Row() {
          Text('Artists');
          ForEach(this.data.ar, (item: ArtistModel) => {
            Text(item.name).onClick(() => {
              router.pushUrl({ url: 'pages/ArtistDetailPage', params: { artistId: item.id } })
            })
          }, (item: ArtistModel) => item.id.toString())
        }.padding(10);
      }
    }.width('100%').height('100%').backgroundColor(Color.White)
  }
}