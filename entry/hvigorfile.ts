import { hapTasks, OhosPluginId } from '@ohos/hvigor-ohos-plugin';
import { getNode, hvigor } from '@ohos/hvigor'
import { execFileSync } from 'child_process'
import * as path from 'path'
import * as fs from 'fs'

type BuildMode = 'debug' | 'release'

// ===== 新增：KMP 工程配置开始 =====
// 这里写你的 KMP 工程路径。
const KMP_PROJECT_DIR: string = '/Users/te/Desktop/MyTestApp/InstaAppKmp'

// 这里写你的 KMP shared 模块名。
const KMP_SHARED_MODULE: string = ':shared'
// ===== 新增：KMP 工程配置结束 =====

// ===== 新增：获取当前构建模式开始 =====
// 作用：
// 1. DevEco Studio 点击 Run，通常识别为 debug。
// 2. DevEco Studio 构建 Release，识别为 release。
// 3. 如果识别不到，默认按 debug 处理。
function getCurrentBuildMode(): BuildMode {
  // ===== 新增：优先从 HAP 插件上下文读取 buildMode =====
  try {
    const node = getNode(__filename)
    const hapPluginId = (OhosPluginId as unknown as Record<string, string>).OHOS_HAP_PLUGIN

    if (hapPluginId) {
      const context = node.getContext(hapPluginId) as Record<string, unknown>
      const getBuildMode = context['getBuildMode']

      if (typeof getBuildMode === 'function') {
        const mode = String(getBuildMode.call(context)).toLowerCase()

        if (mode.includes('release')) {
          return 'release'
        }

        if (mode.includes('debug')) {
          return 'debug'
        }
      }
    }
  } catch (_) {
    // 读取 HAP 插件上下文失败时，继续走后面的兜底逻辑。
  }

  // ===== 新增：从 Hvigor 扩展参数读取 buildMode =====
  try {
    const parameter = hvigor.getParameter()
    const extParams = parameter.getExtParams() as Record<string, string>

    const mode = String(extParams['buildMode'] ?? extParams['mode'] ?? '').toLowerCase()

    if (mode.includes('release')) {
      return 'release'
    }

    if (mode.includes('debug')) {
      return 'debug'
    }
  } catch (_) {
    // 读取扩展参数失败时，继续走命令行兜底逻辑。
  }

  // ===== 新增：从命令行参数兜底判断 =====
  const argvText = process.argv.join(' ').toLowerCase()

  if (argvText.includes('release')) {
    return 'release'
  }

  return 'debug'
}
// ===== 新增：获取当前构建模式结束 =====


// ===== 新增：注册 DevEco 构建前自动编译 KMP shared 的插件开始 =====
function buildKmpSharedPlugin() {
  return {
    pluginId: 'BuildKmpSharedPlugin',

    apply(pluginContext) {
      pluginContext.registerTask({
        name: 'buildKmpShared',

        run: () => {
          const buildMode = getCurrentBuildMode()

          // ===== 新增：根据当前 entry/hvigorfile.ts 自动推导 HarmonyOS 工程路径 =====
          const harmonyModuleDir = __dirname
          const harmonyProjectDir = path.resolve(harmonyModuleDir, '..')
          const harmonyModuleName = path.basename(harmonyModuleDir)

          const gradlew = path.join(KMP_PROJECT_DIR, 'gradlew')

          if (!fs.existsSync(gradlew)) {
            throw new Error(`未找到 KMP Gradle Wrapper：${gradlew}`)
          }

          // ===== 新增：根据 Debug / Release 自动选择 KMP 发布任务 =====
          const gradleTask = buildMode === 'release'
            ? `${KMP_SHARED_MODULE}:publishReleaseOhosToHarmony`
            : `${KMP_SHARED_MODULE}:publishDebugOhosToHarmony`

          console.log(`[KNOI] buildMode=${buildMode}`)
          console.log(`[KNOI] kmpProjectDir=${KMP_PROJECT_DIR}`)
          console.log(`[KNOI] harmonyProjectDir=${harmonyProjectDir}`)
          console.log(`[KNOI] harmonyModuleName=${harmonyModuleName}`)
          console.log(`[KNOI] execute ${gradleTask}`)

          // ===== 新增：调用 KMP 工程 Gradle，编译并复制 lib / header / ts-api =====
          execFileSync(
            gradlew,
            [
              gradleTask,
              `-PharmonyProjectDir=${harmonyProjectDir}`,
              `-PharmonyModuleName=${harmonyModuleName}`,
              '--no-daemon',
              '--stacktrace'
            ],
            {
              cwd: KMP_PROJECT_DIR,
              stdio: 'inherit'
            }
          )
        },

        // ===== 新增：插入到 ArkTS 编译前 =====
        // 原因：ts-api 可能会被 ArkTS 源码 import，所以必须在 CompileArkTS 前准备好。
        dependencies: ['default@BuildJS'],
        postDependencies: ['default@CompileArkTS']
      })
    }
  }
}
// ===== 新增：注册 DevEco 构建前自动编译 KMP shared 的插件结束 =====


// ===== 修改：挂载自定义插件到 HAP 构建流程 =====
export default {
  system: hapTasks,
  plugins: [
    buildKmpSharedPlugin()
  ]
}