import { DEBUG, ERROR, INFO, FATAL, WARN } from "../../common/utils/logutils";
import { Router } from "@ohos.arkui.UIContext";

const tag = 'VideoCard'

@Preview
@Component
export default struct VideoCard {
  private defaultHeight: number = 223
  private defaultWidth: number = 339
  @Prop coverPageUrl: string = ''
  @Prop authorAvatarUrl: string = ''
  @Prop authorNickname: string = '未知作者'
  @Prop coverWidth: number = 339
  @Prop coverHeight: number = 223
  @Prop topMargin: number = 0
  @Prop videoUrl: string = ''

  private getCoverRatio(): number {
    if (this.coverWidth <= 0 || this.coverHeight <= 0) {
      return this.defaultWidth / this.defaultHeight
    }

    return this.coverWidth / this.coverHeight
  }

  private jumpToVideoPlayPage(): void {
    DEBUG(tag, `The url ${this.videoUrl} is clicked`)
    // 修改点 3：增加空 URL 判断，避免跳转到播放器页面后没有视频源
    if (this.videoUrl.length <= 0) {
      ERROR(tag, 'videoUrl is empty')
      return
    }
    // 修改点 4：使用当前组件的 UIContext 获取 Router，并跳转到播放器页面
    this.getUIContext().getRouter().pushUrl({
      url: 'pages/home/VideoPlayerPage',
      params: {
        videoUrl: this.videoUrl,
        coverWidth: this.coverWidth,
        coverHeight: this.coverHeight
      }
    }).catch(() => {
      ERROR(tag, `Can't Router to url`)
    })
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
        .backgroundColor('rgba(255, 255, 255, 0.6)')
        .padding({ left: 15, right: 15 })
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .aspectRatio(this.getCoverRatio())
    }
    .width('100%')
    .borderRadius(12)
    .clip(true)
    .margin({ top: this.topMargin })
    .onClick(
      () => {
        this.jumpToVideoPlayPage()
      }
    )
  }
}
