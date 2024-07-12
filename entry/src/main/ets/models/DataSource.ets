/**
 * DataSource
 */
export class DataSource<T> implements IDataSource {
  private dataArray: T[] = [];
  private listeners: DataChangeListener[] = [];
  private reverseData: boolean = false;

  constructor(reverseData?: boolean) {
    this.reverseData = reverseData || false;
  }

  /**
   * @deprecated
  * @returns
   */
  getAllData(): T [] {
    return this.dataArray;
  }

  totalCount(): number {
    return this.dataArray.length;
  }

  slice(start: number): T[] {
    return this.dataArray.slice(start);
  }

  pushData(data: T): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  init(values: T[]) {
    this.dataArray = values;
    this.notifyDataReload();
  }

  pushDataFromArray(songs: T[]) {
    songs.forEach((item: T) => {
      this.pushData(item);
    });
  }

  getData(index: number): T {
    index = this.calcIndex(index);
    return this.dataArray[index];
  }

  addData(index: number, data: T): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  delData(index: number): void {
    index = this.calcIndex(index);
    this.dataArray.splice(index, 1);
    this.notifyDataDelete(index);
  }

  calcIndex(index: number): number {
    return this.reverseData ? this.dataArray.length - 1 - index : index;
  }

  // 该方法为框架侧调用，为LazyForEach组件向其数据源处添加listener监听
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  // 该方法为框架侧调用，为对应的LazyForEach组件在数据源处去除listener监听
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }

  // 通知LazyForEach组件需要重载所有子组件
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  // 通知LazyForEach组件需要在index对应索引处添加子组件
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  // 通知LazyForEach组件在index对应索引处数据有变化，需要重建该子组件
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  // 通知LazyForEach组件需要在index对应索引处删除该子组件
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  // 通知LazyForEach组件将from索引和to索引处的子组件进行交换
  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }
}