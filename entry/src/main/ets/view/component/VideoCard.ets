@Preview
@Component
export default struct VideoCard {
  private defaultHeight: number = 223
  private defaultWidth: number = 339

  @Prop coverPageUrl: string = ''
  @Prop authorAvatarUrl: string = ''
  @Prop authorNickname: string = '未知作者'

  // 改动 1：新增后端返回的真实封面宽度
  // 不能只用 defaultWidth，否则所有 Card 都会按 339:223 显示
  @Prop coverWidth: number = 339

  // 改动 2：新增后端返回的真实封面高度
  // Card 高度要靠 coverWidth / coverHeight 计算出来
  @Prop coverHeight: number = 223

  // 改动 3：新增方法，统一计算当前 Card 的真实宽高比
  // 正常情况下使用后端返回的真实尺寸
  // 后端数据异常时，才使用 empty_video.png 的默认尺寸 339x223
  private getCoverRatio(): number {
    if (this.coverWidth <= 0 || this.coverHeight <= 0) {
      return this.defaultWidth / this.defaultHeight
    }

    return this.coverWidth / this.coverHeight
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        if (this.coverPageUrl.length > 0) {
          Image(this.coverPageUrl)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
            .backgroundColor(Color.White)
        } else {
          Image($r('app.media.empty_video'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
            .backgroundColor(Color.White)
        }

        Row() {
          if (this.authorAvatarUrl.length > 0) {
            Image(this.authorAvatarUrl)
              .width(24)
              .height(24)
              .borderRadius(12)
              .objectFit(ImageFit.Cover)
              .backgroundColor('#eeeeee')
          } else {
            Image($r('app.media.empty_avatar'))
              .width(24)
              .height(24)
              .borderRadius(12)
              .objectFit(ImageFit.Cover)
              .backgroundColor('#eeeeee')
          }

          Text(this.authorNickname)
            .margin({ left: 12 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .height(60)
        .width('100%')
        .backgroundColor('rgba(255, 255, 255, 0.80)')
        .padding({ left: 15, right: 15 })
        .alignItems(VerticalAlign.Center)
      }
        .width('100%')
        .aspectRatio(this.getCoverRatio())
    }
    .width('100%')
    .borderRadius(12)
    .clip(true)
  }
}
