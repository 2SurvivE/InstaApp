import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { DEBUG, INFO, ERROR, FATAL, WARN } from '../common/utils/logutils/index'
import { setup, init } from "@kuiklybase/knoi"
import { init_all_service_provider } from '../common/utils/bootstrap/bootstrap'

const DOMAIN = 0x0000;
const tag = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  async setFullScreenLayout(windowStage: window.WindowStage) {
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

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    DEBUG(tag, 'Start to init JNOI');
    setup('libkn.so', true)
    init();
    DEBUG(tag, 'Start to register service provider')
    init_all_service_provider();

    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      ERROR(tag, `Failed to set colorMode. Cause: ${JSON.stringify(err)}`);
    }
    DEBUG(tag, 'Ability onCreate');
  }

  onDestroy(): void {
    DEBUG(tag, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    DEBUG(tag, 'Ability onWindowStageCreate');

    this.setFullScreenLayout(windowStage)

    windowStage.loadContent('pages/Index', (err: BusinessError): void => {
      if (err.code) {
        ERROR(tag, `Failed to load the content. Code: ${err.code}, message: ${err.message}`)
        return
      }
      INFO(tag, 'Succeeded in loading the content.')
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