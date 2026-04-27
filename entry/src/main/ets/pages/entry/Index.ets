import { EmitterUtil } from '@pura/harmony-utils'
import { AppEvents } from '../../common/event/AppEvents'
import { AppInitState, AppInitStatus } from '../../common/state/AppInitState'
import { DEBUG, ERROR } from '../../common/utils/logutils/index'
import { HomePage } from '../Home/HomePage'

const tag: string = 'EntryPage'

@Entry
@Component
struct Index {
  private pageStack: NavPathStack = new NavPathStack()
  @State private appReady: boolean = false

  private unsubscribeAppInit(): void {
    EmitterUtil.unSubscribe(AppEvents.APP_INIT)
  }

  private subscribeAppInit(): void {
    DEBUG(tag, `Subscribe the event ${AppEvents.APP_INIT}`)

    EmitterUtil.onSubscribe<boolean>(
      AppEvents.APP_INIT,
      (isSuccess: boolean): void => {
        this.unsubscribeAppInit()

        if (isSuccess) {
          DEBUG(tag, 'App init Success')
          this.appReady = true
          return
        }

        ERROR(tag, 'App init Failed')
      }
    )
  }

  aboutToAppear(): void {
    DEBUG(tag, `Success to show PAGE:${tag}`)

    if (AppInitState.status === AppInitStatus.SUCCESS) {
      DEBUG(tag, 'App already init success before page subscribe')
      this.appReady = true
      return
    }

    if (AppInitState.status === AppInitStatus.FAILED) {
      ERROR(tag, `App already init failed, error=${AppInitState.errorMessage}`)
      return
    }

    this.subscribeAppInit()
  }

  aboutToDisappear(): void {
    this.unsubscribeAppInit()
  }

  @Builder
  splashContent() {
    Stack() {
      Image($r('app.media.index_page_background'))
        .height('100%')
        .width('100%')
        .objectFit(ImageFit.Cover)
        .zIndex(0)

      Column() {
        Text($r('app.string.EntryPage_WaterLabel'))
          .fontColor(Color.White)
          .fontSize(20)
          .padding({ bottom: 40 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Center)
      .zIndex(2)
    }
    .height('100%')
    .width('100%')
    .expandSafeArea(
      [SafeAreaType.SYSTEM, SafeAreaType.CUTOUT],
      [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM, SafeAreaEdge.START, SafeAreaEdge.END]
    )
  }

  build() {
    Navigation(this.pageStack) {
      if (this.appReady) {
        HomePage()
      } else {
        this.splashContent()
      }
    }
    .width('100%')
    .height('100%')
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
  }
}