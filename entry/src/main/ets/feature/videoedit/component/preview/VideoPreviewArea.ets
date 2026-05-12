import { INFO } from '../../../../common/utils/logutils'
import { VideoResolutionRatioEnum } from '../../constants/VideoResolutionRatioEnum'

const tag = 'VideoPreviewArea'

@Preview
@ComponentV2
export struct VideoPreviewArea {
  @Param @Require selectedRatio: VideoResolutionRatioEnum
  @Param @Require xComponentId: string
  @Param @Require xComponentController: XComponentController

  private xComponentOptions: XComponentOptions = {
    type: XComponentType.SURFACE,
    controller: this.xComponentController
  }

  build() {
      Stack({alignContent:Alignment.Center}) {
        XComponent(this.xComponentOptions)
          .id(this.xComponentId)
          .width(this.getCanvasWidth())
          .aspectRatio(this.getCanvasRatio())
          .backgroundColor(Color.Black)
          .onLoad(() => {
            this.onXComponentLoad()
          })
          .onDestroy(() => {
            this.onXComponentDestroy()
          })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
      .clip(true)
  }

  private onXComponentLoad(): void {
    const surfaceSize: SurfaceSize = this.getSurfaceSize()
    this.xComponentController.setXComponentSurfaceSize({
      surfaceWidth: surfaceSize.width,
      surfaceHeight: surfaceSize.height
    })

    const surfaceId: string = this.xComponentController.getXComponentSurfaceId()

    INFO(tag, `VideoPreviewArea XComponent loaded, surfaceId = ${surfaceId}`)
    INFO(tag, `Surface size: ${surfaceSize.width} x ${surfaceSize.height}`)
  }

  private onXComponentDestroy(): void {
    INFO(tag, 'VideoPreviewArea XComponent destroyed')
  }

  private getCanvasWidth(): Length {
    switch (this.selectedRatio) {
      case VideoResolutionRatioEnum.RATIO_1_1:
        return '100%'

      case VideoResolutionRatioEnum.RATIO_235_1:
        return '100%'

      case VideoResolutionRatioEnum.RATIO_16_9:
        return '100%'

      case VideoResolutionRatioEnum.RATIO_9_16:
        return '70%'

      default:
        return '100%'
    }
  }

  private getCanvasRatio(): number {
    switch (this.selectedRatio) {
      case VideoResolutionRatioEnum.RATIO_1_1:
        return 1 / 1

      case VideoResolutionRatioEnum.RATIO_235_1:
        return 2.35 / 1

      case VideoResolutionRatioEnum.RATIO_16_9:
        return 16 / 9

      case VideoResolutionRatioEnum.RATIO_9_16:
        return 9 / 16

      default:
        return 16 / 9
    }
  }

  private getSurfaceSize(): SurfaceSize {
    const ratio: number = this.getCanvasRatio()
    const baseShortSide: number = 1080

    if (ratio >= 1) {
      return {
        width: Math.round(baseShortSide * ratio),
        height: baseShortSide
      }
    }
    return {
      width: baseShortSide,
      height: Math.round(baseShortSide / ratio)
    }
  }
}

interface SurfaceSize {
  width: number
  height: number
}