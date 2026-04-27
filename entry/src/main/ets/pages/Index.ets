import { DEBUG, INFO, ERROR , FATAL, WARN} from '../common/utils/logutils/index'

import * as provider from '../ts-api/provider'

const tag = 'EntryPage'


@Entry
@Component
struct Index {
  @State res: string = 'compute a + b'

  build() {
    Column() {
      Text(this.res)
        .onClick(() => {
          DEBUG(tag,"Text is clicked")
          this.res = provider.getCalcService().add(10,30).toString();
        })
    }
    .height('100%')
    .width('100%')
  }
}