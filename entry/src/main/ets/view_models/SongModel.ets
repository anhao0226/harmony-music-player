export interface Quality {
  br: number;
  fid: number;
  size: number;
  vd: number;
  sr: number;
}

export class SongModel {
  name: string;
  id: number;
  pst: number;
  t: number;
  artists: ArtistModel[];
  alia: any[];
  pop: number;
  st: number;
  rt: string;
  fee: number;
  v: number;
  crbt?: string;
  cf: string;
  album: AlbumModel;
  duration: number;
  h?: Quality;
  m?: Quality;
  l?: Quality;
  sq?: Quality;
  hr?: Quality;
  a?: any;
  cd: string;
  no: number;
  rtUrl: any;
  ftype: number;
  rtUrls: any[];
  djId: number;
  copyright: number;
  s_id: number;
  mark: number;
  originCoverType: number;
  originSongSimpleData: any;
  tagPicList: any;
  resourceState: boolean;
  version: number;
  songJumpInfo: any;
  entertainmentTags: any;
  awardTags: any;
  single: number;
  noCopyrightRcmd: any;
  mv: number;
  rtype: number;
  rurl: any;
  mst: number;
  cp: number;
  publishTime: number;
  tns: string[];

  fromJson(json: any) {
    this.name = json['name'];
    this.id = json['id'];
    this.pst = json['pst'];
    this.t = json['t'];
    this.pop = json['pop'];
    this.st = json['st'];
    this.rt = json['rt'];
    this.fee = json['fee'];
    this.v = json['v'];
    this.crbt = json['crbt'];
    this.cf = json['cf'];
    this.duration = json['dt'];
    this.h = json['h'];
    this.m = json['m'];
    this.l = json['l'];
    this.sq = json['sq'];
    this.hr = json['hr'];
    this.a = json['a'];
    this.cd = json['cd'];
    this.no = json['no'];
    this.rtUrl = json['rtUrl'];
    this.ftype = json['ftype'];
    this.djId = json['djId'];
    this.copyright = json['copyright'];
    this.s_id = json['s_id'];
    this.mark = json['mark'];
    this.originCoverType = json['originCoverType'];
    this.originSongSimpleData = json['originSongSimpleData'];
    this.tagPicList = json['tagPicList'];
    this.resourceState = json['resourceState'];
    this.version = json['version'];
    this.songJumpInfo = json['songJumpInfo'];
    this.entertainmentTags = json['entertainmentTags'];
    this.awardTags = json['awardTags'];
    this.single = json['single'];
    this.noCopyrightRcmd = json['noCopyrightRcmd'];
    this.mv = json['mv'];
    this.rtype = json['rtype'];
    this.rurl = json['rurl'];
    this.mst = json['mst'];
    this.cp = json['cp'];
    this.publishTime = json['publishTime'];
    //
    if (json['al'] !== null) {
      this.album = new AlbumModel().fromJson(json['al']);
    }
    // artists
    if (json['ar'] !== null && Array.isArray(json['ar'])) {
      const artists: ArtistModel[] = [];
      json['ar'].forEach((item) => artists.push(new ArtistModel().fromJson(item)));
      this.artists = artists;
    }

    return this
  }
}

export class ArtistModel {
  id: number;
  name: string;
  tns: any[];
  alias: any[];
  picUrl: string;

  fromJson(json: any) {
    this.id = json['id'];
    this.name = json['name'];
    return this
  }
}

export class AlbumModel {
  id: number;
  name: string;
  picUrl: string;
  tns: any[];
  pic_str: string;
  pic: number;

  fromJson(json: any) {
    this.id = json['id'];
    this.name = json['name'];
    this.picUrl = json['picUrl'];
    this.pic_str = json['pic_str'];
    this.pic = json['pic'];
    return this
  }
}