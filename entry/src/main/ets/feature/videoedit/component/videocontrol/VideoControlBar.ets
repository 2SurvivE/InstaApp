@ComponentV2
export struct VideoControlBar {
  @Require @Param isPlaying: boolean = false
  @Event onUndoClick: () => void = () => {}
  @Event onRedoClick: () => void = () => {}
  @Event onPlayClick: () => void = () => {}
  @Event onFullscreenClick: () => void = () => {}

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Row() {
        Button({ type: ButtonType.Normal, stateEffect: false }) {
          SymbolGlyph($r('sys.symbol.arrow_left'))
            .fontSize(24)
            .fontColor([Color.White])
        }
        .videoControlIconButtonStyle()
        .onClick(() => {
          this.onUndoClick()
        })

        Button({ type: ButtonType.Normal, stateEffect: false }) {
          SymbolGlyph($r('sys.symbol.arrow_right'))
            .fontSize(24)
            .fontColor([Color.White])
        }
        .videoControlIconButtonStyle()
        .margin({ left: 8 })
        .onClick(() => {
          this.onRedoClick()
        })

        Blank()

        Button({ type: ButtonType.Normal, stateEffect: false }) {
          SymbolGlyph($r('sys.symbol.fullscreen'))
            .fontSize(24)
            .fontColor([Color.White])
        }
        .videoControlIconButtonStyle()
        .onClick(() => {
          this.onFullscreenClick()
        })
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 }) // 内容距离左右边缘
      .backgroundColor(Color.Black)
      .alignItems(VerticalAlign.Center)

      Button({ type: ButtonType.Normal, stateEffect: false }) {
        if (!this.isPlaying) {
          SymbolGlyph($r('sys.symbol.play'))
            .fontSize(26)
            .fontColor([Color.White])
        } else {
          SymbolGlyph($r('sys.symbol.pause'))
            .fontSize(26)
            .fontColor([Color.White])
        }
      }
      .videoControlCenterButtonStyle() // 中间播放按钮固定居中
      .onClick(() => {
        this.onPlayClick()
      })
    }
    .backgroundColor(Color.Black)
  }
}

@Extend(Button)
function videoControlIconButtonStyle() {
  .width(40)
  .height(40)
  .padding(0)
  .backgroundColor(Color.Transparent)
  .borderRadius(0)
}

@Extend(Button)
function videoControlCenterButtonStyle() {
  .width(56)
  .height(48)
  .padding(0)
  .backgroundColor(Color.Transparent)
  .borderRadius(0)
}