import { TimeRuler } from "./TimeRuler"

@Preview
@ComponentV2
export struct TimelinePanel {
  @Param currentTime: number = 0
  @Param durationTime: number = 0

  build() {
    Column(){
      TimeRuler({currentTime:this.currentTime,durationTime:this.durationTime})
        .height(20)
    }
      .height('100%')
      .width('100%')
      .backgroundColor(Color.Gray)
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
  }

}