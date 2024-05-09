import { formatArtists, SongModel } from '../view_models/playlist_song_model';


@Extend(Text) function songTagStyle(color: Color | string) {
  .border({ width: 1.4 })
  .borderRadius(3)
  .fontWeight(FontWeight.Bold)
  .borderColor(color)
  .fontColor(color)
  .fontSize(10)
  .padding({ left: 2, right: 2, top: 0.4, bottom: 0.4 })
}


@CustomDialog
export struct SongListCustomDialog {
  private controller: CustomDialogController
  private songs: SongModel[] = [];
  private onItemClick: (song: SongModel, index: number) => void;

  @Builder SongTagUI(fee: number) {
    if (fee === 0) {
      // Text('free').songTagStyle('#A6C2BE');
    } else if (fee === 1) {
      Text('VIP').songTagStyle('#E87361');
    } else {
      // Text('other').songTagStyle('#F5DC62');
    }
  }

  @Builder SongItemUI(value: SongModel) {
    Row({ space: 10 }) {
      Column({ space: 10 }) {
        Text(value.name)
          .fontSize(20)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor('E5000000');
        //
        Row({ space: 4 }) {
          this.SongTagUI(value.fee);
          Text(formatArtists(value.ar))
            .fontSize(15)
            .fontColor('#66000000')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        };
      }.alignItems(HorizontalAlign.Start).layoutWeight(1);


      Image($r('app.media.ic_public_more_list')).width(30).fillColor('#66000000')

    }.padding(14);
  }

  build() {
    Column() {
      List() {
        ForEach(this.songs, (item: SongModel, index) => {
          ListItem() {
            this.SongItemUI(item);
          }.onClick(() => {
            this.onItemClick(item, index);
          })
        }, (item: SongModel, index) => (item.id + index).toString())
      }.height('100%').width('100%')
    }.height('100%').backgroundColor(Color.White);
  }
}