@Component
export struct IconComponent {
  private iconColor: string;
  private resource?: Resource
  private iconSize: number = 32;
  private text?: string
  private onTap?: () => void;
  private defaultResource?: Resource;

  getIconData(): Resource {
    return this.resource ? this.resource : this.defaultResource;
  }

  @Builder IconBuilder(iconData: Resource) {
    Image(iconData)
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
        this.IconBuilder(this.getIconData());
        Text(this.text);
      }
    } else {
      this.IconBuilder(this.getIconData());
    }
  }
}