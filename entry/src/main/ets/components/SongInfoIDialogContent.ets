import router from '@ohos.router';
import { formatArtists } from '../view_models/playlist_song_model'
import { Song } from '../models/SongModel';


interface ListTitleValue {
  icon: Resource,
  title: string,
  content?: string,
  onClick?: () => void
}

@CustomDialog
export struct SongInfoDialogComponent {
  private data: Song | null = null;
  controller?: CustomDialogController

  @Builder ListTitle(value: ListTitleValue) {
    Row({ space: 20 }) {
      Image(value.icon).width(28).fillColor('#99000000')
      Column() {
        Row({ space: 4 }) {
          Text(value.title).fontSize(18).fontColor('#E5000000');
          if (value.content) {
            Text(':').fontSize(18).fontColor('#E5000000');
            Text(value.content)
              .fontSize(18)
              .fontColor('#E5000000')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
          }
        }
        .height(63)
        .width('100%')
        .padding({ top: 4, bottom: 4 })
        .justifyContent(FlexAlign.Start)

        Divider();
      }.justifyContent(FlexAlign.Start).layoutWeight(1);
    }
    .height(64)
    .padding({ left: 20, right: 20 })
    .onClick(() => {
      if (value.onClick) value.onClick();
    });
  }

  build() {
    Column() {
      if (this.data) {
        Text(this.data.name).padding(20).fontSize(24).fontWeight(FontWeight.Bold);

        this.ListTitle({
          icon: $r('app.media.ic_public_user_line'),
          title: 'Artists',
          content: formatArtists(this.data.ar),
          onClick: () => {
            router.pushUrl({ url: 'pages/ArtistDetailPage', params: { artistId: this.data.ar[0].id } });
          }
        });

        this.ListTitle({
          icon: $r('app.media.ic_public_album_fill'),
          title: 'Album',
          content: this.data.al.name,
          onClick: () => {
            router.pushUrl({ url: 'pages/AlbumDetailPage', params: { albumId: this.data.al.id } });
          }
        });

        this.ListTitle({
          icon: $r('app.media.ic_public_share_fill'),
          title: 'Share',
          onClick: () => {

          }
        });

        this.ListTitle({ icon: $r('app.media.ic_public_skip_forward_fill'), title: 'Play next' });
        this.ListTitle({ icon: $r('app.media.ic_public_message_3_line'), title: 'Comment' });
      }


    }.width('100%').height('100%').backgroundColor(Color.White).alignItems(HorizontalAlign.Start);
  }
}