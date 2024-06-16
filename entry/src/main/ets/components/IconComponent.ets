@Component
export struct IconComponent {
  private iconColor: string;
  private resource: Resource
  private iconSize: number = 32;
  private text?: string
  private onTap?: () => void;

  @Builder IconBuilder() {
    Image(this.resource)
      .width(this.iconSize)
      .aspectRatio(1)
      .fillColor(this.iconColor)
      .onClick(() => {
        if (this.onTap) this.onTap();
      });
  }

  build() {
    if (this.text) {
      Row() {
        this.IconBuilder();
        Text(this.text);
      }
    } else {
      this.IconBuilder();
    }
  }
}