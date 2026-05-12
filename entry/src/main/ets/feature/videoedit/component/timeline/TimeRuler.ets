import { Ms2MmSs } from "../../util/TimeUtils"

@Preview
@ComponentV2
export struct TimeRuler{
  @Require @Param currentTime:number = 0
  @Require @Param durationTime:number = 0


  build(){
    Row(){
      Text(`${Ms2MmSs(this.currentTime)}/${Ms2MmSs(this.durationTime)}`)
        .fontColor(Color.White)
    }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
  }

}