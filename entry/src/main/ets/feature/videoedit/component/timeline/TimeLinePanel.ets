import { DisplayUtil } from "@pura/harmony-utils"
import { DEBUG } from "../../../../common/utils/logutils/Logger"
import { TimeRuler } from "./TimeRuler"
const tag = "TimelinePanel"

@Preview
@ComponentV2
export struct TimelinePanel {
  @Param @Require currentTime: number
  @Param @Require durationTime: number
  @Event onTimeChange: (timeMs:number) => void = (_timeMs:number) =>{}
  private scroller: Scroller = new Scroller()
  build() {
    Stack({alignContent:Alignment.Center}){
      Stack({alignContent:Alignment.TopStart}){
        Scroll(this.scroller){
          TimeRuler(
            {
              durationMs:this.durationTime,
              fps:30,
              halfViewport:this.getUIContext().px2vp(DisplayUtil.getWidth()/2),
              secondWidth:35
            }
          )
        }
          .height('100%')
          .width('100%')
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)

        // Text(`${Ms2MmSs(this.currentTime)}/${Ms2MmSs(this.durationTime)}`)
        //   .fontColor(Color.White)
        //   .fontSize(14)
        //   .height(20)

      }
      .height('100%')
      .width('100%')

      Column()
        .width(1)
        .height(120)
        .backgroundColor(Color.White)

    }
      .height('100%')
      .width('100%')

  }
}