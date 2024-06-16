import router from '@ohos.router';
import { CommentType, fetchComments, SortType } from '../api/CommentApi'
import { WindowsConstant } from '../common/constant/WindowConstant';
import { Comment } from '../models/CommentModel';
import { CommonDataSource } from '../models/CommonDataSource';

@Entry
@Component
struct CommentView {
  private _id: number = 0;
  private _type: CommentType;
  private _pageNo: number = 1;
  @State _sortType: SortType = SortType.HOT;
  @State _comments: CommonDataSource<Comment> = new CommonDataSource<Comment>();
  @State _commentCount: number = 0;

  onPageShow() {
    // params['id'] = 705123491;
    // params['type'] = CommentType.PLAYLIST;
    const params = router.getParams() ?? {};
    if (params && params.hasOwnProperty('id') && params.hasOwnProperty('type')) {
      this._id = params['id'];
      this._type = params['type'];
      this.initData();
    }
  }

  initData() {
    fetchComments({
      id: this._id,
      type: this._type,
      sortType: this._sortType,
      pageNo: this._pageNo,
      pageSize: 20,
    })
      .then((res) => {
        this._comments.pushDataFromArray(res.comments);
        this._commentCount = res.totalCount;
        this._pageNo += 1;
      }).catch((err) => {
      console.log(err);
    })
  }

  @Builder NavTitle() {
    Column() {
      Row({ space: 18 }) {
        Image($r('app.media.ic_public_arrow_left_line')).width(32).onClick(() => {
          router.back();
        });
        Text(`Comments(${this._commentCount})`).fontSize(22).fontWeight(FontWeight.Medium);
      }.height(56).justifyContent(FlexAlign.Start).width('100%').padding({ left: 18 })
    }
    .width('100%')
    // .backgroundColor(Color.Brown)
    .height(WindowsConstant.statusBarHeight() + 56)
    .padding({ top: WindowsConstant.statusBarHeight() });
  }

  build() {
    Column() {
      this.NavTitle();
      List() {
        LazyForEach(this._comments, (item: Comment, index: number) => {
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
        }, (item: Comment, _) => `COMMENT_${item.commentId}`);
      }
      .width('100%')
      .height(0)
      .divider({ strokeWidth: 1 })
      .padding({ left: 10, right: 10 })
      .onReachEnd(() => this.initData())
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}

@Component
struct AppBar {
  build() {
    Row() {

    }
  }
}