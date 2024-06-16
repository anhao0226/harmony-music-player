export class FreeTrialPrivilegeModel {
  resConsumable: boolean;
  userConsumable: boolean;
  listenType: any;
  cannotListenReason: any;
  playReason: any;

  fromJson(json: any) {
    this.resConsumable = json['resConsumable'];
    this.userConsumable = json['userConsumable'];
    this.listenType = json['listenType'];
    this.cannotListenReason = json['cannotListenReason'];
    this.playReason = json['playReason'];
    return this
  }
}

export class ChargeInfoModel {
  rate: number;
  chargeUrl: any;
  chargeMessage: any;
  chargeType: number;

  fromJson(json: any) {
    this.rate = json['rate'];
    this.chargeUrl = json['chargeUrl'];
    this.chargeMessage = json['chargeMessage'];
    this.chargeType = json['chargeType'];
    return this
  }
}

export class PrivilegeModel {
  id: number;
  fee: number;
  payed: number;
  st: number;
  pl: number;
  dl: number;
  sp: number;
  cp: number;
  subp: number;
  cs: boolean;
  maxbr: number;
  fl: number;
  toast: boolean;
  flag: number;
  preSell: boolean;
  playMaxbr: number;
  downloadMaxbr: number;
  maxBrLevel: string;
  playMaxBrLevel: string;
  downloadMaxBrLevel: string;
  plLevel: string;
  dlLevel: string;
  flLevel: string;
  rscl?: any;
  freeTrialPrivilege: FreeTrialPrivilegeModel;
  rightSource: number;
  chargeInfoList: ChargeInfoModel[];

  fromJson(json: any) {
    this.id = json['id'];
    this.fee = json['fee'];
    this.payed = json['payed'];
    this.st = json['st'];
    this.pl = json['pl'];
    this.dl = json['dl'];
    this.sp = json['sp'];
    this.cp = json['cp'];
    this.subp = json['subp'];
    this.cs = json['cs'];
    this.maxbr = json['maxbr'];
    this.fl = json['fl'];
    this.toast = json['toast'];
    this.flag = json['flag'];
    this.preSell = json['preSell'];
    this.playMaxbr = json['playMaxbr'];
    this.downloadMaxbr = json['downloadMaxbr'];
    this.maxBrLevel = json['maxBrLevel'];
    this.playMaxBrLevel = json['playMaxBrLevel'];
    this.downloadMaxBrLevel = json['downloadMaxBrLevel'];
    this.plLevel = json['plLevel'];
    this.dlLevel = json['dlLevel'];
    this.flLevel = json['flLevel'];
    this.rscl = json['rscl'];
    this.rightSource = json['rightSource'];

    const freeTrialPrivilegeVal = json['freeTrialPrivilege'];
    if (freeTrialPrivilegeVal != null) {
      this.freeTrialPrivilege = new FreeTrialPrivilegeModel().fromJson(json['freeTrialPrivilege']);
    }

    const chargeInfoListVal = json['chargeInfoList'];
    if (chargeInfoListVal != null && Array.isArray(chargeInfoListVal)) {
      const chargeInfoList: ChargeInfoModel[] = [];
      chargeInfoListVal.forEach((item) => chargeInfoList.push(new ChargeInfoModel().fromJson(item)));
    }
    return this
  }
}