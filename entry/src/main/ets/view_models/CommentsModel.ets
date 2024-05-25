class UserModel {
  avatarDetail: any;
  commonIdentity: any;
  locationInfo: any;
  liveInfo: any;
  followed: boolean;
  vipRights: any;
  relationTag: any;
  anonym: number;
  encryptUserId: string;
  userId: number;
  userType: number;
  nickname: string;
  avatarUrl: string;
  authStatus: number;
  expertTags: any;
  experts: any;
  vipType: number;
  remarkName: any;
  isHug: boolean;
  socialUserId: any;
  target: any;

  fromJson(json: any) {
    this.avatarDetail = json['avatarDetail'];
    this.commonIdentity = json['commonIdentity'];
    this.locationInfo = json['locationInfo'];
    this.liveInfo = json['liveInfo'];
    this.followed = json['followed'];
    this.vipRights = json['vipRights'];
    this.relationTag = json['relationTag'];
    this.anonym = json['anonym'];
    this.encryptUserId = json['encryptUserId'];
    this.userId = json['userId'];
    this.userType = json['userType'];
    this.nickname = json['nickname'];
    this.avatarUrl = json['avatarUrl'];
    this.authStatus = json['authStatus'];
    this.expertTags = json['expertTags'];
    this.experts = json['experts'];
    this.vipType = json['vipType'];
    this.remarkName = json['remarkName'];
    this.isHug = json['isHug'];
    this.socialUserId = json['socialUserId'];
    this.target = json['target'];
    return this
  }
}

class ShowFloorCommentModel {
  replyCount: number;
  comments: any;
  showReplyCount: boolean;
  topCommentIds: any;
  target: any;

  fromJson(json: any) {
    this.replyCount = json['replyCount'];
    this.comments = json['comments'];
    this.showReplyCount = json['showReplyCount'];
    this.topCommentIds = json['topCommentIds'];
    this.target = json['target'];
    return this
  }
}

class DecorationModel {
  repliedByAuthorCount: number;

  fromJson(json: any) {
    this.repliedByAuthorCount = json['repliedByAuthorCount'];
    return this
  }
}

class TagModel {
  datas: any[];
  extDatas: any[];
  contentDatas: any[];
  contentPicDatas: any[];
  relatedCommentIds: any;

  fromJson(json: any) {
    this.relatedCommentIds = json['relatedCommentIds'];
    return this
  }
}

class ExtInfoModel {
  fromJson(json: any) {
    return this
  }
}

class CommentVideoVOModel {
  showCreationEntrance: boolean;
  allowCreation: boolean;
  creationOrpheusUrl: any;
  playOrpheusUrl: any;
  videoCount: number;
  forbidCreationText: string;

  fromJson(json: any) {
    this.showCreationEntrance = json['showCreationEntrance'];
    this.allowCreation = json['allowCreation'];
    this.creationOrpheusUrl = json['creationOrpheusUrl'];
    this.playOrpheusUrl = json['playOrpheusUrl'];
    this.videoCount = json['videoCount'];
    this.forbidCreationText = json['forbidCreationText'];
    return this
  }
}

class IpLocationModel {
  ip: any;
  location: string;
  userId: any;

  fromJson(json: any) {
    this.ip = json['ip'];
    this.location = json['location'];
    this.userId = json['userId'];
    return this
  }
}

export class CommentModel {
  user: UserModel;
  beReplied: any;
  commentId: number;
  threadId: string;
  content: string;
  richContent: any;
  status: number;
  time: number;
  timeStr: string;
  needDisplayTime: boolean;
  likedCount: number;
  replyCount: number;
  liked: boolean;
  expressionUrl: any;
  parentCommentId: number;
  repliedMark: boolean;
  pendantData: any;
  pickInfo: any;
  showFloorComment: ShowFloorCommentModel;
  decoration: DecorationModel;
  commentLocationType: number;
  musicianSayAirborne: any;
  args: any;
  tag: TagModel;
  source: any;
  resourceSpecialType: any;
  extInfo: ExtInfoModel;
  commentVideoVO: CommentVideoVOModel;
  contentResource: any;
  contentPicNosKey: any;
  contentPicUrl: any;
  grade: any;
  userBizLevels: any;
  userNameplates: any;
  ipLocation: IpLocationModel;
  owner: boolean;
  tail: any;
  hideSerialComments: any;
  hideSerialTips: any;
  topicList: any;
  privacy: number;
  medal: any;
  outShowComments: any;
  bottomTags: any[];

  fromJson(json: any) {
    this.user = new UserModel().fromJson(json['user']);
    this.beReplied = json['beReplied'];
    this.commentId = json['commentId'];
    this.threadId = json['threadId'];
    this.content = json['content'];
    this.richContent = json['richContent'];
    this.status = json['status'];
    this.time = json['time'];
    this.timeStr = json['timeStr'];
    this.needDisplayTime = json['needDisplayTime'];
    this.likedCount = json['likedCount'];
    this.replyCount = json['replyCount'];
    this.liked = json['liked'];
    this.expressionUrl = json['expressionUrl'];
    this.parentCommentId = json['parentCommentId'];
    this.repliedMark = json['repliedMark'];
    this.pendantData = json['pendantData'];
    this.pickInfo = json['pickInfo'];
    this.showFloorComment = new ShowFloorCommentModel().fromJson(json['showFloorComment']);
    this.decoration = new DecorationModel().fromJson(json['decoration']);
    this.commentLocationType = json['commentLocationType'];
    this.musicianSayAirborne = json['musicianSayAirborne'];
    this.args = json['args'];
    this.tag = new TagModel().fromJson(json['tag']);
    this.source = json['source'];
    this.resourceSpecialType = json['resourceSpecialType'];
    this.extInfo = new ExtInfoModel().fromJson(json['extInfo']);
    this.commentVideoVO = new CommentVideoVOModel().fromJson(json['commentVideoVO']);
    this.contentResource = json['contentResource'];
    this.contentPicNosKey = json['contentPicNosKey'];
    this.contentPicUrl = json['contentPicUrl'];
    this.grade = json['grade'];
    this.userBizLevels = json['userBizLevels'];
    this.userNameplates = json['userNameplates'];
    this.ipLocation = new IpLocationModel().fromJson(json['ipLocation']);
    this.owner = json['owner'];
    this.tail = json['tail'];
    this.hideSerialComments = json['hideSerialComments'];
    this.hideSerialTips = json['hideSerialTips'];
    this.topicList = json['topicList'];
    this.privacy = json['privacy'];
    this.medal = json['medal'];
    this.outShowComments = json['outShowComments'];
    return this
  }
}