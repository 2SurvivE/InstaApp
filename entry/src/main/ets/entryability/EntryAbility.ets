import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { DEBUG, INFO, ERROR, FATAL, WARN } from '../common/utils/logutils/index'
import { setup, init } from "@kuiklybase/knoi"
import { init_all_service_provider } from '../common/utils/bootstrap/bootstrap'
import { AppUtil, EmitterUtil } from '@pura/harmony-utils';
import { AppInitState, AppInitStatus } from '../common/state/AppInitState';
import { AppEvents } from '../common/event/AppEvents';

const DOMAIN = 0x0000;
const tag = 'EntryAbility'

export default class EntryAbility extends UIAbility {

  private async initFullScreenLayout(windowStage: window.WindowStage) {
    try {
      DEBUG(tag, "Start to set full screen mode")
      const mainWindow: window.Window = await windowStage.getMainWindow()

      await mainWindow.setWindowLayoutFullScreen(true)

      await mainWindow.setWindowSystemBarProperties({
        statusBarColor: '#00000000',
        navigationBarColor: '#00000000',
        statusBarContentColor: '#ff000000',
        navigationBarContentColor: '#ff000000'
      })

    } catch (e) {
      ERROR(tag, `Can't set full screen mode, cause ${JSON.stringify(e)}`)
    }
  }

  private async initKNOI(){
    DEBUG(tag, 'Start to init KNOI');
    setup('libkn.so', true)
    init();
    DEBUG(tag, 'KNOI initted')
  }

  private async initServiceProvider(){
    DEBUG(tag, 'Start to init ServiceProvider');
    init_all_service_provider();
    DEBUG(tag,'ServiceProvider initted')
  }

  private async initHarmonyOSUtils(){
    DEBUG(tag,"Try to init @Pura/Harmony-utils")
    try{
      AppUtil.init(this.context)
      DEBUG(tag,'@Pura/Harmony-utils initted')
    }catch (e){
      ERROR(tag,`Can't Init @Pura/Harmony-utils, ${JSON.stringify(e)}`)
    }
  }

  private async initColorMode(){
    DEBUG(tag,"Try to init Color mode")
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      DEBUG(tag,"Color mode initted")
    } catch (err) {
      ERROR(tag, `Failed to set colorMode. Cause: ${JSON.stringify(err)}`);
    }
  }

  private delay(ms: number): Promise<void> {
    return new Promise<void>((resolve: () => void): void => {
      setTimeout((): void => {
        resolve()
      }, ms)
    })
  }

  private async startAppInitAsync(): Promise<void>{
    try{
      this.initHarmonyOSUtils()
      this.initKNOI()
      this.initServiceProvider()
      this.initColorMode()
      DEBUG(tag, 'App init success');
      await this.delay(3000)
      AppInitState.success()
      EmitterUtil.post<boolean>(AppEvents.APP_INIT, true)
    }catch (e) {
      DEBUG(tag, 'App init failure');
      AppInitState.failed(`Error, ${JSON.stringify(e)}`)
      EmitterUtil.post<boolean>(AppEvents.APP_INIT, false)
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    DEBUG(tag, 'EntryAbility.onCreate(), start to init app');
  }

  onDestroy(): void {
    DEBUG(tag, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    DEBUG(tag, 'Ability onWindowStageCreate');
    this.initFullScreenLayout(windowStage)
    windowStage.loadContent('pages/entry/Index', (err: BusinessError): void => {
      if (err.code) {
        ERROR(tag, `Failed to load the content. Code: ${err.code}, message: ${err.message}`)
        return
      }
      INFO(tag, 'Succeeded in loading the content.')
      this.startAppInitAsync();
    })
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    DEBUG(tag, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    DEBUG(tag, 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    DEBUG(tag, 'Ability onBackground');
  }
}