import { formatArtists, SongModel } from '../view_models/playlist_song_model';
import { SongItemComponent } from './SongItem';

@CustomDialog
export struct SongListCustomDialog {
  private songs: SongModel[] = [];
  private onItemClick: (song: SongModel, index: number) => void;
  private controller: CustomDialogController

  build() {
    Column() {
      List() {
        ForEach(this.songs, (item: SongModel, index) => {
          ListItem() {
            SongItemComponent({ data: item });
          }.onClick(() => {
            this.onItemClick(item, index);
          })
        }, (item: SongModel, index) => (item.id + index).toString())
      }.height('100%').width('100%')
    }.height('100%').backgroundColor(Color.White);
  }
}