class TransUserModel {
  id: number;
  status: number;
  demand: number;
  userid: number;
  nickname: string;
  uptime: number;

  fromJson(json: any) {
    this.id = json['id'];
    this.status = json['status'];
    this.demand = json['demand'];
    this.userid = json['userid'];
    this.nickname = json['nickname'];
    this.uptime = json['uptime'];
    return this
  }
}

class LyricUserModel {
  id: number;
  status: number;
  demand: number;
  userid: number;
  nickname: string;
  uptime: number;

  fromJson(json: any) {
    this.id = json['id'];
    this.status = json['status'];
    this.demand = json['demand'];
    this.userid = json['userid'];
    this.nickname = json['nickname'];
    this.uptime = json['uptime'];
    return this
  }
}

class LrcModel {
  version: number;
  lyric: string;

  fromJson(json: any) {
    this.version = json['version'];
    this.lyric = json['lyric'];
    return this
  }
}

class KlyricModel {
  version: number;
  lyric: string;

  fromJson(json: any) {
    this.version = json['version'];
    this.lyric = json['lyric'];
    return this
  }
}

class TlyricModel {
  version: number;
  lyric: string;

  fromJson(json: any) {
    this.version = json['version'];
    this.lyric = json['lyric'];
    return this
  }
}

class RomalrcModel {
  version: number;
  lyric: string;

  fromJson(json: any) {
    this.version = json['version'];
    this.lyric = json['lyric'];
    return this
  }
}

export class LyricModel {
  sgc: boolean;
  sfy: boolean;
  qfy: boolean;
  transUser?: TransUserModel;
  lyricUser?: LyricUserModel;
  lrc: LrcModel;
  code: number;

  // klyric: KlyricModel;
  // tlyric: TlyricModel;
  // romalrc: RomalrcModel;

  fromJson(json: any) {
    this.sgc = json['sgc'];
    this.sfy = json['sfy'];
    this.qfy = json['qfy'];
    //
    // if (json['transUser'] !== null) {
    //   this.transUser = new TransUserModel().fromJson(json['transUser']);
    // }
    //
    // if (json['lyricUser'] !== null) {
    //   this.lyricUser = new LyricUserModel().fromJson(json['lyricUser']);
    // }
    //
    if (json['lrc'] !== null) {
      this.lrc = new LrcModel().fromJson(json['lrc']);
    }
    // if (json['klyric'] !== null) {
    //   this.klyric = new KlyricModel().fromJson(json['klyric']);
    // }
    // if (json['tlyric'] !== null) {
    //   this.tlyric = new TlyricModel().fromJson(json['tlyric']);
    // }
    //
    // if (json['romalrc'] !== null) {
    //   this.romalrc = new RomalrcModel().fromJson(json['romalrc']);
    // }

    this.code = json['code'];
    return this
  }
}