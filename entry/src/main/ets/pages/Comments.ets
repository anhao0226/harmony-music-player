import router from '@ohos.router';
import { fetchPlaylistComment } from '../api/CommentApi'
import { CommentModel } from '../view_models/CommentsModel';

@Entry
@Component
struct CommentView {
  @State comments: CommentModel[] = [];
  @State hotComments: CommentModel[] = [];

  onPageShow() {
    const params = router.getParams();
    // params['playlistId']
    fetchPlaylistComment(6666112560).then(({ hotComments, comments }) => {
      this.comments = comments;
      this.hotComments = hotComments;
    })
  }

  build() {
    Navigation() {
      List() {
        ForEach(this.comments, (item: CommentModel, index: number) => {
          ListItem() {
            Row({ space: 6 }) {
              Image(item.user.avatarUrl).width(40).aspectRatio(1).borderRadius(38);
              Column({ space: 6 }) {
                Text(item.user.nickname).fontWeight(FontWeight.Bold);
                Row() {
                  Text(item.timeStr).fontSize(12);
                  Text(item.ipLocation.location).fontSize(12);
                }

                Text(item.content)
              }.alignItems(HorizontalAlign.Start).layoutWeight(1)
            }.alignItems(VerticalAlign.Top)
          }.padding(16)
        }, (item: CommentModel, _) => `COMMENT_${item.commentId}`);
      }.width('100%').height('100%').divider({ strokeWidth: 1 }).padding({ left: 10, right: 10 })
    }.titleMode(NavigationTitleMode.Full).navBarWidth('100%').title('Comments').backgroundColor(Color.White);
  }
}