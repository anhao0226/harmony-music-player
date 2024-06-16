import preferences from '@ohos.data.preferences'
//
// class _AppStorage extends AppStorage {
//   static _context: Context = AppStorage.Get('context');
//
//   constructor() {
//     super();
//   }
//
//   static _saveValue<T extends preferences.ValueType>(propName: string, newValue: T) {
//     preferences.getPreferences(this._context, 'STORAGE_SERVICE', (err, pref: preferences.Preferences) => {
//       if (!err) {
//         pref.put(propName, newValue, () => pref.flush());
//       }
//     })
//   }
//
//   static SetAndSave<T extends preferences.ValueType>(propName: string, newValue: T) {
//     AppStorage.SetOrCreate(propName, newValue);
//     this._saveValue(propName, newValue);
//   }
// }

export class StorageService {
  static getInstance() {
    let storageService: StorageService | undefined = AppStorage.Get('StorageService');
    if (!storageService) {
      storageService = new StorageService();
      AppStorage.SetOrCreate('StorageService', storageService);
    }
    return storageService;
  }

  private getPreferences(): Promise<preferences.Preferences> {
    return preferences.getPreferences(AppStorage.Get('CONTEXT') as Context, "StorageService");
  }

  public async put(key: string, value: preferences.ValueType) {
    return new Promise<void>(async (resolve, reject) => {
      try {
        const prefs = await this.getPreferences();
        await prefs.put(key, value);
        await prefs.flush();
      } catch (err) {
        console.error(`Failed to put data. Code: ${err.code},message:${err.message}`);
        reject(err);
      }
    })
  }

  public get(key: string, defaultValue: preferences.ValueType): Promise<preferences.ValueType> {
    return new Promise<preferences.ValueType>(async (resolve, reject) => {
      try {
        const prefs = await this.getPreferences();
        const data = prefs.get(key, defaultValue);
        resolve(data);
      } catch (err) {
        console.error(`Failed to get value of '${key}'. Code:${err.code}, message:${err.message}`);
        reject(err);
      }
    });
  }
}