import { VideoResolutionRatioEnum } from '../../constants/VideoResolutionRatioEnum'

@Preview
@ComponentV2
struct VideoEditTopBar{
  @Param selectedRatio: VideoResolutionRatioEnum = VideoResolutionRatioEnum.RATIO_16_9

  @Event onCloseClick: () => void = () => {}
  @Event onSettingClick: () => void = () => {}
  @Event onRatioClick: () => void = () => {}
  @Event onExportClick: () => void = () => {}

  build(){
    Row(){
      // 关闭
      Button(){
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontColor([Color.White])
      }
        .transparentIconButton()
        .margin({left:5})
        .onClick(this.onCloseClick)

      // 设置
      Button(){
        SymbolGlyph($r('sys.symbol.gearshape'))
          .fontColor([Color.White])
      }
        .transparentIconButton()
        .onClick(this.onSettingClick)

      Blank()

      // 分辨率选择
      Button(this.selectedRatio)
        .backgroundColor(Color.Transparent)
        .height(20)
        .border({width:1,color:Color.White})
        .onClick(this.onRatioClick)

      // 导出
      Button(){
        SymbolGlyph($r('sys.symbol.share'))
          .fontColor([Color.White])
      }
        .transparentIconButton()
        .onClick(this.onExportClick)

    }
      .width('100%')
      .height(40)
      .backgroundColor(Color.Black)
  }
}

@Extend(Button)
function transparentIconButton(){
  .width(40)
  .height(40)
  .padding(0)
  .backgroundColor(Color.Transparent)
}

export { VideoEditTopBar }
